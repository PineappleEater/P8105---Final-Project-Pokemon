# Extract Pokemon GIF URLs for UI
# This script generates a mapping of Pokemon names to their animated GIF sprites

library(tidyverse)
library(rvest)
library(glue)

# =============================================================================
# Method 1: Extract from HTML files (static icons)
# =============================================================================

extract_sprites_from_html <- function(html_path) {
  html <- read_html(html_path)

  # Extract all Pokemon entries
  rows <- html |> html_nodes("tr")

  sprites <- map_df(rows, function(row) {
    # Get Pokemon number
    dex_num <- row |> html_node(".infocard-cell-data") |> html_text()

    # Get Pokemon name
    name <- row |> html_node(".ent-name") |> html_text()

    # Get variant name if exists (e.g., "Mega Venusaur")
    variant <- row |> html_node(".text-muted") |> html_text()

    # Get sprite URL (PNG)
    img <- row |> html_node("img.icon-pkmn")
    sprite_url <- if (!is.null(img)) html_attr(img, "src") else NA

    # Get AVIF URL
    source <- row |> html_node("source")
    avif_url <- if (!is.null(source)) html_attr(source, "srcset") else NA

    if (!is.na(name)) {
      tibble(
        dex = dex_num,
        name = name,
        variant = variant,
        sprite_png = sprite_url,
        sprite_avif = avif_url
      )
    } else {
      NULL
    }
  })

  sprites |> filter(!is.na(name))
}

# Extract from Pokemon.html
pokemon_sprites <- extract_sprites_from_html("data/raw-data/Pokemon.html")

cat(glue("Extracted {nrow(pokemon_sprites)} Pokemon sprites from HTML\n\n"))

# =============================================================================
# Method 2: Generate animated GIF URLs based on naming convention
# =============================================================================

# PokemonDB animated sprite URL pattern:
# https://img.pokemondb.net/sprites/black-white/anim/normal/{name}.gif
# https://img.pokemondb.net/sprites/black-white/anim/shiny/{name}.gif

generate_gif_url <- function(name, variant = NA, shiny = FALSE) {
  # Convert name to URL-friendly format
  base_name <- name |>
    str_to_lower() |>
    str_replace_all(" ", "-") |>
    str_replace_all("\\.", "") |>
    str_replace_all("'", "") |>
    str_replace_all("♀", "-f") |>
    str_replace_all("♂", "-m") |>
    str_replace_all("é", "e")

  # Handle variants
  if (!is.na(variant)) {
    variant_suffix <- variant |>
      str_to_lower() |>
      str_replace_all(" ", "-") |>
      str_replace("mega-", "mega-") |>
      str_replace("alolan-", "alolan-") |>
      str_replace("galarian-", "galarian-") |>
      str_replace("hisuian-", "hisuian-") |>
      str_replace("paldean-", "paldean-")

    # Construct variant name based on common patterns
    if (str_detect(variant, "Mega")) {
      if (str_detect(variant, "X$")) {
        base_name <- glue("{base_name}-mega-x")
      } else if (str_detect(variant, "Y$")) {
        base_name <- glue("{base_name}-mega-y")
      } else {
        base_name <- glue("{base_name}-mega")
      }
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

# Generate GIF URLs for all Pokemon
pokemon_gifs <- pokemon_sprites |>
  mutate(
    gif_url = map2_chr(name, variant, ~generate_gif_url(.x, .y, shiny = FALSE)),
    gif_url_shiny = map2_chr(name, variant, ~generate_gif_url(.x, .y, shiny = TRUE))
  )

# =============================================================================
# Method 3: Alternative sprite sources (higher quality)
# =============================================================================

# Pokemon Showdown sprites (commonly used, reliable)
# https://play.pokemonshowdown.com/sprites/ani/{name}.gif
# https://play.pokemonshowdown.com/sprites/ani-shiny/{name}.gif

generate_showdown_url <- function(name, variant = NA, shiny = FALSE) {
  base_name <- name |>
    str_to_lower() |>
    str_replace_all(" ", "") |>
    str_replace_all("\\.", "") |>
    str_replace_all("'", "") |>
    str_replace_all("-", "") |>
    str_replace_all("♀", "f") |>
    str_replace_all("♂", "m") |>
    str_replace_all("é", "e")

  # Handle variants for Showdown format
  if (!is.na(variant)) {
    if (str_detect(variant, "Mega")) {
      if (str_detect(variant, "X$")) {
        base_name <- glue("{base_name}-megax")
      } else if (str_detect(variant, "Y$")) {
        base_name <- glue("{base_name}-megay")
      } else {
        base_name <- glue("{base_name}-mega")
      }
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

# Add Showdown URLs
pokemon_gifs <- pokemon_gifs |>
  mutate(
    showdown_gif = map2_chr(name, variant, ~generate_showdown_url(.x, .y, shiny = FALSE)),
    showdown_gif_shiny = map2_chr(name, variant, ~generate_showdown_url(.x, .y, shiny = TRUE))
  )

# =============================================================================
# Save the sprite mapping
# =============================================================================

# Create full display name
pokemon_gifs <- pokemon_gifs |>
  mutate(
    display_name = if_else(
      is.na(variant),
      name,
      glue("{name} ({variant})")
    )
  )

# Select final columns
pokemon_sprite_map <- pokemon_gifs |>
  select(
    dex,
    name,
    variant,
    display_name,
    sprite_png,
    sprite_avif,
    gif_url,
    gif_url_shiny,
    showdown_gif,
    showdown_gif_shiny
  )

# Save to CSV
write_csv(pokemon_sprite_map, "data/pokemon_sprites.csv")
cat(glue("Saved sprite mapping to data/pokemon_sprites.csv\n"))

# =============================================================================
# Preview
# =============================================================================

cat("\n=== Sample Sprite URLs ===\n")
pokemon_sprite_map |>
  head(10) |>
  select(display_name, gif_url, showdown_gif) |>
  print()

# Summary
cat(glue("\n\nTotal Pokemon with sprites: {nrow(pokemon_sprite_map)}\n"))
cat("Available sprite formats:\n")
cat("  - sprite_png: Static PNG icons from Scarlet/Violet\n")
cat("  - sprite_avif: High-quality AVIF format icons\n")
cat("  - gif_url: Animated GIF from PokemonDB (Black/White style)\n")
cat("  - gif_url_shiny: Shiny variant animated GIF\n")
cat("  - showdown_gif: Animated GIF from Pokemon Showdown\n")
cat("  - showdown_gif_shiny: Shiny variant from Pokemon Showdown\n")
