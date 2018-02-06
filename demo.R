library(DBI)
library(pool)

# Create the pool object for connecting to the database.
# Assumes there is alocal instance of PostgreSQL running with the given user and database names
pool <- pool::dbPool(
  drv = RPostgreSQL::PostgreSQL(),
  dbname = "michaelmaguire",
  host = "localhost",
  user = "michaelmaguire",
  port = 5432,
  password = ""
)

# Connect to the database.
pg_conn <- poolCheckout(pool)

# Drop the PostgreSQL table "iris" if it exists by calling a PL/pgSQL function.
schema_name <- 'public'
table_name <- 'iris'
drop_table_tmpl <- 'SELECT * FROM drop_table(?schema_name, ?table_name)'
drop_table_sql <- sqlInterpolate(DBI::ANSI(), drop_table_tmpl, schema_name = schema_name, table_name = table_name)
drop_table_msg <- dbGetQuery(pg_conn, drop_table_sql)
print(drop_table_msg)

# Load the data frame "iris" into the PostgreSQL database.
dbWriteTable(pg_conn, c(schema_name, table_name), iris, row.names=FALSE, append=FALSE)

# Call a PostgreSQL function to return a table of data for a given species name in the "iris" table.
get_spp_tmpl <- 'SELECT * FROM get_data_for_species(?spp_name)'
spp_name <- 'setosa'
get_spp_sql <- sqlInterpolate(DBI::ANSI(), get_spp_tmpl, spp_name = spp_name)
setosa_df <- dbGetQuery(pg_conn, get_spp_sql)

# If running from RStudio, display the data frame containing the data from the returned table.
View(setosa_df)


