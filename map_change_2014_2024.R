## Map change (2014–2024) from the provided CSV.
##
## This repo CSV contains percent change (2014–2024) by county (not annual values),
## so this script produces:
## 1) A static choropleth of % change (2014–2024)
## 2) A 2-frame "index" animation (2014=100, 2024=100*(1+pct_change))

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(scales)
  library(sf)
  library(stringr)
  library(tidyr)
  library(tigris)
})

# Optional (only needed for GIF output)
has_gganimate <- requireNamespace("gganimate", quietly = TRUE)
has_gifski <- requireNamespace("gifski", quietly = TRUE)

csv_path <- "Civilian vs Veteran Status of Texas Counties  - Texas Veteran Status 2014 - 202.csv"

# Choose which row to map. Options in your CSV (after cleaning) appear to be:
# - "Civilian Population 18 Years and Over:"
# - "Veteran:"
# - "Nonveteran:"
metric_to_map <- "Veteran:"

out_dir <- "outputs"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# Keep tigris caching inside the project (sandbox-friendly).
tigris_cache_dir <- file.path(out_dir, "tigris_cache")
if (!dir.exists(tigris_cache_dir)) dir.create(tigris_cache_dir, recursive = TRUE)
Sys.setenv(TIGRIS_CACHE_DIR = normalizePath(tigris_cache_dir, winslash = "/", mustWork = FALSE))
options(tigris_use_cache = TRUE)

raw <- read.csv(csv_path, check.names = FALSE, stringsAsFactors = FALSE)
names(raw)[1] <- "metric"

long <- raw %>%
  mutate(metric = str_squish(metric)) %>%
  pivot_longer(
    cols = -metric,
    names_to = "county_name",
    values_to = "pct_change_raw"
  ) %>%
  mutate(
    county = county_name %>%
      str_remove(",\\s*Texas\\s*$") %>%
      str_remove("\\s*County\\s*$") %>%
      str_squish(),
    pct_change = parse_number(pct_change_raw) / 100
  ) %>%
  filter(metric == metric_to_map)

tx_counties <- tigris::counties(state = "TX", cb = TRUE, class = "sf") %>%
  st_transform(3857) %>%
  select(NAME, GEOID, geometry)

map_df <- tx_counties %>%
  left_join(long, by = c("NAME" = "county"))

# ---- Static map: % change 2014–2024 ----
p_static <- ggplot(map_df) +
  geom_sf(aes(fill = pct_change), color = "white", linewidth = 0.15) +
  coord_sf(datum = NA) +
  scale_fill_gradient2(
    name = "% change\n(2014–2024)",
    low = "#2b6cb0",
    mid = "white",
    high = "#c53030",
    midpoint = 0,
    labels = percent
  ) +
  labs(
    title = paste0("Texas counties: ", metric_to_map),
    subtitle = "Percent change (2014–2024) from provided CSV"
  ) +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "right"
  )

static_out <- file.path(out_dir, paste0("tx_counties_", str_replace_all(tolower(metric_to_map), "[^a-z0-9]+", "_"), "pct_change_2014_2024.png"))
ggsave(static_out, p_static, width = 9, height = 6, dpi = 200)

# ---- 2-frame animation: index 2014 vs 2024 (derived) ----
# NOTE: This is NOT annual data—just a visual before/after using the % change.
index_df <- map_df %>%
  mutate(
    index_2014 = 100,
    index_2024 = 100 * (1 + pct_change)
  ) %>%
  select(NAME, GEOID, geometry, pct_change, index_2014, index_2024) %>%
  pivot_longer(
    cols = c(index_2014, index_2024),
    names_to = "year_label",
    values_to = "index"
  ) %>%
  mutate(
    year = if_else(year_label == "index_2014", 2014L, 2024L)
  )

p_index <- ggplot(index_df) +
  geom_sf(aes(fill = index), color = "white", linewidth = 0.15) +
  coord_sf(datum = NA) +
  scale_fill_viridis_c(name = "Index\n(2014=100)", option = "C", na.value = "grey90") +
  labs(
    title = paste0("Texas counties: ", metric_to_map),
    subtitle = "Index derived from % change in CSV",
    caption = "If you have year-by-year values (2014..2024), we can make a true time animation."
  ) +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "right"
  )

if (has_gganimate && has_gifski) {
  p_anim <- p_index +
    gganimate::transition_states(year, transition_length = 2, state_length = 1) +
    gganimate::labs(subtitle = "Index derived from % change in CSV — year: {closest_state}")

  gif_out <- file.path(out_dir, paste0("tx_counties_", str_replace_all(tolower(metric_to_map), "[^a-z0-9]+", "_"), "index_2014_2024.gif"))
  gganimate::anim_save(
    filename = gif_out,
    animation = gganimate::animate(p_anim, fps = 10, width = 900, height = 600, renderer = gganimate::gifski_renderer())
  )
} else {
  message("Skipping GIF: install.packages(c('gganimate','gifski')) to enable animation output.")
}

message("Wrote: ", static_out)
message("Done.")

