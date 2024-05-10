source("helpers.R")

library(tidymodels)
library(stacks)
library(embed)
library(future)

tidymodels_prefer()
options(pillar.advice = FALSE)
library(doMC); registerDoMC(n_workers())

recipe <- "basic"
spec <- "glmnet"
dataset <- "nhl"

source("helpers.R")

wf_set <- read_as_workflow_set(file.path("analyses", dataset, "candidate_fits"))

load(file.path("analyses", dataset, paste0(dataset, "_data.RData")))

# no need to define a meta-learner--use the glmnet default.

# add candidates to a data stack
data_stack <- 
  stacks() %>%
  add_candidates(wf_set)

# record time-to-fit for meta-learner fitting
timing <- system.time({
  set.seed(1)
  model_stack <-
    data_stack %>%
    blend_predictions()
})

model_stack_fitted <-
  add_members(model_stack, dataset)

ms <- metric_set(accuracy, brier_class, roc_auc)

res_metric <-
  bind_cols(
    predict(model_stack_fitted, test, type = "prob"),
    predict(model_stack_fitted, test, type = "class"),
    test
  ) %>%
  ms(
    truth = !!attr(data_stack, "outcome"),
    estimate = .pred_class,
    c(contains(".pred_"), -.pred_class)
  )

res <-
  list(
    dataset = dataset,
    recipe = recipe,
    spec = spec,
    time_to_fit = timing[["elapsed"]],
    metric = res_metric
  )

save(
  res, 
  file = file.path("metrics", paste0(dataset, "_", recipe, "_", spec, ".RData"))
)

plan(sequential)

