# The Story and Mystery of Pokémon — Data Science Project

<div align="center">

<!-- Hero Banner with animated GIFs - varying sizes for visual hierarchy -->
<img src="assets/sprites/gif/pichu.gif" width="50" alt="Pichu">
<img src="assets/sprites/gif/togepi.gif" width="55" alt="Togepi">
<img src="assets/sprites/gif/eevee.gif" width="65" alt="Eevee">
<img src="assets/sprites/gif/charizard.gif" width="100" alt="Charizard">
<img src="assets/sprites/gif/pikachu.gif" width="85" alt="Pikachu">
<!-- <img src="assets/sprites/gif/rayquaza.gif" width="110" alt="Rayquaza"> -->
<!-- <img src="assets/sprites/gif/lucario.gif" width="80" alt="Lucario">
<img src="assets/sprites/gif/garchomp.gif" width="90" alt="Garchomp"> -->
<img src="assets/sprites/gif/gengar.gif" width="70" alt="Gengar">
<img src="assets/sprites/gif/dragonite.gif" width="55" alt="Dragonite">
<img src="assets/sprites/gif/jigglypuff.gif" width="55" alt="Jigglypuff">
<img src="assets/sprites/gif/mew.gif" width="45" alt="Mew">
<img src="assets/sprites/gif/mewtwo.gif" width="95" alt="Mewtwo">


<br>

