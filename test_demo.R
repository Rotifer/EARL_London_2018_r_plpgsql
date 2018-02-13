library("testthat")
 
source("./demo.R")

test_that("PostgreSQL connection is created",
          class(pg_conn)[[1]], equals("PostgreSQLConnection"))
