library(DBI)
library(pool)

# Create the pool object for connecting to the database
pool <- pool::dbPool(
  drv = RPostgreSQL::PostgreSQL(),
  dbname = "michaelmaguire",
  host = "localhost",
  user = "michaelmaguire",
  port = 5432,
  password = ""
)
# Connect to the database
pg_conn <- poolCheckout(pool)
schema_name <- 'public'
table_name <- 'iris'
# Drop the old table if it exists.
drop_table_tmpl <- 'SELECT * FROM drop_table(?schema_name, ?table_name)'
drop_table_sql <- sqlInterpolate(DBI::ANSI(), drop_table_tmpl, schema_name = schema_name, table_name = table_name)
drop_table_msg <- dbGetQuery(pg_conn, drop_table_sql)
print(drop_table_msg)
# Passing both the schema name and table name. In PostgreSQL, this translates into "schema_name.table_name".
dbWriteTable(pg_conn, c(schema_name, table_name), iris, row.names=FALSE, append=FALSE)
get_spp_tmpl <- 'SELECT * FROM get_data_for_species(?spp_name)'
spp_name <- 'setosa'
get_spp_sql <- sqlInterpolate(DBI::ANSI(), get_spp_tmpl, spp_name = spp_name)
setosa_df <- dbGetQuery(pg_conn, get_spp_sql)
View(setosa_df)


