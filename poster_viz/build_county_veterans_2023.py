import re
from pathlib import Path

import pandas as pd
import pdfplumber


ROOT = Path(__file__).resolve().parents[1]
PDF_PATH = ROOT / "Veterans-2025-Accessible.pdf"
OUT_CSV = Path(__file__).resolve().parent / "county_veterans_2023.csv"


def _norm_county_name(s: str) -> str:
    s = s.strip()
    s = re.sub(r"\s+", " ", s)
    return s


def extract_county_totals_from_text(text: str) -> list[tuple[str, int]]:
    """
    Extract rows that look like:
      CountyName <whitespace> 5,315 <whitespace> 4,633 <whitespace> 682 ...
    and returns (county, total_veterans)
    """
    out: list[tuple[str, int]] = []
    for line in (text or "").splitlines():
        line = line.strip()
        if not line:
            continue

        # Skip headers and totals/region lines
        if any(
            key in line
            for key in (
                "Table ",
                "LWDA ",
                "County",
                "Texas Workforce Investment Council",
                "Total Veteran",
                "Veteran Population",
                "Years",
            )
        ):
            continue

        # Skip region totals like "Panhandle Total  22,859 ..."
        if re.search(r"\bTotal\b", line) and not re.match(r"^[A-Za-z].*\d", line):
            continue
        if re.search(r"\bTotal\b", line) and re.search(r"\bTotal\s+\d", line):
            # keep only if it is a county literally named "Total" (it isn't)
            continue

        # County rows in Appendix C tables have 8 numeric columns after the county name:
        # total, male, female, 18-34, 35-54, 55-64, 65-74, 75+
        nums = re.findall(r"\b\d{1,3}(?:,\d{3})*\b|\b\d+\b", line)
        if len(nums) < 8:
            continue

        # Find the first numeric token to split the county name from the numbers
        first_num_match = re.search(r"\b\d{1,3}(?:,\d{3})*\b|\b\d+\b", line)
        if not first_num_match:
            continue

        county = _norm_county_name(line[: first_num_match.start()])
        if not county:
            continue
        if "Total" in county:
            continue

        total = int(nums[0].replace(",", ""))
        out.append((county, total))
    return out


def main() -> None:
    if not PDF_PATH.exists():
        raise SystemExit(f"PDF not found: {PDF_PATH}")

    pairs: list[tuple[str, int]] = []
    with pdfplumber.open(PDF_PATH) as pdf:
        for page in pdf.pages:
            # Appendix C (county tables) begins late in the PDF. Limit parsing to those pages
            # to avoid accidentally ingesting earlier non-county tables (e.g., disability tables).
            if getattr(page, "page_number", 0) < 34:
                continue
            text = page.extract_text() or ""
            # Appendix C starts around page 28 of the PDF; still parse all pages to be safe.
            pairs.extend(extract_county_totals_from_text(text))

    # De-duplicate keeping the first seen value per county name
    totals: dict[str, int] = {}
    for county, total in pairs:
        totals.setdefault(county, total)

    df = (
        pd.DataFrame([{"county": k, "veterans_2023": v} for k, v in sorted(totals.items())])
        .sort_values("county")
        .reset_index(drop=True)
    )

    df.to_csv(OUT_CSV, index=False)
    print(f"Wrote {OUT_CSV} with {len(df)} counties")


if __name__ == "__main__":
    main()

