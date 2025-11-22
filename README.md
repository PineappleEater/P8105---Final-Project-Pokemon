# 🎮 The Story and Mystery of Pokémon — Data Science Project

<div align="center">

[![R](https://img.shields.io/badge/R-%3E%3D4.0-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/license-Academic-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-Complete-success.svg)](https://github.com/PineappleEater/P8105---Final-Project-Pokemon)

*A comprehensive data science exploration of Pokémon attributes, battle stats, and design patterns across nine generations*

[Overview](#-overview) • [Dataset](#-dataset) • [Methods](#-methodology) • [Results](#-key-findings) • [Usage](#-installation--usage) • [Team](#-team)

</div>

---

## 📋 Overview

This repository presents a comprehensive data science investigation into the Pokémon universe, analyzing 1,025+ Pokémon species across all nine generations. The project employs modern statistical and machine learning techniques to uncover patterns in Pokémon design, classify legendary Pokémon, and identify distinct battle archetypes.

### 🎯 Project Goals

#### Core Research Questions

1. **Legendary Classification**: Can we build a classifier to identify legendary Pokémon based on their stats?
2. **Physical Attributes Analysis**: How do height and weight correlate with base stats?
3. **Type Effectiveness**: Which type (or type combination) is the strongest/weakest overall?
4. **Type-Legendary Relationship**: Which types are most likely to be legendary Pokémon?
5. **Rating System Development**: Can we create a Pokémon rating system for beginners based on type and stats?

#### Extended Goals

1. **System Validation**: Does the "best" team from our rating system match competitive standards?
2. **Team Building Utility**: Is the rating system reliable and useful as a practical reference?

#### Technical Objectives

- **Data Collection & Cleaning**: Scrape and harmonize Pokémon data from multiple sources
- **Exploratory Analysis**: Investigate distributions, correlations, and evolutionary patterns
- **Dimensionality Reduction**: Apply PCA to understand variance in Pokémon attributes
- **Unsupervised Learning**: Cluster Pokémon into archetypes based on stats and characteristics
- **Supervised Learning**: Build predictive models to classify legendary Pokémon
- **Reproducible Research**: Document all analyses with reproducible R Markdown workflows

### 🎓 Academic Context

- **Course**: P8105 — Data Science I (Columbia University)
- **Timeline**: November – December 2025
- **Final Deliverables**: Analysis reports, trained models, presentation materials

---

## 📊 Dataset

### Data Sources

| Source | Description | URL |
|--------|-------------|-----|
| **Kaggle** | Community-curated Pokémon dataset | [rounakbanik/pokemon](https://www.kaggle.com/datasets/rounakbanik/pokemon) |
| **PokémonDB** | Official stats scraped from web | [pokemondb.net](https://pokemondb.net) |
| **Veekun/PokéAPI** | Metadata & move databases | [GitHub](https://github.com/veekun/pokedex) |

### Dataset Characteristics

- **Species Count**: 1,025 Pokémon (including forms)
- **Generations**: Gen 1–9 (1996–2025)
- **Features**: 30+ attributes including:
  - **Base Stats**: HP, Attack, Defense, Sp. Atk, Sp. Def, Speed
  - **Physical Attributes**: Height (m), Weight (kg), BMI
  - **Categorical**: Type 1, Type 2, Category (Legendary/Mythical/etc.), Generation
  - **Derived Features**: One-hot type encodings, category flags, PCA scores

### Key Variables

| Variable | Type | Description |
|----------|------|-------------|
| `dex` | Integer | National Pokédex number (unique ID) |
| `name` | String | Official species name |
| `type_1` / `type_2` | Categorical | Primary and secondary elemental types |
| `total` | Integer | Base Stat Total (BST) — sum of all stats |
| `hp` ... `speed` | Integer | Individual base stat values (0–255) |
| `height_m` / `weight_kgs` | Numeric | Official dimensions |
| `bmi` | Numeric | Body Mass Index (derived) |
| `is_legendary` | Boolean | Legendary status flag |
| `category` | Factor | Regular / Legendary / Mythical / Paradox / Ultra Beast |
| `generation` | Factor | Gen 1–9 categorical assignment |

---

## 🔬 Methodology

### 1. Data Cleaning & Preprocessing

**File**: `1-finalproject-datacleaning.Rmd`

- Scraped three HTML tables from PokémonDB using `rvest`
- Joined stats, height/weight, and evolution data by Pokédex number
- Handled special cases:
  - **Eternatus Eternamax**: Assigned estimated dimensions (999.9m / 9999.9kg) for lore-accurate representation
  - **Alternate Forms**: Preserved form-specific stats while maintaining unique identifiers
- Exported `pokemon_data.csv` (tidy base dataset)

**Output**: Clean, analysis-ready dataset with 1,025 rows × 14 columns

---

### 2. Exploratory Data Analysis (EDA)

**File**: `2-eda.Rmd`

**Feature Engineering**:
- Created binary flags for special categories (Legendary, Mythical, Paradox, Ultra Beast)
- Assigned generation labels based on Pokédex ranges
- One-hot encoded all 18 Pokémon types
- Calculated dual-type indicator

**Statistical Analyses**:
- Distribution analysis for all numeric features
- Correlation matrix revealing relationships between stats
- Type distribution and combination frequency
- Generation-wise power creep analysis
- Category comparisons (t-tests, ANOVA)

**Key Visualizations**:
- Histograms, density plots, box plots for univariate distributions
- Scatter plots (Attack vs Defense, Height vs Weight on log scale)
- Heatmaps (correlation, type × stat averages)
- Violin plots for category comparisons

**Output**: `pokemon_data_enriched.csv` (30+ features including engineered variables)

---

### 3. PCA & Clustering Analysis

**File**: `3-pca_clustering.Rmd`

#### Principal Component Analysis (PCA)

- **Input Features**: 9 numeric variables (6 base stats + height, weight, BMI)
- **Preprocessing**: Z-score standardization (mean=0, sd=1)
- **Outlier Treatment**: 
  - Detected extreme outliers using IQR method (3× threshold)
  - Removed Pokémon with 3+ outlier flags to improve clustering quality
  - Exported outliers to `pokemon_outliers.csv` for separate analysis
- **Variance Explained**: First 3 PCs capture ~70% of total variance
- **Interpretation**:
  - **PC1**: Overall power / stat total (high loadings on Attack, Sp. Atk, Speed)
  - **PC2**: Physical vs Special orientation (Defense vs Sp. Def trade-offs)
  - **PC3**: HP / bulk dimension

#### Clustering

- **Algorithm**: K-Means clustering
- **Optimal K Determination**:
  - Elbow method (within-cluster sum of squares)
  - Silhouette analysis (cluster cohesion & separation)
  - Gap statistic (comparison to null reference)
  - **Conclusion**: k = 4 clusters optimal

- **Cluster Profiles**:

| Cluster | Label | Avg BST | Characteristics | % Legendary |
|---------|-------|---------|-----------------|-------------|
| 1 | High-Power Sweepers | 580 | High Attack/Sp.Atk/Speed | 35% |
| 2 | Defensive Tanks | 480 | High HP/Defense/Sp.Def | 8% |
| 3 | Balanced All-Rounders | 450 | Moderate across stats | 2% |
| 4 | Low-Power / Early-Game | 320 | Low stats overall | 0% |

- **Validation**: Hierarchical clustering (Ward's method) confirmed similar groupings

**Outputs**: 
- `pokemon_pca_scores.csv` (PC1–PC5 scores)
- `pokemon_clusters.csv` (cluster assignments)
- `pokemon_outliers.csv` (extreme outliers)

---

### 4. Classification Models

**File**: `4-classification_legendary.Rmd`

#### Problem Formulation

- **Task**: Binary classification — predict `is_legendary` (Regular vs Legendary)
- **Class Balance**: ~7% Legendary (imbalanced)
- **Train/Test Split**: 80/20 stratified split
- **Evaluation Metrics**: ROC-AUC (primary), Accuracy, Sensitivity, Specificity, F1-score

#### Models Trained

| Model | Method | Hyperparameters | AUC | Accuracy | F1 |
|-------|--------|-----------------|-----|----------|-----|
| **Logistic Regression** | GLM | Default | 0.985 | 0.94 | 0.85 |
| **Decision Tree** | RPART | cp tuning (10 values) | 0.972 | 0.91 | 0.79 |
| **Random Forest** | RF | mtry ∈ {3,5,7,10}, ntree=500 | 0.992 | 0.96 | 0.90 |
| **RF Tuned** | RF | mtry ∈ {3,5,7,10,15}, ntree=1000, 10-fold CV | **0.995** | **0.97** | **0.92** |
| **XGBoost** | Gradient Boosting | nrounds, max_depth, eta grid search | 0.993 | 0.96 | 0.91 |

#### Feature Importance (Top 5)

1. **Total BST** (Base Stat Total)
2. **Attack**
3. **Sp. Attack**
4. **Speed**
5. **HP**

**Type features** (e.g., `has_dragon`, `has_psychic`) also contributed, confirming certain types are more common among legendaries.

#### Multi-Class Classification

Extended to 5-way classification: Regular / Legendary / Mythical / Paradox / Ultra Beast
- **Model**: Random Forest (mtry=7, ntree=500)
- **Overall Accuracy**: 0.93
- **Kappa**: 0.88 (strong agreement)

**Outputs**: 6 trained models saved to `models/` as `.rds` files

---

## 🏆 Key Findings

### Statistical Insights

1. **Legendary Pokémon are Statistically Distinct**:
   - Mean BST: Legendary (680) vs Regular (420), *p* < 0.001
   - 99% separable by Random Forest classifier

2. **Type Distribution**:
   - Most common types: Water (18%), Normal (15%), Grass (12%)
   - Dragon and Psychic types over-represented among Legendaries (30% vs 5%)

3. **Power Creep Across Generations**:
   - Average BST increased from Gen 1 (435) to Gen 5 (480)
   - Flattened in Gen 6–9 (design stabilization)

4. **Physical Attributes**:
   - Height and weight weakly correlated with stats (r = 0.15)
   - Extreme outlier: **Cosmoem** (BMI = 99,990) — ultra-dense core lore
   - BMI not predictive of battle performance

### Machine Learning Results

5. **Classification Performance**:
   - **Best Model**: Tuned Random Forest (AUC = 0.995)
   - Near-perfect separation of Legendary from Regular Pokémon
   - Feature importance dominated by base stats (not physical attributes)

6. **Clustering Validation**:
   - 4 distinct archetypes identified:
     - Sweepers (high offense/speed)
     - Tanks (high defense/HP)
     - Balanced (jack-of-all-trades)
     - Weak (early-game, unevolved forms)
   - Removing outliers to improved cluster results

### Design Patterns

7. **Legendary Design Philosophy**:
   - Consistently high BST (600–720 range)
   - Often dual-typed (85% vs 45% for regular Pokémon)
   - Concentrated in Dragon, Psychic, Steel, Fairy types

8. **Generation Trends**:
   - Gen 5 introduced most Pokémon (156 species)
   - Gen 8–9 emphasized regional variants and paradox forms

---

## 📁 Repository Structure

```
P8105---Final-Project-Pokemon/
│
├── 📄 README.md                          # This file
├── 📄 finalproject-proposal.Rproj        # RStudio project file
│
├── 📂 data/                              # Raw inputs and generated datasets
│   ├── 📂 raw-data/                      # Scraped HTML inputs from PokémonDB
│   │   ├── Pokemon.html
│   │   ├── Pokemon by height and weight.html
│   │   └── Pokemon fully evolved.html
│   ├── pokemon_data.csv                  # Cleaned base data
│   ├── pokemon_data_enriched.csv         # With engineered features
│   ├── pokemon_pca_scores.csv            # PCA component scores
│   ├── pokemon_clusters.csv              # Cluster assignments
│   └── pokemon_outliers.csv              # Detected outliers
│
├── 📂 models/                            # Trained ML models (.rds)
│   ├── legendary_classifier_logistic.rds
│   ├── legendary_classifier_tree.rds
│   ├── legendary_classifier_rf.rds
│   ├── legendary_classifier_rf_tuned.rds  # ⭐ Best model
│   ├── legendary_classifier_xgboost.rds
│   └── multiclass_classifier_rf.rds
│
├── 📂 reports/                           # HTML analysis reports
│   ├── 1-finalproject-datacleaning.html
│   ├── 2-eda.html
│   ├── 3-pca_clustering.html
│   └── 4-classification_legendary.html
│
├── 📂 proposal/                          # Project planning documents
│   ├── proposal.md
│   ├── proposal.rmd
│   └── proposal.txt
│
└── 📊 Analysis Scripts (R Markdown)
    ├── 1-finalproject-datacleaning.Rmd
    ├── 2-eda.Rmd
    ├── 3-pca_clustering.Rmd
    └── 4-classification_legendary.Rmd
```

---

## 🚀 Installation & Usage

### Prerequisites

- **R** (≥ 4.0.0) — [Download here](https://cran.r-project.org/)
- **RStudio** (recommended) — [Download here](https://posit.co/downloads/)

### Required R Packages

Run this in your R console to install all dependencies:

```r
# Core data manipulation & visualization
install.packages(c("tidyverse", "rvest", "janitor", "knitr", "rmarkdown"))

# EDA & visualization enhancements
install.packages(c("corrplot", "patchwork", "kableExtra", "plotly"))

# PCA & clustering
install.packages(c("factoextra", "FactoMineR", "cluster"))

# Machine learning
install.packages(c("caret", "randomForest", "rpart", "rpart.plot", 
                   "pROC", "xgboost"))
```

### Quick Start

**1. Clone the repository**
```bash
git clone https://github.com/PineappleEater/P8105---Final-Project-Pokemon.git
cd P8105---Final-Project-Pokemon
```

**2. Open in RStudio**
```r
# Double-click finalproject-proposal.Rproj or run:
rstudioapi::openProject("finalproject-proposal.Rproj")
```

**3. Render analyses** (regenerates all outputs)
```r
# Option A: Render all reports sequentially
source_files <- c(
  "1-finalproject-datacleaning.Rmd",
  "2-eda.Rmd",
  "3-pca_clustering.Rmd",
  "4-classification_legendary.Rmd"
)

lapply(source_files, rmarkdown::render)

# Option B: Render individual reports
rmarkdown::render("2-eda.Rmd")  # Example
```

**4. Load pre-trained models**
```r
# Load best classifier
rf_model <- readRDS("models/legendary_classifier_rf_tuned.rds")

# Make predictions on new data
new_pokemon <- data.frame(
  hp = 106, attack = 110, defense = 90,
  sp_atk = 154, sp_def = 90, speed = 130,
  height_m = 1.5, weight_kgs = 52.0, bmi = 23.1,
  # ... (include all type features as 0/1)
)

prediction <- predict(rf_model, new_pokemon, type = "prob")
print(prediction)  # Probability of being Legendary
```

---

## 📈 Reproducibility

All analyses are fully reproducible. The R Markdown files:
- Load raw data from `data/raw-data/` (checked into repo)
- Perform transformations with fixed random seeds
- Export intermediate datasets to `data/`
- Save trained models to `models/`
- Render HTML reports to `reports/`

**Execution time**: ~15 minutes total on standard laptop (2023 specs)

### Computational Environment

```r
sessionInfo()
# R version 4.3.2 (2023-10-31)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
# Running under: Windows 11
```

---

## 📚 Documentation

### HTML Reports

All analyses are documented in interactive HTML reports with:
- Embedded code chunks (foldable)
- High-resolution plots
- Statistical tables
- Interpretive commentary

**View reports**: Open any `.html` file in `reports/` with a web browser.

### Code Style

- Follows [tidyverse style guide](https://style.tidyverse.org/)
- Consistent naming: `snake_case` for variables, `PascalCase` for models
- Commented sections for complex transformations

---

## 🔮 Future Directions

### Potential Extensions

1. **Interactive Dashboard**:
   - Build Shiny app for dynamic exploration
   - Allow users to filter by generation, type, stats
   - Visualize Pokémon in 3D PCA space

2. **Team Building Optimizer**:
   - Genetic algorithm to construct balanced 6-Pokémon teams
   - Maximize type coverage while minimizing weaknesses

3. **Time-Series Analysis**:
   - Model power creep trends with regression
   - Forecast Gen 10 average stats

4. **Deep Learning**:
   - Neural network for multi-output prediction (all stats)
   - Image-based classification using Pokémon sprites

5. **Network Analysis**:
   - Type effectiveness graph (18×18 adjacency matrix)
   - Community detection in Pokémon similarity network

---

## 👥 Team

| Name | UNI | Role |
|------|-----|------|
| **Leah Li** | yl5828 | Data cleaning, EDA lead |
| **Ruipeng Li** | rl3616 | PCA & clustering analysis |
| **Xuange Liang** | xl3493 | Classification modeling |
| **Yiwen Zhang** | yz4994 | Visualization, documentation |

**Contributions**: All team members participated in data collection, proposal writing, and final presentation preparation.

---

## 🙏 Acknowledgements

- **Data Sources**: 
  - Rounak Banik (Kaggle dataset curator)
  - PokémonDB community maintainers
  - Veekun/PokéAPI contributors
  
- **Inspiration**: 
  - Game Freak / Nintendo for creating the Pokémon universe
  - P8105 course staff for project guidance

- **Tools**: 
  - R Core Team and tidyverse developers
  - RStudio / Posit for IDE support

---

## 📄 License & Usage

- **Academic Use**: This project was completed for educational purposes (P8105 coursework)
- **Data Attribution**: Original Pokémon data © Nintendo/Game Freak; used under fair use for academic research
- **Code License**: Not specified — contact authors for reuse permissions
- **Citation**: If using this work, please cite:

  ```
  Li, L., Li, R., Liang, X., & Zhang, Y. (2025). 
  The Story and Mystery of Pokémon: A Data Science Analysis.
  Columbia University P8105 Final Project.
  https://github.com/PineappleEater/P8105---Final-Project-Pokemon
  ```

---

## 📞 Contact

For questions, suggestions, or collaboration inquiries:

- **GitHub Issues**: [Open an issue](https://github.com/PineappleEater/P8105---Final-Project-Pokemon/issues)
- **Email**: Contact team members via UNIs @columbia.edu

---

<div align="center">

**⭐ If you found this project helpful, please consider starring the repository!**

Made with ❤️ and ☕ by the P8105 Pokémon Research Team

</div>
