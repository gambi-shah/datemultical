#!/usr/bin/env python3

from pathlib import Path
import re
import sys


READ_ONLY_RE = re.compile(
    r"\s+Read-only\s*:?\s*\.?",
    flags=re.IGNORECASE,
)


def parse_calendar_line(line: str):
    """
    Parse a row from the fixed-width calendars table.

    Expected form:

        name    structure    description
    """

    line = line.rstrip().lstrip()

    # Empty lines and separator lines
    if not line or line.startswith("-"):
        return None

    # The three input columns are separated by at least two spaces.
    match = re.match(
        r"(\S+)\s{2,}(.+?)\s{2,}(.+)$",
        line,
    )

    if not match:
        return None

    name, structure, description = match.groups()

    # Ignore table headings and other non-calendar lines.
    if name in {
        "Name",
        "Calendars",
        "Additional",
        "generated",
    }:
        return None

    read_only = bool(READ_ONLY_RE.search(description))

    # Remove Read-only or Read-only: from the description.
    description = READ_ONLY_RE.sub(" ", description)

    # Clean up spaces left after removing the marker.
    description = re.sub(r"\s+([.:])", r"\1", description)
    description = re.sub(r"\s{2,}", " ", description).strip()

    return (
        name.strip(),
        structure.strip(),
        description,
        "yes" if read_only else "no",
    )


def main():
    # Default paths, relative to the project root.
    input_path = Path("dics/calendars.txt")
    output_path = Path("dics/calendars-sorted.txt")

    # Optional explicit paths are still supported.
    if len(sys.argv) == 3:
        input_path = Path(sys.argv[1])
        output_path = Path(sys.argv[2])
    elif len(sys.argv) != 1:
        print(
            f"کاربرد: {sys.argv[0]} [INPUT.txt OUTPUT.txt]",
            file=sys.stderr,
        )
        sys.exit(1)

    if not input_path.is_file():
        print(
            f"خطا: فایل ورودی پیدا نشد: {input_path}",
            file=sys.stderr,
        )
        print(
            "اسکریپت را از پوشهٔ اصلی پروژه اجرا کنید.",
            file=sys.stderr,
        )
        sys.exit(1)

    calendars = []

    for line in input_path.read_text(encoding="utf-8").splitlines():
        row = parse_calendar_line(line)

        if row is not None:
            calendars.append(row)

    # Sort alphabetically by calendar name.
    calendars.sort(key=lambda row: row[0].casefold())

    headers = (
        "Name",
        "Structure",
        "Description",
        "Read-only",
    )

    # Calculate the width of each output column.
    widths = [
        max(
            len(headers[index]),
            *(len(row[index]) for row in calendars),
        )
        for index in range(4)
    ]

    output_path.parent.mkdir(parents=True, exist_ok=True)

    with output_path.open(
        "w",
        encoding="utf-8",
        newline="\n",
    ) as file:
        # Header
        file.write(
            "  ".join(
                headers[index].ljust(widths[index])
                for index in range(4)
            ).rstrip()
            + "\n"
        )

        # Separator
        file.write(
            "  ".join(
                "-" * widths[index]
                for index in range(4)
            )
            + "\n"
        )

        # Rows
        for row in calendars:
            file.write(
                "  ".join(
                    row[index].ljust(widths[index])
                    for index in range(4)
                ).rstrip()
                + "\n"
            )

    print(f"{len(calendars)} calendar(s) written to {output_path}")


if __name__ == "__main__":
    main()
