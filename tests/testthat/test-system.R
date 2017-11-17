context("system tests")

library(tools)

test_that("running test01", {
  Sys.setenv("R_TESTS" = "") # needed for R CMD CHECK to run correctly
  expected <- md5sum('../expected/test01out/collated_scenario_001_realisation_001_feature_001.rds')
  offsetsim::run('test01run.R', INFO)
  actual <- md5sum('../output/test01out/simulation_runs/00001/collated_outputs/collated_scenario_001_realisation_001_feature_001.rds')
  print(paste('expected[', expected, '] actual[', actual, ']'))
  expect_true(actual == expected)
})
