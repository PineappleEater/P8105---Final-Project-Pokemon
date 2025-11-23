# =============================================================================
# Pokemon Asset Downloader
# =============================================================================
# This script downloads all Pokemon image assets for UI use including:
# - Official artwork (Sugimori art)
# - Animated GIFs (normal & shiny)
# - Pokemon Home 3D renders (normal & shiny)
# - Classic pixel sprites (Gen 1 & Gen 2)
# - Scarlet/Violet icons
# - Type icons
#
# Usage: Rscript scripts/download_pokemon_assets.R
# =============================================================================

library(tidyverse)
library(rvest)
library(httr)
library(glue)

# =============================================================================
# PART 1: Extract Pokemon Sprite URLs from HTML
# =============================================================================

cat("=" |> rep(70) |> paste(collapse = ""), "\n")
cat("POKEMON ASSET DOWNLOADER\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n\n")

# -----------------------------------------------------------------------------
# 1.1 Extract sprite data from Pokemon.html
# -----------------------------------------------------------------------------

extract_sprites_from_html <- function(html_path) {
  html <- read_html(html_path)
  rows <- html |> html_nodes("tr")

  sprites <- map_df(rows, function(row) {
    dex_num <- row |> html_node(".infocard-cell-data") |> html_text()
    name <- row |> html_node(".ent-name") |> html_text()
    variant <- row |> html_node(".text-muted") |> html_text()

    img <- row |> html_node("img.icon-pkmn")
    sprite_url <- if (!is.null(img)) html_attr(img, "src") else NA

    source <- row |> html_node("source")
    avif_url <- if (!is.null(source)) html_attr(source, "srcset") else NA

    if (!is.na(name)) {
      tibble(dex = dex_num, name = name, variant = variant,
             sprite_png = sprite_url, sprite_avif = avif_url)
    } else {
      NULL
    }
  })

  sprites |> filter(!is.na(name))
}

cat("### Step 1: Extracting Pokemon data from HTML ###\n")
pokemon_sprites <- extract_sprites_from_html("data/raw-data/Pokemon.html")
cat(glue("Extracted {nrow(pokemon_sprites)} Pokemon entries\n\n"))

# -----------------------------------------------------------------------------
# 1.2 Generate sprite URLs
# -----------------------------------------------------------------------------

generate_gif_url <- function(name, variant = NA, shiny = FALSE) {
  base_name <- name |>
    str_to_lower() |>
    str_replace_all(" ", "-") |>
    str_replace_all("[\\.']", "") |>
    str_replace_all("♀", "-f") |>
    str_replace_all("♂", "-m") |>
    str_replace_all("é", "e")

  if (!is.na(variant)) {
    if (str_detect(variant, "Mega")) {
      suffix <- case_when(
        str_detect(variant, "X$") ~ "-mega-x",
        str_detect(variant, "Y$") ~ "-mega-y",
        TRUE ~ "-mega"
      )
      base_name <- glue("{base_name}{suffix}")
    } else if (str_detect(variant, "Alolan")) {
      base_name <- glue("{base_name}-alolan")
    } else if (str_detect(variant, "Galarian")) {
      base_name <- glue("{base_name}-galarian")
    } else if (str_detect(variant, "Hisuian")) {
      base_name <- glue("{base_name}-hisuian")
    } else if (str_detect(variant, "Paldean")) {
      base_name <- glue("{base_name}-paldean")
    }
  }

  type <- if (shiny) "shiny" else "normal"
  glue("https://img.pokemondb.net/sprites/black-white/anim/{type}/{base_name}.gif")
}

generate_showdown_url <- function(name, variant = NA, shiny = FALSE) {
  base_name <- name |>
    str_to_lower() |>
    str_replace_all("[ \\.-']", "") |>
    str_replace_all("♀", "f") |>
    str_replace_all("♂", "m") |>
    str_replace_all("é", "e")

  if (!is.na(variant)) {
    if (str_detect(variant, "Mega")) {
      suffix <- case_when(
        str_detect(variant, "X$") ~ "-megax",
        str_detect(variant, "Y$") ~ "-megay",
        TRUE ~ "-mega"
      )
      base_name <- glue("{base_name}{suffix}")
    } else if (str_detect(variant, "Alolan")) {
      base_name <- glue("{base_name}-alola")
    } else if (str_detect(variant, "Galarian")) {
      base_name <- glue("{base_name}-galar")
    } else if (str_detect(variant, "Hisuian")) {
      base_name <- glue("{base_name}-hisui")
    } else if (str_detect(variant, "Paldean")) {
      base_name <- glue("{base_name}-paldea")
    }
  }

  folder <- if (shiny) "ani-shiny" else "ani"
  glue("https://play.pokemonshowdown.com/sprites/{folder}/{base_name}.gif")
}

