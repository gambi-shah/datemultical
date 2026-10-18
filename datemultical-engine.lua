-- datemultical-engine.lua
--
-- Lua date-conversion engine for datemultical.
--
-- Copyright (C) 2026 Amer Amikhteh
--
-- This file is part of the datemultical package.
--
-- This work is free software: you may redistribute it and/or modify
-- it under the terms of the LaTeX Project Public License as published
-- by the LaTeX Project, either version 1.3c of the License, or
-- (at your option) any later version.
--
-- This work is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty
-- of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- The full license text is available at:
-- https://www.latex-project.org/lppl/
--
-- This work is "maintained" by Amer Amikhteh.
--
-- The current maintainer of this work is Amer Amikhteh.
--
-- Version: 0.2.0
-- Date: 2026-10-18

local ok, calendrica = pcall(require, "calendrica")

local M = {}

local tex_store_result

local RD_TO_JDN = 1721425

M.available = ok

if not ok then
  return M
end

-- =================================================
-- Calendar definitions
-- =================================================

local calendars = {
  -- Primary aliases
  gr = "gregorian",
  sh = "persian",
  lh = "islamic-tbla",
}

-- Full calendar names
for _, name in ipairs(calendrica.calendars()) do
  calendars[name] = name
end


-- =================================================
-- Calendar lookup
-- =================================================

local function get_calendar(name)
  local cal = calendars[name]

  if not cal then
    error(
      "datemultical: unknown calendar `"
      .. tostring(name)
      .. "`"
    )
  end

  return cal
end

-- =================================================
-- Create calendar date
-- =================================================

local function new_date(calendar, year, month, day)
  local cal = get_calendar(calendar)

  return calendrica.date(
    {
      year = tonumber(year),
      month = tonumber(month),
      day = tonumber(day),
    },
    cal
  )
end

-- =================================================
-- Create calendar date from structured fields
-- =================================================

local function boolean_value(value)
  if value == nil or value == "" then
    return nil
  end

  if value == "true" or value == "1" then
    return true
  end

  if value == "false" or value == "0" then
    return false
  end

  return value
end

local function number_value(value)
  if value == nil or value == "" then
    return nil
  end

  return tonumber(value)
end

-- local function normalize_fields(fields)
--   return {
--     major = number_value(fields.major),
--     cycle = number_value(fields.cycle),
--     year = number_value(fields.year),
--     month = number_value(fields.month),
--     week = number_value(fields.week),
--     day = number_value(fields.day),
--     leap = boolean_value(fields.leap),
--     leap_month = boolean_value(fields.leap_month),
--     leap_day = boolean_value(fields.leap_day),
--   }
-- end

local function normalize_value(value)
  if value == nil or value == "" then
    return nil
  end

  local boolean = boolean_value(value)

  if type(boolean) == "boolean" then
    return boolean
  end

  local number = tonumber(value)

  if number ~= nil then
    return number
  end

  return value
end

local function normalize_fields(fields)
  local normalized = {}

  for key, value in pairs(fields) do
    normalized[key] = normalize_value(value)
  end

  return normalized
end


local function new_date_from_fields(calendar, fields)
  local cal = get_calendar(calendar)
  local normalized = normalize_fields(fields)
  return calendrica.date(normalized, cal)
end


-- =================================================
-- Structured date -> RD
-- =================================================

function M.fields_to_rd(calendar, fields)
  local date = new_date_from_fields(calendar, fields)
  return date.rd
end

-- =================================================
-- Structured date -> all supported calendars
-- =================================================

function M.convert_all_fields(calendar, fields)
  local rd = M.fields_to_rd(calendar, fields)
  local result = {}

  for name in pairs(calendars) do
    local date = M.rd_to_date(name, rd)
    result[name] = date
  end

 result.rd = rd
result.jdn = rd + RD_TO_JDN
  result.weekday = (rd + 0) % 7

  return result
end

-- =================================================
-- Public structured setter
-- =================================================

function M.set_date_fields(calendar, label, fields)
  local result = M.convert_all_fields(calendar, fields)
  tex_store_result(label, result)
end


-- =================================================
-- Parse key-value payload
-- =================================================

local function parse_fields(payload)
  local fields = {}

  for item in string.gmatch(payload, "([^,]+)") do
    local key, value = string.match(item, "^%s*([%a_]+)%s*=%s*(.-)%s*$")
    if key then
      fields[key] = value
    end
  end

  return fields
end

function M.set_date_kv(calendar, label, payload)
  local fields = parse_fields(payload)
  M.set_date_fields(calendar, label, fields)
end





-- =================================================
-- Date -> RD
-- =================================================

function M.date_to_rd(calendar, year, month, day)
  local date = new_date(calendar, year, month, day)
  return date.rd
end

-- =================================================
-- RD -> date
-- =================================================

function M.rd_to_date(calendar, rd)
  local cal = get_calendar(calendar)
  return calendrica.date(tonumber(rd), cal)
end

-- =================================================
-- Date -> all supported calendars
-- =================================================

function M.convert_all(calendar, year, month, day)
  local rd = M.date_to_rd(calendar, year, month, day)
  local result = {}

  for name in pairs(calendars) do
    local date = M.rd_to_date(name, rd)
    result[name] = date
  end

  result.rd = rd
  result.jdn = rd + RD_TO_JDN
  result.weekday = rd % 7

  return result
end


-- =================================================
-- Store complete result in TeX
-- =================================================

tex_store_result = function(label, result)
  for name, date in pairs(result) do
    if type(date) == "table" then
      for key, value in pairs(date) do
        tex.sprint(
          "\\dmcLuaStoreDynamic{"
          .. tostring(name)
          .. "}{"
          .. tostring(label)
          .. "}{"
          .. tostring(key)
          .. "}{"
          .. tostring(value)
          .. "}"
        )
      end
    end
  end

  tex.sprint(
    "\\dmcLuaStoreRD{"
    .. tostring(label)
    .. "}{"
    .. tostring(result.rd)
    .. "}"
  )

  tex.sprint(
    "\\dmcLuaStoreJDN{"
    .. tostring(label)
    .. "}{"
    .. tostring(result.jdn)
    .. "}"
  )

  tex.sprint(
    "\\dmcLuaStoreWeekday{"
    .. tostring(label)
    .. "}{"
    .. tostring(result.weekday)
    .. "}"
  )
end

-- =================================================
-- Public setter
-- =================================================

function M.set_date(calendar, label, year, month, day)
  local result = M.convert_all(calendar, year, month, day)
  tex_store_result(label, result)
end

-- =================================================
-- Existing conversion interface
-- =================================================

function M.dateconvert(source, destination, year, month, day, part)
  local src = new_date(source, year, month, day)
  local dst = get_calendar(destination)
  local result = src:to(dst)

  if part == "year" then
    tex.sprint(result.year)
  elseif part == "month" then
    tex.sprint(result.month)
  elseif part == "day" then
    tex.sprint(result.day)
  else
    error(
      "datemultical: unknown type `"
      .. tostring(part)
      .. "`; expected year, month, or day"
    )
  end
end

_G.dmc = M

return M
