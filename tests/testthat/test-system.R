context("system tests")

test_that("running system test1", {
  Sys.setenv("R_TESTS" = "") # needed for R CMD CHECK to run correctly
  offsetsim::run('test01run.R')
  expect_equal( 1, 1 )
})
