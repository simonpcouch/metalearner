source_safely <- function(file) {
  tryCatch({source(file); return(TRUE)}, error = function(e) {FALSE})
}

source("helpers.R")

# prepare datasets and resample member specifications --------------------------
prepare_files <-
  list.files(
    pattern = "prepare_",
    full.names = TRUE,
    recursive = TRUE
  )

lapply(prepare_files, source_safely)

# fit members for all resampled specifications. members are fitted regardless
# of whether the meta-learner would include them so that we can reuse those member
# fits for each proposed meta-learner -----------------------------------------
fit_members_files <-
  list.files(
    pattern = "fit_members_",
    full.names = TRUE,
    recursive = TRUE
  )

lapply(fit_members_files, source_safely)

# blend and benchmark each proposed meta-learner -------------------------------
blend_files <-
  list.files(
    pattern = "blend_",
    full.names = TRUE,
    recursive = TRUE
  )

lapply(blend_files, source_safely)
