## Interactive visualizations (Tables 9, 10, 12, 14, 15, 16, 17, 18)

This folder contains **standalone HTML embeds** (no build step) generated from `Veterans-2025-Accessible.pdf`.

### Files
- `table09.html`: Median age of Texas veterans by period of service (2023)
- `table10.html`: Disability types reported by veterans vs nonveterans (Texas, 2023)
- `table12.html`: Service-connected disability ratings distribution (Texas veterans, 2023)
- `table14.html`: Labor force participants by age group (Texas, 2023)
- `table15.html`: Class of worker distribution (Texas veteran labor force, 2023)
- `table16.html`: Top 20 industries employing Texas veterans (2023)
- `table17.html`: Top 20 occupations of veterans in Texas (2023)
- `table18.html`: Average yearly salary by educational attainment (Texas veterans, 2023)

### How to embed in a digital poster

- **Option A (recommended): iframe**
  - Upload the HTML files to any static host (GitHub Pages, Netlify, university web space, etc.)
  - Embed with an iframe, e.g.:

```html
<iframe
  src="table16.html"
  width="100%"
  height="520"
  style="border:0;"
  loading="lazy"
></iframe>
```

- **Option B: open directly**
  - Double-click an `.html` file to open locally (works best in Chrome).

### Notes
- Charts use Plotly via CDN. If your poster environment blocks external scripts, tell me what platform you’re using and I’ll generate **fully self-contained** versions.

