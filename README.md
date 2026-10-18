LaTeX Package: DateMultiCal 2026-10-18 v0.2.0
----------------------------------------


Named dates and multi-calendar date formatting for LaTeX.

## Description

`datemultical` provides a unified interface for defining, converting, and
formatting named dates in LaTeX documents.

It provides two backends:

- `basic`: supports the Gregorian, Solar Hijri, and Lunar Hijri calendars
  under all supported engines, with English names and optional Persian
  localization;
- `lua`: selected by default under LuaLaTeX. It supports all calendar
  systems provided by `lua-calendrica`—currently 54, including the three
  core calendars and historical and astronomical calendars.

Newly added calendars become available automatically, without updating
`datemultical`. The `basic` backend can be selected with the `native`
option.

## Installation

### From CTAN

https://ctan.org/pkg/datemultical

~~~bash
tlmgr install datemultical
~~~

### From GitHub

~~~bash
git clone https://github.com/gambi-shah/datemultical.git
~~~

Copy the files into a TeX-searchable directory, or keep them beside your
document. Run `mktexlsr` if necessary.

## Usage

~~~latex
\documentclass{article}
\usepackage{datemultical}

\begin{document}
\dmcset[sh]{birth}{1365}{3}{11}
\dmc{birth}{short}
\dmc[lh]{birth}{full}
\end{document}
~~~

Use `\usepackage[persian]{datemultical}` for Persian localization and
`\usepackage[native]{datemultical}` to select the basic backend under
LuaLaTeX.

## Lua Backend

Calendar-specific components can be defined with `\dmcnew`:

~~~latex
\dmcnew[chinese]{birth}{cycle=78,year=3,month=4,leap=false,day=24}
~~~
## Documentation
See the [main manual](doc/datemultical.pdf) for configuration and examples.

## License and maintainer

- License: LPPL 1.3c or later.
- Maintainer: Amer Amikhteh.
- Report bugs via the [repository issue tracker](https://github.com/gambi-shah/datemultical/issues).
