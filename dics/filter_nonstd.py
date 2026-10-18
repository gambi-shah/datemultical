#!/usr/bin/env python3

from pathlib import Path
import re


INPUT_PATH = Path("dics/calendars-sorted.txt")
OUTPUT_PATH = Path("dics/calendars-nonstd.txt")

STANDARD_STRUCTURE = "year, month, day"


def parse_line(line: str):
    """Parse one row from calendars-sorted.txt."""

    line = line.rstrip()

    if not line.strip():
        return None

    # Ignore separator lines.
    if re.fullmatch(r"[\s-]+", line):
        return None

    # Columns are separated by at least two spaces.
    columns = re.split(r"\s{2,}", line.strip())

    if len(columns) < 4:
        return None

    name = columns[0].strip()
    structure = columns[1].strip()
    read_only = columns[-1].strip()

    # Ignore the header.
    if name.casefold() == "name":
        return None

    if read_only.casefold() not in {"yes", "no"}:
        return None

    return name, structure


def main():
    if not INPUT_PATH.is_file():
        raise FileNotFoundError(
            f"Input file not found: {INPUT_PATH}"
        )

    calendars = []

    for line in INPUT_PATH.read_text(
        encoding="utf-8"
    ).splitlines():
        row = parse_line(line)

        if row is None:
            continue

        name, structure = row

        # Keep calendars whose structure is not the standard
        # year-month-day structure.
        if structure.casefold() != STANDARD_STRUCTURE.casefold():
            calendars.append((name, structure))

    # The input is already sorted, but sort again for safety.
    calendars.sort(key=lambda row: row[0].casefold())

    headers = (
        "Name",
        "Structure",
    )

    widths = [
        max(
            len(headers[index]),
            *(len(row[index]) for row in calendars),
        )
        for index in range(2)
    ]

    OUTPUT_PATH.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with OUTPUT_PATH.open(
        "w",
        encoding="utf-8",
        newline="\n",
    ) as file:
        # Header
        file.write(
            "  ".join(
                headers[index].ljust(widths[index])
                for index in range(2)
            ).rstrip()
            + "\n"
        )

        # Separator
        file.write(
            "  ".join(
                "-" * widths[index]
                for index in range(2)
            )
            + "\n"
        )

        # Data rows
        for row in calendars:
            file.write(
                "  ".join(
                    row[index].ljust(widths[index])
                    for index in range(2)
                ).rstrip()
                + "\n"
            )

    print(
        f"{len(calendars)} non-standard calendar(s) "
        f"written to {OUTPUT_PATH}"
    )


if __name__ == "__main__":
    main()
