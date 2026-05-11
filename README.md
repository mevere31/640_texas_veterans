# Texas veterans (INFO 640)

ACS PUMS–based exploratory analysis and a small **GitHub Pages** site.

| Path | Purpose |
|------|--------|
| `texasvets_eda.R` | Pull IPUMS microdata, build Texas `srvyr` survey object, EDA tables, and export chart JSON |
| `poster_viz/export_poster_viz_data.R` | Write `poster_viz/data/table*.json` for the embeddable charts |
| `poster_viz/*.html` | Plotly charts + county map (embed or open locally) |
| `poster_viz/county_veterans_2023.csv` | County totals for the map (static; not from PUMS without PUMA→county allocation) |
| `index.html` + `site/styles.css` | Optional landing / hero page for GitHub Pages |

Set `IPUMS_API_KEY` before running `texasvets_eda.R`. See `poster_viz/README.md` for chart export and hosting.
