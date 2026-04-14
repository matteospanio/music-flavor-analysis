# Cross-Modal Music-Flavor Correspondences

[![arXiv](https://img.shields.io/badge/arXiv-2604.10632-b31b1b.svg)](https://arxiv.org/abs/2604.10632)

Companion code and analysis notebooks for the paper:

> **Multimodal Dataset Normalization and Perceptual Validation for Music-Taste Correspondences**
> Matteo Spanio, Valentina Frezzato, Antonio Roda — University of Padova

The rendered notebooks are available at **[CSCPadova.github.io/music-flavor-analysis](https://CSCPadova.github.io/music-flavor-analysis)**.

## Data

Datasets are archived on Zenodo:

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19259231.svg)](https://doi.org/10.5281/zenodo.19259231)

Download the data files and place them in the `data/` directory before running the notebooks.

| File | Description |
|------|-------------|
| `data/data.csv` | Raw participant ratings (one row per participant x track x dimension) |
| `data/target_vectors.xlsx` | Ground-truth 5D gustatory target vectors for each of the 20 tracks |
| `data/small_processed.csv` | Small dataset (257 tracks, human-annotated flavor ratings) |
| `data/train_processed.csv` | FMA training split (~44K segments, AST-generated flavor labels) |
| `data/validation_processed.csv` | FMA validation split (~5K segments) |
| `data/genres.csv` | FMA genre taxonomy (id, title, parent, top_level) |
| `data/food_taste_vectors.csv` | FooDB foods with 6D taste vectors (sweet, bitter, sour, salty, spicy, umami) |
| `data/foodb_compound_fart_classifications.json` | FART taste predictions for ~70K FooDB compounds |
| `data/nutrients_flavor.json` | Nutrient-to-taste mappings (37 entries) |
| `data/foodb_foods.csv` | FooDB food metadata (id, name, food_group; 992 rows) |

## Notebooks

The project is a [Quarto](https://quarto.org) book with four analysis chapters:

1. **Cross-Modal Dataset Analysis** (`notebooks/01-cross-modal-analysis.qmd`, Python) — Correlation transfer, feature importance, latent factor structure, and text-flavor correspondences across human-annotated and AST-labeled corpora.
2. **Taste Vector Construction** (`notebooks/02-taste-vectors.qmd`, Python) — Pipeline from FooDB compound concentrations through FART taste classification to 20 experimental target vectors.
3. **Power Analysis** (`notebooks/03-power-analysis.qmd`, R) — Simulation-based power analysis for the perceptual validation LMM.
4. **Perceptual Experiment** (`notebooks/04-perceptual-experiment.qmd`, R) — Perceptual validation with 49 participants: z-score normalization, permutation test, Mantel correlation, Procrustes analysis.

## Setup

### Python (Chapters 1-2)

Requires Python 3.12+ and [uv](https://docs.astral.sh/uv/):

```bash
uv sync
```

### R (Chapters 3-4)

Requires R 4.5+ with `renv`:

```r
renv::restore()
```

### Render the book

```bash
quarto render
```

The rendered site is written to `_output/`.

## License

Code is released under the [MIT License](LICENSE). Datasets are subject to their respective licenses as described on Zenodo.

## Citation

If you use this code or data, please cite:

```bibtex
@misc{spanio2026multimodaldatasetnormalizationperceptual,
      title={Multimodal Dataset Normalization and Perceptual Validation for Music-Taste Correspondences}, 
      author={Matteo Spanio and Valentina Frezzato and Antonio Rodà},
      year={2026},
      eprint={2604.10632},
      archivePrefix={arXiv},
      primaryClass={cs.SD},
      url={https://arxiv.org/abs/2604.10632}, 
}
```