[![R](https://img.shields.io/badge/R-%3E%3D4.0-276DC3?style=for-the-badge&logo=r&logoColor=white)](https://www.r-project.org/)
[![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)](https://github.com/PineappleEater/P8105---Final-Project-Pokemon)
[![License](https://img.shields.io/badge/License-Academic-blue?style=for-the-badge)](LICENSE)

*A comprehensive data science exploration of Pokémon attributes, battle stats, and design patterns across nine generations*

[Overview](#overview) · [Dataset](#dataset) · [Methods](#methodology) · [Results](#key-findings) · [Usage](#installation--usage) · [Team](#team)

</div>

---

## Overview

<img align="right" src="assets/sprites/gif/bulbasaur.gif" width="90" alt="Bulbasaur">
<img align="right" src="assets/sprites/gif/charmander.gif" width="75" alt="Charmander">
<img align="right" src="assets/sprites/gif/squirtle.gif" width="70" alt="Squirtle">

This repository presents a comprehensive data science investigation into the Pokémon universe, analyzing **1,025+ Pokémon species** across all nine generations. The project employs modern statistical and machine learning techniques to uncover patterns in Pokémon design, classify legendary Pokémon, and identify distinct battle archetypes.

<br clear="right">

### Project Goals

**Core Research Questions**

1. **Legendary Classification**: Can we build a classifier to identify legendary Pokémon based on their stats?
2. **Physical Attributes Analysis**: How do height and weight correlate with base stats?
3. **Type Effectiveness**: Which type (or type combination) is the strongest/weakest overall?
4. **Type-Legendary Relationship**: Which types are most likely to be legendary Pokémon?
5. **Rating System Development**: Can we create a Pokémon rating system for beginners based on type and stats?

### Academic Context

- **Course**: P8105 — Data Science I (Columbia University)
- **Timeline**: November – December 2025
- **Final Deliverables**: Analysis reports, trained models, presentation materials

---

## Dataset

### Data Sources

| Source | Description | URL |
|--------|-------------|-----|
| **Kaggle** | Community-curated Pokémon dataset | [rounakbanik/pokemon](https://www.kaggle.com/datasets/rounakbanik/pokemon) |
| **PokémonDB** | Official stats scraped from web | [pokemondb.net](https://pokemondb.net) |
| **Veekun/PokéAPI** | Metadata & move databases | [GitHub](https://github.com/veekun/pokedex) |

### Dataset Overview

<div align="center">

| Metric | Value |
|--------|-------|
| **Species Count** | 1,025 Pokémon |
| **Generations** | Gen 1–9 (1996–2025) |
| **Features** | 30+ attributes |

</div>

### 18 Pokémon Types

<div align="center">

<img src="assets/icons/types/normal.png" height="28" alt="Normal">
<img src="assets/icons/types/fire.png" height="28" alt="Fire">
<img src="assets/icons/types/water.png" height="28" alt="Water">
<img src="assets/icons/types/electric.png" height="28" alt="Electric">
<img src="assets/icons/types/grass.png" height="28" alt="Grass">
<img src="assets/icons/types/ice.png" height="28" alt="Ice">
<img src="assets/icons/types/fighting.png" height="28" alt="Fighting">
<img src="assets/icons/types/poison.png" height="28" alt="Poison">
<img src="assets/icons/types/ground.png" height="28" alt="Ground">
<img src="assets/icons/types/flying.png" height="28" alt="Flying">
<img src="assets/icons/types/psychic.png" height="28" alt="Psychic">
<img src="assets/icons/types/bug.png" height="28" alt="Bug">
<img src="assets/icons/types/rock.png" height="28" alt="Rock">
<img src="assets/icons/types/ghost.png" height="28" alt="Ghost">
<img src="assets/icons/types/dragon.png" height="28" alt="Dragon">
<img src="assets/icons/types/dark.png" height="28" alt="Dark">
<img src="assets/icons/types/steel.png" height="28" alt="Steel">
<img src="assets/icons/types/fairy.png" height="28" alt="Fairy">

</div>

### Key Variables

| Variable | Type | Description |
|----------|------|-------------|
| `dex` | Integer | National Pokédex number |
| `name` | String | Official species name |
| `type_1` / `type_2` | Categorical | Primary and secondary types |
| `total` | Integer | Base Stat Total (BST) |
| `hp` ... `speed` | Integer | Individual base stats |
| `is_legendary` | Boolean | Legendary status flag |
| `category` | Factor | Regular / Legendary / Mythical / Paradox / Ultra Beast |

---

## Methodology

### Analysis Pipeline

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  1. Data Clean  │───▶│    2. EDA       │───▶│  3. PCA/Cluster │
│   (rvest)       │    │  (tidyverse)    │    │  (factoextra)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                      │
┌─────────────────┐    ┌─────────────────┐           │
│ 5. Type Rating  │◀───│ 4. ML Classify  │◀──────────┘
│   System        │    │ (Random Forest) │
└─────────────────┘    └─────────────────┘
```

### 1. Data Cleaning & Preprocessing

<img align="right" src="assets/sprites/gif/porygon.gif" width="65" alt="Porygon">

**File**: `1-datacleaning.Rmd`

- Scraped three HTML tables from PokémonDB using `rvest`
- Joined stats, height/weight, and evolution data
- Handled special cases (Eternamax, alternate forms)
- **Output**: `pokemon_data.csv` (1,025 rows × 14 columns)

### 2. Exploratory Data Analysis

<img align="right" src="assets/sprites/gif/magnezone.gif" width="75" alt="Magnezone">

**File**: `2-eda.Rmd`

- Feature engineering (binary flags, generation labels)
- One-hot encoded all 18 types
- Correlation analysis & distribution plots
- **Output**: `pokemon_data_enriched.csv` (30+ features)

### 3. PCA & Clustering Analysis

<img align="right" src="assets/sprites/gif/alakazam.gif" width="80" alt="Alakazam">

**File**: `3-pca_clustering.Rmd`

- Principal Component Analysis on 9 numeric features
- K-Means clustering (k=4 optimal)
- **Variance Explained**: First 3 PCs capture ~70%

**Cluster Profiles**:

| Cluster | Label | Avg BST | % Legendary |
|---------|-------|---------|-------------|
| 1 | High-Power Sweepers | 580 | 35% |
| 2 | Defensive Tanks | 480 | 8% |
| 3 | Balanced All-Rounders | 450 | 2% |
| 4 | Low-Power / Early-Game | 320 | 0% |

### 4. Classification Models

<img align="right" src="assets/sprites/gif/mewtwo.gif" width="85" alt="Mewtwo">

**File**: `4-classification_legendary.Rmd`

**Task**: Binary classification — predict `is_legendary`

| Model | AUC | Accuracy | F1 |
|-------|-----|----------|-----|
| Logistic Regression | 0.985 | 0.94 | 0.85 |
| Decision Tree | 0.972 | 0.91 | 0.79 |
| Random Forest | 0.992 | 0.96 | 0.90 |
| **RF Tuned** | **0.995** | **0.97** | **0.92** |

### 5. Type Effectiveness & Rating System

<img align="right" src="assets/sprites/gif/tyranitar.gif" width="90" alt="Tyranitar">

**File**: `5-type_analysis_rating.Rmd`

- Attack & defense type analysis
- Beginner-friendly rating system
- Team building recommendations

---

## Key Findings

### Legendary Pokémon

<div align="center">

<img src="assets/sprites/gif/articuno.gif" width="70" alt="Articuno">
<img src="assets/sprites/gif/zapdos.gif" width="75" alt="Zapdos">
<img src="assets/sprites/gif/moltres.gif" width="80" alt="Moltres">
<img src="assets/sprites/gif/lugia.gif" width="100" alt="Lugia">
<img src="assets/sprites/gif/ho-oh.gif" width="95" alt="Ho-Oh">
<img src="assets/sprites/gif/dialga.gif" width="90" alt="Dialga">
<img src="assets/sprites/gif/palkia.gif" width="90" alt="Palkia">

</div>

1. **Statistically Distinct**: Mean BST Legendary (680) vs Regular (420), *p* < 0.001
2. **99% Separable** by Random Forest classifier
3. **Type Concentration**: Dragon & Psychic over-represented (30% vs 5%)

### Type Distribution

| Most Common | Legendary Favorites |
|-------------|---------------------|
| Water (18%) | Dragon (30%) |
| Normal (15%) | Psychic (25%) |
| Grass (12%) | Steel (20%) |

### Machine Learning Results

- **Best Model**: Tuned Random Forest (AUC = 0.995)
- **Top Features**: Total BST, Attack, Sp. Attack, Speed, HP

---

## Repository Structure

```
P8105---Final-Project-Pokemon/
│
├── data/                    # Datasets
│   ├── raw-data/            # Scraped HTML inputs
│   ├── analysis/            # Analysis outputs (PCA, clustering, type)
│   └── *.csv                # Processed datasets
│
├── models/                  # Trained ML models (.rds)
│   └── legendary_classifier_rf_tuned.rds  # Best model
│
├── reports/                 # HTML analysis reports
│
├── assets/                  # Image assets for UI
│   ├── artwork/             # Official artwork (978 files)
│   ├── sprites/
│   │   ├── gif/             # Animated GIFs (1,176 files)
│   │   ├── gif-shiny/       # Shiny GIFs (941 files)
│   │   ├── home/            # Pokemon Home 3D (982 files)
│   │   ├── home-shiny/      # Pokemon Home Shiny (982 files)
│   │   ├── gen1-classic/    # Gen 1 pixel sprites (149 files)
│   │   ├── gen2-crystal/    # Gen 2 Crystal sprites (249 files)
│   │   └── sv-icons/        # Scarlet/Violet icons (982 files)
│   └── icons/types/         # 18 type icons
│
├── scripts/
│   └── download_pokemon_assets.R  # Asset downloader
│
└── *.Rmd                    # Analysis notebooks
```

---

## Installation & Usage

### Prerequisites

- **R** (≥ 4.0.0) — [Download](https://cran.r-project.org/)
- **RStudio** — [Download](https://posit.co/downloads/)

### Required Packages

```r
install.packages(c(
  "tidyverse", "rvest", "janitor", "knitr", "rmarkdown",
  "corrplot", "patchwork", "kableExtra", "plotly",
  "factoextra", "FactoMineR", "cluster",
  "caret", "randomForest", "rpart", "pROC"
))
```

### Quick Start

```bash
# Clone repository
git clone https://github.com/PineappleEater/P8105---Final-Project-Pokemon.git
cd P8105---Final-Project-Pokemon

# Open in RStudio and render analyses
```

### Download Assets (Optional)

```r
source("scripts/download_pokemon_assets.R")
```

---

## Team

<div align="center">

| Name | UNI | Role |
|------|-----|------|
| **Leah Li** | yl5828 | Data cleaning, EDA lead |
| **Ruipeng Li** | rl3616 | PCA & clustering analysis |
| **Xuange Liang** | xl3493 | Classification modeling |
| **Yiwen Zhang** | yz4994 | Visualization, documentation |

</div>

---

## Acknowledgements

- **Data Sources**: Rounak Banik (Kaggle), PokémonDB, Veekun/PokéAPI
- **Inspiration**: Game Freak / Nintendo, P8105 course staff
- **Tools**: R Core Team, tidyverse developers, RStudio

---

## License & Citation

**Academic Use**: This project was completed for educational purposes (P8105 coursework)

**Citation**:

```
Li, L., Li, R., Liang, X., & Zhang, Y. (2025).
The Story and Mystery of Pokémon: A Data Science Analysis.
Columbia University P8105 Final Project.
https://github.com/PineappleEater/P8105---Final-Project-Pokemon
```

---

<div align="center">

<!-- Eeveelutions with animated GIFs - varying sizes -->
<img src="assets/sprites/gif/eevee.gif" width="65" alt="Eevee">
<img src="assets/sprites/gif/vaporeon.gif" width="80" alt="Vaporeon">
<img src="assets/sprites/gif/jolteon.gif" width="75" alt="Jolteon">
<img src="assets/sprites/gif/flareon.gif" width="78" alt="Flareon">
<img src="assets/sprites/gif/espeon.gif" width="73" alt="Espeon">
<img src="assets/sprites/gif/umbreon.gif" width="72" alt="Umbreon">
<img src="assets/sprites/gif/leafeon.gif" width="70" alt="Leafeon">
<img src="assets/sprites/gif/glaceon.gif" width="74" alt="Glaceon">
<img src="assets/sprites/gif/sylveon.gif" width="60" alt="Sylveon">

<br><br>
**If you found this project helpful, please consider starring the repository!**

Made with ❤️ by the P8105 Pokémon Research Team

*Gotta Analyze 'Em All!*

</div>
