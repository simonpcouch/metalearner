make_spec <- function() {
  boost_tree(trees = tune(), mtry = tune(),
             learn_rate = tune(), stop_iter = 10) %>%
    set_engine("xgboost", nthread = 1) %>%
    set_mode("regression")
}