# Generate all URLs
pokemon_sprites <- pokemon_sprites |>
  mutate(
    gif_url = map2_chr(name, variant, ~generate_gif_url(.x, .y, FALSE)),
    gif_url_shiny = map2_chr(name, variant, ~generate_gif_url(.x, .y, TRUE)),
    showdown_gif = map2_chr(name, variant, ~generate_showdown_url(.x, .y, FALSE)),
    showdown_gif_shiny = map2_chr(name, variant, ~generate_showdown_url(.x, .y, TRUE)),
    display_name = if_else(is.na(variant), name, glue("{name} ({variant})"))
  )

# Save sprite mapping
write_csv(pokemon_sprites, "data/pokemon_sprites.csv")
cat("Saved sprite URL mapping to data/pokemon_sprites.csv\n\n")

# =============================================================================
# PART 2: Download Functions
# =============================================================================

download_image <- function(url, dest_path, max_retries = 2) {
  if (file.exists(dest_path)) {
    return(list(success = TRUE, message = "exists"))
  }

  for (i in 1:max_retries) {
    tryCatch({
      response <- GET(url, timeout(20),
        user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"))

      if (status_code(response) == 200) {
        content_raw <- content(response, "raw")
        if (length(content_raw) > 100) {
          writeBin(content_raw, dest_path)
          return(list(success = TRUE, message = "downloaded"))
        }
      }
      if (i == max_retries) {
        return(list(success = FALSE, message = glue("HTTP {status_code(response)}")))
      }
    }, error = function(e) {
      if (i == max_retries) return(list(success = FALSE, message = "error"))
    })
    Sys.sleep(0.3)
  }
  return(list(success = FALSE, message = "failed"))
}

batch_download <- function(pokemon_df, url_template, output_dir, ext = "png", desc = "images") {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  total <- nrow(pokemon_df)
  success <- 0
  failed <- 0

  cat(glue("\n{'=' |> rep(60) |> paste(collapse = '')}\n"))
  cat(glue("Downloading {desc} to {output_dir}\n"))
  cat(glue("{'=' |> rep(60) |> paste(collapse = '')}\n"))

  for (i in 1:total) {
    row <- pokemon_df[i, ]
    url <- glue(url_template)
    dest <- file.path(output_dir, glue("{row$name_clean}.{ext}"))

    result <- download_image(url, dest)
    if (result$success) success <- success + 1 else failed <- failed + 1

    if (i %% 100 == 0 || i == total) {
      pct <- round(i / total * 100, 1)
      cat(glue("[{i}/{total}] {pct}% - Success: {success}, Failed: {failed}\n"))
    }
    Sys.sleep(0.05)
  }

  cat(glue("Done! Success: {success}, Failed: {failed}\n"))
  return(list(success = success, failed = failed))
}

safe_filename <- function(name, variant) {
  base <- name |>
    str_to_lower() |>
    str_replace_all(" ", "-") |>
    str_replace_all("[^a-z0-9-]", "")

  if (!is.na(variant) && variant != "NA") {
    suffix <- variant |>
      str_to_lower() |>
      str_replace_all(" ", "-") |>
      str_replace_all("[^a-z0-9-]", "")
    base <- glue("{base}-{suffix}")
  }
  base
}

# =============================================================================
# PART 3: Download All Assets
# =============================================================================

# Prepare Pokemon list (unique, without problematic variants)
pokemon_list <- pokemon_sprites |>
  filter(is.na(variant) | variant == "NA") |>
  distinct(dex, name) |>
  mutate(name_clean = name |>
    str_to_lower() |>
    str_replace_all(" ", "-") |>
    str_replace_all("[\\.':,]", "") |>
    str_replace_all("♀", "-f") |>
    str_replace_all("♂", "-m") |>
    str_replace_all("é", "e") |>
    str_replace_all("[^a-z0-9-]", ""))

cat(glue("\n### Step 2: Downloading assets for {nrow(pokemon_list)} Pokemon ###\n"))

# -----------------------------------------------------------------------------
# 3.1 Official Artwork
# -----------------------------------------------------------------------------
cat("\n\n### OFFICIAL ARTWORK ###\n")
batch_download(pokemon_list,
  "https://img.pokemondb.net/artwork/large/{row$name_clean}.jpg",
  "assets/artwork", ext = "jpg", desc = "official artwork")

# -----------------------------------------------------------------------------
# 3.2 Animated GIFs (Normal)
# -----------------------------------------------------------------------------
cat("\n\n### ANIMATED GIFS ###\n")

gif_dir <- "assets/sprites/gif"
dir.create(gif_dir, recursive = TRUE, showWarnings = FALSE)

total <- nrow(pokemon_sprites)
success <- 0
failed <- 0

cat(glue("Downloading animated GIFs to {gif_dir}\n"))

for (i in 1:total) {
  row <- pokemon_sprites[i, ]
  filename <- safe_filename(row$name, row$variant)
  dest_path <- file.path(gif_dir, glue("{filename}.gif"))

  # Try Showdown first, then PokemonDB
  result <- download_image(row$showdown_gif, dest_path)
  if (!result$success) {
    result <- download_image(row$gif_url, dest_path)
  }

  if (result$success) success <- success + 1 else failed <- failed + 1

  if (i %% 100 == 0 || i == total) {
    cat(glue("[{i}/{total}] {round(i/total*100,1)}% - Success: {success}, Failed: {failed}\n"))
  }
  Sys.sleep(0.05)
}

# -----------------------------------------------------------------------------
# 3.3 Shiny Animated GIFs
# -----------------------------------------------------------------------------
cat("\n\n### SHINY ANIMATED GIFS ###\n")
batch_download(pokemon_list,
  "https://play.pokemonshowdown.com/sprites/ani-shiny/{row$name_clean}.gif",
  "assets/sprites/gif-shiny", ext = "gif", desc = "shiny animated GIFs")

# -----------------------------------------------------------------------------
# 3.4 Pokemon Home 3D Renders
# -----------------------------------------------------------------------------
cat("\n\n### POKEMON HOME 3D RENDERS ###\n")
batch_download(pokemon_list,
  "https://img.pokemondb.net/sprites/home/normal/{row$name_clean}.png",
  "assets/sprites/home", ext = "png", desc = "Pokemon Home renders")

# -----------------------------------------------------------------------------
# 3.5 Pokemon Home Shiny Renders
# -----------------------------------------------------------------------------
cat("\n\n### POKEMON HOME SHINY RENDERS ###\n")
batch_download(pokemon_list,
  "https://img.pokemondb.net/sprites/home/shiny/{row$name_clean}.png",
  "assets/sprites/home-shiny", ext = "png", desc = "Pokemon Home shiny renders")

# -----------------------------------------------------------------------------
# 3.6 Classic Gen 1 Sprites
# -----------------------------------------------------------------------------
cat("\n\n### CLASSIC GEN 1 SPRITES ###\n")
gen1_pokemon <- pokemon_list |> filter(as.numeric(dex) <= 151)
batch_download(gen1_pokemon,
  "https://img.pokemondb.net/sprites/red-blue/normal/{row$name_clean}.png",
  "assets/sprites/gen1-classic", ext = "png", desc = "Gen 1 classic sprites")

# -----------------------------------------------------------------------------
# 3.7 Gen 2 Crystal Sprites
# -----------------------------------------------------------------------------
cat("\n\n### GEN 2 CRYSTAL SPRITES ###\n")
gen2_pokemon <- pokemon_list |> filter(as.numeric(dex) <= 251)
batch_download(gen2_pokemon,
  "https://img.pokemondb.net/sprites/crystal/normal/{row$name_clean}.png",
  "assets/sprites/gen2-crystal", ext = "png", desc = "Gen 2 Crystal sprites")

# -----------------------------------------------------------------------------
# 3.8 Scarlet/Violet Icons
# -----------------------------------------------------------------------------
cat("\n\n### SCARLET/VIOLET ICONS ###\n")
batch_download(pokemon_list,
  "https://img.pokemondb.net/sprites/scarlet-violet/icon/{row$name_clean}.png",
  "assets/sprites/sv-icons", ext = "png", desc = "Scarlet/Violet icons")

# -----------------------------------------------------------------------------
# 3.9 Type Icons
# -----------------------------------------------------------------------------
cat("\n\n### TYPE ICONS ###\n")

type_dir <- "assets/icons/types"
dir.create(type_dir, recursive = TRUE, showWarnings = FALSE)

types <- c(normal=1, fighting=2, flying=3, poison=4, ground=5, rock=6,
           bug=7, ghost=8, steel=9, fire=10, water=11, grass=12,
           electric=13, psychic=14, ice=15, dragon=16, dark=17, fairy=18)

cat("Downloading type icons from PokeAPI...\n")
for (type_name in names(types)) {
  type_id <- types[[type_name]]
  url <- glue("https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/{type_id}.png")
  dest <- file.path(type_dir, glue("{type_name}.png"))
  result <- download_image(url, dest)
  cat(glue("  {type_name}: {result$message}\n"))
  Sys.sleep(0.1)
}

# =============================================================================
# PART 4: Summary
# =============================================================================

cat("\n\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n")
cat("DOWNLOAD COMPLETE!\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n\n")

cat("Asset folders:\n")
asset_dirs <- c(
  "assets/artwork",
  "assets/sprites/gif",
  "assets/sprites/gif-shiny",
  "assets/sprites/home",
  "assets/sprites/home-shiny",
  "assets/sprites/gen1-classic",
  "assets/sprites/gen2-crystal",
  "assets/sprites/sv-icons",
  "assets/icons/types"
)

for (d in asset_dirs) {
  if (dir.exists(d)) {
    n_files <- length(list.files(d, pattern = "\\.(png|jpg|gif)$"))
    cat(glue("  {d}: {n_files} files\n"))
  }
}

cat("\nAll assets ready for UI use!\n")
