library("testthat")
 
# source("./demo.R")

# Test with > test_file("./test_demo.R")

test_that("PostgreSQL connection", {
  expect_that(class(pg_conn)[[1]], equals("PostgreSQLConnection"))
})

