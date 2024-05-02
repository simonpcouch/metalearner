r_cmd_batch <- function(file) {
  system(paste0("R CMD BATCH --vanilla ", file, " ", file, "out"))
}

source("helpers.R")

# prepare datasets and resample member specifications --------------------------
prepare_files <-
  list.files(
    pattern = "prepare_",
    full.names = TRUE,
    recursive = TRUE
  )

prepare_files <- prepare_files[!grepl("Rout", prepare_files)]

lapply(prepare_files, r_cmd_batch)

# fit members for all resampled specifications. members are fitted regardless
# of whether the meta-learner would include them so that we can reuse those member
# fits for each proposed meta-learner -----------------------------------------
fit_members_files <-
  list.files(
    pattern = "fit_members_",
    full.names = TRUE,
    recursive = TRUE
  )

fit_members_files <- fit_members_files[!grepl("Rout", fit_members_files)]

lapply(fit_members_files, r_cmd_batch)

# blend and benchmark each proposed meta-learner -------------------------------
blend_files <-
  list.files(
    pattern = "blend_",
    full.names = TRUE,
    recursive = TRUE
  )

blend_files <- blend_files[!grepl("Rout", blend_files)]

lapply(blend_files, r_cmd_batch)
