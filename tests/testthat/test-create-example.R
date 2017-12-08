context("system tests")

library(tools)
library(futile.logger)
library(rprojroot)

test_that("creating example usage file", {
  Sys.setenv("R_TESTS" = "") # needed for R CMD CHECK to run correctly


  testroot <- "."
  result <- tryCatch({
    # If we are running the test from within the package structure
    root <- rprojroot::find_root("DESCRIPTION")
    testroot <- paste0(root,"/tests")
  }, error = function(err) {
    # Else if we are running from outside
    testroot <- "."
  })
  
  tocreateDir <- paste0(testroot,'/output/test-create-example')
  tocreate <- paste0(tocreateDir, '/offsetsim_example.R')

  if (file.exists(tocreate)) {
    flog.warn(paste0("File '", tocreate, "' exists so will delete it first"))
    file.remove(tocreate)
  }

  expect_false(file.exists(tocreate))
  offsetsim::osim.create.example(tocreateDir, futile.logger::INFO)
  expect_true(file.exists(tocreate))
  
})
