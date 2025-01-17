
# metalearner

This repository contains source code for a set of experiments that
assess the performance of multiple approaches to model stacking with the
[stacks package](https://stacks.tidymodels.org/).

The scripts in this repo benchmark the existing implemented
meta-learner, a regularized linear model, against a set of proposed
alternative meta-learners. They rely on a branch of the stacks package
which introduces a `meta_learner` argument to `blend_predictions`,
allowing for combining predictions from member models with any modeling
workflow. That version of the package can be installed with the
following code:

``` r
pak::pak("tidymodels/stacks@general-meta")
```

Install of the dependencies needed to run this experiment with
`pak::local_install_dev_deps()`.

## Structure

The `analyses` folder contains a series of scripts that benchmark model
stacking with several combinations of datasets and meta-learners.

The structure of each sub-folder in `analyses`, for a dataset called
`dataset`, is as follows:

- `dataset/`
  - `prepare_dataset.R`: A script that prepares data and fits a series
    of preprocessors and models to resamples of a dataset. Data splits
    resulting from this script are saved to `dataset_data.RData`. Model
    fit objects resulting from this script are saved to the
    `candidate_fits/` sub-directory.
  - `dataset_data.RData`: Data splits resulting from
    `prepare_dataset.R`.
  - `candidate_fits/`: A folder containing model fits given some
    `preproc`essor and `model` on resamples of the `dataset`. Each of
    the objects are stored as a row of a workflow set, and can be
    row-binded together to form a fitted `workflow_set` object.
    - `dataset_preproc1_model1.RData`
    - `dataset_preproc1_model2.RData`
    - …
  - `fit_members_dataset.R`: A script that reads in each element of
    `candidate_fits/` and fits *all* of them on the entire training set.
    The needed results from this script can then be dropped in to model
    stacks with fitted meta-learners as “fitted members.” Doing this
    step separately from the usual stacks pipeline allows for only
    fitting each base learner on the entire training set only once,
    rather than for each unique combination of preprocessor and model.
  - `member_fits/`: A folder containing model fits given some
    `preproc`essor and `model` on the training set of the `dataset`.
    - `dataset_preproc1_model1.RData`
    - `dataset_preproc1_model2.RData`
    - …
  - `blend_scripts/`:
    - `blend_dataset_preproc1_model1.R`: A script that reads in each
      element of `candidate_fits/`, row-binds them together to form a
      workflow set, generates a data stack using the workflow set, fits
      the `preproc`essor and `model` as a meta-learner to the data
      stack, drops in needed fitted members, and then generates some
      basic metrics with the fitted model stack. These metrics are saved
      as `dataset_preproc1_model1.Rdata` under `metrics/`.
    - `blend_dataset_preproc1_model2.R`
    - …

The top-level folder `metrics` contains the “output” from each of these
experiments, a five-element list with the dataset name, preprocessor and
model specification for the meta-learner, time to fit, and test set
performance metrics. The files are named in the format
`dataset_preproc_model.RData`.

The top-level folder `meta_learners` contains the code used to generate
the proposed preprocessors and model specifications.

The naming schemes in these experiments are chosen for straightforward
extensibility:

- Run all of the data preparation scripts and workflow set fitting
  scripts (`.R` files starting with `prepare_`)
- Run all of the member fitting scripts (`.R` files starting with
  `fit_members_`)
- Run all of the blending + benchmarking scripts (`.R` files starting
  with `blend_`)

The code that I use to run the experiment is in `run.R`.

## Proposed Meta-learners

| ID                | Recipe                       | Model Spec                              |
|:------------------|:-----------------------------|:----------------------------------------|
| `basic_glmnet`    | Minimal                      | Penalized Linear Regression             |
| `basic_xgb`       | Minimal                      | Boosted Tree (via XGBoost)              |
| `basic_lgb`       | Minimal                      | Boosted Tree (via LightGBM)             |
| `normalize_bt`    | Center + Scale               | Bagged Tree                             |
| `normalize_bm`    | Center + Scale               | Bagged Mars                             |
| `normalize_svm`   | Center + Scale               | Support Vector Machine (via RBF)        |
| `normalize_nn`    | Center + Scale               | Multi-layer Perceptron (Neural Network) |
| `pca_bt`          | Principal Component Analysis | Bagged Tree                             |
| `pca_bm`          | Principal Component Analysis | Bagged Mars                             |
| `pca_svm`         | Principal Component Analysis | Support Vector Machine (via RBF)        |
| `pca_nn`          | Principal Component Analysis | Multi-layer Perceptron (Neural Network) |
| `renormalize_svm` | C+S, PCA, C+S                | Support Vector Machine (via RBF)        |
| `renormalize_nn`  | C+S, PCA, C+S                | Multi-layer Perceptron (Neural Network) |
