make_spec <- function() {
  mlp(hidden_units = tune(), penalty = tune(), epochs = tune()) %>%
    set_engine("nnet", MaxNWts = 1e5) %>%
    set_mode("regression")
}
