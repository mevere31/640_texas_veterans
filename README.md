# Texas veterans (INFO 640 / 658)

Reproducible analysis in R using ACS PUMS (IPUMS), plus **Flourish** for the interactive charts.

## Visualizations (Flourish)

1. Sign up at [Flourish](https://flourish.studio/) and create a project.
2. Pick a template (bar chart, grouped bar, pie, choropleth map, etc.).
3. **Data:** paste from Excel, upload a CSV, or copy from [data.census.gov](https://data.census.gov/) / your memo. You do **not** need the old Plotly HTML or JSON export.
4. **Publish** the visual, then **Embed in a website** and copy the embed snippet.
5. Optional: open **`charts.html`** locally, paste Flourish embed snippets into the placeholder sections if you want one HTML page that holds all embeds.

More detail: **`scripts/README-viz.md`**.

## R analysis

| Path | Role |
|------|------|
| `scripts/texasvets_eda.R` | IPUMS pull, Texas filter, `srvyr` design, EDA tables, **export workbook for charts** |

Set `IPUMS_API_KEY` (e.g. `Sys.setenv(IPUMS_API_KEY = "…")` before sourcing). Run with working directory at the **project root** so `outputs/` is created next to `scripts/`.

After the script runs, open **`outputs/texas_vets_tables_for_charts.xlsx`** (requires `writexl`; otherwise the same tables are written as separate CSVs in `outputs/`). Import a sheet into Flourish or copy into Google Sheets.

## Reference data

- **`references/county_veterans_2023.csv`** — county counts for a Flourish Texas choropleth (see `charts.html`).

## License

See `LICENSE` if present in the repository.
