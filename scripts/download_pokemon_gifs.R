# Download Pokemon GIF sprites to local folder
# This script downloads animated GIFs for all Pokemon

library(tidyverse)
library(httr)
library(glue)

# Create output directory
gif_dir <- "assets/sprites/gif"
dir.create(gif_dir, recursive = TRUE, showWarnings = FALSE)

# Load sprite mapping
sprites <- read_csv("data/pokemon_sprites.csv")

cat(glue("Total Pokemon to download: {nrow(sprites)}\n\n"))

# Download function with retry logic
download_gif <- function(url, dest_path, max_retries = 3) {
  if (file.exists(dest_path)) {
    return(list(success = TRUE, message = "Already exists"))
  }

  for (i in 1:max_retries) {
    tryCatch({
      response <- GET(
        url,
        timeout(30),
        user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
      )

      if (status_code(response) == 200) {
        writeBin(content(response, "raw"), dest_path)
        return(list(success = TRUE, message = "Downloaded"))
      } else {
        if (i == max_retries) {
          return(list(success = FALSE, message = glue("HTTP {status_code(response)}")))
        }
      }
    }, error = function(e) {
      if (i == max_retries) {
        return(list(success = FALSE, message = as.character(e$message)))
      }
    })
    Sys.sleep(0.5)  # Wait before retry
  }
  return(list(success = FALSE, message = "Max retries exceeded"))
}

# Generate safe filename from Pokemon name
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

  glue("{base}.gif")
}

# Download all GIFs
results <- tibble(
  dex = character(),
  name = character(),
  filename = character(),
  source = character(),
  success = logical(),
  message = character()
)

# Progress tracking
total <- nrow(sprites)
success_count <- 0
fail_count <- 0

cat("Starting download...\n")
cat("=" |> rep(50) |> paste(collapse = ""), "\n")

for (i in 1:total) {
  row <- sprites[i, ]
  filename <- safe_filename(row$name, row$variant)
  dest_path <- file.path(gif_dir, filename)

  # Try Showdown first (more reliable), then PokemonDB
  sources <- c(
    showdown = row$showdown_gif,
    pokemondb = row$gif_url
  )

  downloaded <- FALSE
  for (source_name in names(sources)) {
    url <- sources[[source_name]]
    result <- download_gif(url, dest_path)

    if (result$success) {
      downloaded <- TRUE
      success_count <- success_count + 1
      results <- bind_rows(results, tibble(
        dex = row$dex,
        name = row$display_name,
        filename = filename,
        source = source_name,
        success = TRUE,
        message = result$message
      ))
      break
    }
  }

  if (!downloaded) {
    fail_count <- fail_count + 1
    results <- bind_rows(results, tibble(
      dex = row$dex,
      name = row$display_name,
      filename = filename,
      source = "none",
      success = FALSE,
      message = "All sources failed"
    ))
  }

  # Progress update every 50 Pokemon
  if (i %% 50 == 0 || i == total) {
    pct <- round(i / total * 100, 1)
    cat(glue("[{i}/{total}] {pct}% - Success: {success_count}, Failed: {fail_count}\n"))
  }

  # Rate limiting
  Sys.sleep(0.1)
}

cat("\n", "=" |> rep(50) |> paste(collapse = ""), "\n")
cat(glue("Download complete!\n"))
cat(glue("  Success: {success_count}\n"))
cat(glue("  Failed: {fail_count}\n"))
cat(glue("  Location: {gif_dir}/\n"))

# Save download log
write_csv(results, "data/pokemon_sprites_download_log.csv")
cat(glue("\nDownload log saved to data/pokemon_sprites_download_log.csv\n"))

# Show failed downloads if any
failed <- results |> filter(!success)
if (nrow(failed) > 0) {
  cat(glue("\n{nrow(failed)} failed downloads:\n"))
  failed |> select(dex, name, message) |> print(n = 20)
}

# Update sprites CSV with local paths
sprites_local <- sprites |>
  mutate(
    local_filename = map2_chr(name, variant, safe_filename),
    local_gif_path = file.path(gif_dir, local_filename)
  )

write_csv(sprites_local, "data/pokemon_sprites.csv")
cat("\nUpdated pokemon_sprites.csv with local paths\n")
