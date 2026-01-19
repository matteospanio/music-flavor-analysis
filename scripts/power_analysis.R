# ============================================================
# POWER ANALYSIS SIMULATA PER LMM (PARALLELIZED)
# ============================================================

# -----------------------------
# 1. LIBRERIE
# -----------------------------
library(tidyverse)
library(lme4)
library(lmerTest)
library(broom.mixed)
library(furrr) # For parallel processing

# -----------------------------
# 2. SETUP PARALLELO
# -----------------------------
# Use all cores minus one to keep the OS responsive
n_cores <- 8 # parallel::detectCores(logical = FALSE) - 1
plan(multisession, workers = n_cores)

message(paste("🚀 Running on", n_cores, "cores"))

# -----------------------------
# COSTANTI GLOBALI
# -----------------------------
set.seed(123) # Initial seed for reproducibility

N_TRACKS_TOTAL <- 20
N_TRACKS_PER_SUBJECT <- 10
BETA_TARGET <- 0.15
SD_SUBJECT <- 1.2
SD_TRACK <- 1
SD_RESIDUAL <- 1.5
ALPHA <- 0.05

# Simulations
N_SIM <- 100
SAMPLE_SIZES <- seq(20, 120, by = 10)

# Grids
SD_SUBJECT_GRID <- seq(0.2, 2.0, by = 0.3)
SD_TRACK_GRID <- seq(0.2, 2.0, by = 0.3)

# ============================================================
# 3. FUNZIONE: SIMULA UN DATASET (LOGIC UNCHANGED)
# ============================================================

simulate_dataset <- function(n_subjects, beta_target, sd_subject, sd_track, sd_residual) {
    subjects <- paste0("S", seq_len(n_subjects))
    tracks <- paste0("T", seq_len(N_TRACKS_TOTAL))

    design <- expand_grid(
        subject = subjects,
        track   = tracks
    ) |>
        group_by(subject) |>
        slice_sample(n = N_TRACKS_PER_SUBJECT) |>
        ungroup()

    subject_re <- tibble(
        subject = subjects,
        u_subject = rnorm(n_subjects, 0, sd_subject)
    )

    track_re <- tibble(
        track = tracks,
        u_track = rnorm(N_TRACKS_TOTAL, 0, sd_track)
    )

    design |>
        left_join(subject_re, by = "subject") |>
        left_join(track_re, by = "track") |>
        mutate(
            target = runif(n(), 1, 7),
            perceived = beta_target * target +
                u_subject +
                u_track +
                rnorm(n(), 0, sd_residual)
        )
}

# ============================================================
# 4. FUNZIONE: STIMA POTENZA (OPTIMIZED LMER)
# ============================================================

estimate_power <- function(n_subjects, beta_target, sd_subject, sd_track, sd_residual) {
    # We use replicate loop here, but the OUTER calls will be parallelized
    p_values <- replicate(N_SIM, {
        data <- simulate_dataset(
            n_subjects, beta_target, sd_subject, sd_track, sd_residual
        )

        # OPTIMIZATION: calc.derivs = FALSE speeds up fitting
        # We suppressMessages to avoid "boundary (singular) fit" spam in the console
        model <- suppressMessages(lmer(
            perceived ~ target + (1 | subject) + (1 | track),
            data = data,
            REML = FALSE,
            control = lmerControl(calc.derivs = FALSE)
        ))

        # Extract p-value safely
        coefs <- summary(model)$coefficients
        if ("target" %in% rownames(coefs)) {
            coefs["target", "Pr(>|t|)"]
        } else {
            NA # Safety in case model drops the term (rare)
        }
    })

    mean(p_values < ALPHA, na.rm = TRUE)
}

# ============================================================
# 5. GRAFICO 1: POTENZA vs SAMPLE SIZE (PARALLEL)
# ============================================================

message("Starting Graph 1 simulations...")

power_sample_size <- tibble(
    n_subjects = SAMPLE_SIZES
) |>
    mutate(
        # future_map_dbl runs in parallel
        power = future_map_dbl(
            n_subjects,
            estimate_power,
            beta_target = BETA_TARGET,
            sd_subject = SD_SUBJECT,
            sd_track = SD_TRACK,
            sd_residual = SD_RESIDUAL,
            .options = furrr_options(seed = TRUE) # Ensures reproducible RNG in parallel
        )
    )

ggplot(power_sample_size, aes(x = n_subjects, y = power)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    geom_hline(yintercept = 0.8, linetype = "dashed") +
    labs(
        title = "Power analysis: effect of sample size",
        subtitle = paste("Simulations:", N_SIM),
        x = "Number of subjects",
        y = "Statistical power"
    ) +
    theme_minimal()

ggsave("power_analysis_sample_size.png", width = 8, height = 6, dpi = 300)

# ============================================================
# 6. GRAFICO 2: POTENZA vs VARIANZE RANDOM (PARALLEL)
# ============================================================

message("Starting Graph 2 simulations (this takes longer)...")

power_variance <- expand_grid(
    sd_subject = SD_SUBJECT_GRID,
    sd_track   = SD_TRACK_GRID
) |>
    mutate(
        # future_pmap_dbl runs in parallel
        power = future_pmap_dbl(
            list(sd_subject, sd_track),
            ~ estimate_power(
                n_subjects = 50,
                beta_target = BETA_TARGET,
                sd_subject = ..1,
                sd_track = ..2,
                sd_residual = SD_RESIDUAL
            ),
            .options = furrr_options(seed = TRUE)
        )
    )

ggplot(power_variance, aes(x = sd_subject, y = sd_track, fill = power)) +
    geom_tile() +
    scale_fill_viridis_c(limits = c(0, 1)) +
    labs(
        title = "Power as a function of random-effect variances",
        x = "Subject SD",
        y = "Track SD",
        fill = "Power"
    ) +
    theme_minimal()

ggsave("power_analysis_variance_heatmap.png", width = 8, height = 6, dpi = 300)

plan(sequential) # Chiude i worker paralleli
