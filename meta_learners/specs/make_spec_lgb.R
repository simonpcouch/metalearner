make_spec <- function() {
  boost_tree(trees = tune(), mtry = tune(),
             learn_rate = tune(), stop_iter = 10) %>%
    set_engine("lightgbm", num_threads = 1) %>%
    set_mode("regression")
}
