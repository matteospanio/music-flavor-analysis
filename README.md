# Sonic Seasoning – Statistical Analysis

Statistical analysis for the study *"Musica e Gusto"* (Music and Taste), which
investigates the relationship between the gustatory metadata assigned to music
tracks by a sonic-seasoning recommendation system and the taste perceptions
reported by participants.

**Authors:** Valentina Frezzato, Matteo Spanio — University of Padova,
Department of Information Engineering

---

## Study Design

- **Participants:** 49 (no zero-variance responses removed)
- **Stimuli:** 20 music tracks; each participant rated 10 randomly assigned tracks
- **Taste dimensions:** salty, sweet, sour, bitter, spicy (5-dimensional Likert
  scale 1–7)
- **Target vectors:** gustatory metadata associated with each track by the
  recommendation system, used as ground truth

Each track has an associated ground-truth target vector
**t**_i = (salty, sweet, sour, bitter, spicy), and each participant provides a
perceptual vector **p**_ij for every track they hear.

---

## Analysis Pipeline

The full analysis is in `music-flavor-analysis.qmd`.

1. **Pre-processing** – Reshape to long format; remove participants with
   zero-variance responses; z-score normalisation of both perceptual ratings
   and target vectors (per dimension).

2. **Descriptive statistics** – Distributions per taste dimension and per
   track; no floor/ceiling effects detected; rating counts per track are
   moderately unbalanced.

3. **PCA of target vectors** – Sweet is anti-correlated with salty/spicy;
   bitter and sour co-vary; salty and spicy are aligned.

4. **Mean perceptual vectors** – Per-track mean z-score rating across
   participants; structure qualitatively consistent with the target space.

5. **Euclidean distances** – Per-track distance d_i between mean perceptual
   vector and corresponding target vector; weighted and unweighted means
   are virtually identical, confirming robustness to rating-count imbalance.

6. **Structural consistency (secondary)**
   - *Mantel test* (Pearson, 9 999 permutations): significant positive
     correlation between the 20×20 target and perceptual distance matrices.
   - *Procrustes analysis / PROTEST* (9 999 permutations): significant but
     imperfect alignment after optimal rotation and scaling.

7. **Main test – permutation test on mean vector distance** (10 000
   permutations): target–percept assignments are shuffled; the observed mean
   distance is compared against the null distribution.

8. **Effect size** – z-score of the observed mean distance relative to the null
   distribution.

---

## Key Results

| Test | Result |
|------|--------|
| Permutation test (main) | p << 0.001 — observed mean distance falls in the extreme left tail of the null distribution |
| Effect size (z) | Large — observed distance is several SDs below the null mean |
| Mantel test | Significant positive correlation between distance matrices |
| Procrustes (PROTEST) | Significant but moderate structural alignment |
| Diagonal matches | Partial — several tracks (e.g. budino, cioccolato al latte, diavola, radicchio, tè verde, tiramisù) show the minimum distance to their own target; mismatches occur mainly between tracks with similar gustatory profiles |

The observed mean distance between mean perceptual vectors and target vectors is
significantly smaller than expected under random association. The gustatory
metadata capture global regularities in the perceptual space, though one-to-one
correspondence at the individual track level is limited.

---

## Power Analysis

`scripts/power_analysis.R` runs a simulation-based power analysis for the
secondary linear mixed-effects model (LMM):

```
perceived ~ target + (1 | subject) + (1 | track)
```

**Parameters assumed:**

| Parameter | Value |
|-----------|-------|
| β_target | 0.15 |
| SD_subject | 1.2 |
| SD_track | 1.0 |
| SD_residual | 1.5 |
| α | 0.05 |

Two analyses are produced:

1. **Power vs. sample size** (`power_analysis_sample_size.png`) – sample sizes
   from 20 to 120 subjects (step 10); the 80% power threshold is marked.
2. **Power vs. random-effect variances** (`power_analysis_variance_heatmap.png`)
   – heatmap of power at N = 50 subjects across a grid of SD_subject ×
   SD_track values (0.2–2.0).

Parallel execution uses `furrr` (8 cores by default); set `n_cores` in the
script to match your hardware.

---

## Reproducing the Analysis

### Requirements

- R ≥ 4.5 with `renv` (dependencies are locked in `renv.lock`)
- Quarto ≥ 1.4 (for the notebook)

### Setup

```r
renv::restore()   # install locked packages
```

### Render the notebook

```bash
quarto render music-flavor-analysis.qmd
```

### Run the power analysis

```r
source("scripts/power_analysis.R")
```

### Data

| File | Description |
|------|-------------|
| `data/data.csv` | Raw participant ratings (long form after cleaning) |
| `data/target_vectors.xlsx` | Gustatory target vectors for the 20 tracks |
