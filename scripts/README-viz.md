## Visualizations — Flourish only

Interactive charts for Tables **9, 10, 12, 14, 15, 16, 17, 18** and an optional **county map** are meant to be built in **[Flourish](https://flourish.studio/)**, not in this repository’s code.

### Workflow

1. Prepare a small table in **Excel** or **Google Sheets** (or export from R as CSV for your own use — no special format required for Flourish).
2. In Flourish, **Import data** and choose a story type (bar, grouped bar, pie, map, etc.).
3. Style the chart, then **Export & publish** → **Embed in a website**.
4. Copy the embed `<div class="flourish-embed" …></div>` and paste it into **`charts.html`** in the matching section (replace the gray dashed placeholder), if you use that optional page.  
   The page already includes the Flourish embed **script** once at the bottom — do not duplicate that script for each chart.

### County map

Use Flourish’s **choropleth** (or similar) for Texas counties. A starting dataset is:

- `references/county_veterans_2023.csv`

Match county names or FIPS to Flourish’s Texas county geography template per Flourish’s import instructions.

### Embedding in your poster

- **Figma Sites (or similar):** paste each Flourish embed snippet, or iframe a local / hosted `charts.html` if you use that collector page.

### Official help

- [How to embed a chart on your own website](https://help.flourish.studio/article/80-how-to-embed-a-chart-on-your-own-website)

The old Plotly standalone pages and R → JSON export have been **removed** on purpose to keep the project student-simple.
