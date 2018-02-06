/*
Example functions written in PL/pgSQL for use in R client code to demonstrate
how R can call these functions to make changes on the database or to return tables of data as data frames.
The example table used here is called 'iris' and resides in the 'public' schema' It was created 
and populated by the DBI function 'dbWriteTable' using the R 'iris' data set.
See the R script named 'demo.R' to see how these functions are used.
*/
CREATE OR REPLACE FUNCTION table_exists(p_schema_name TEXT, p_table_name TEXT)
RETURNS BOOLEAN
AS
$$
DECLARE
  l_exists BOOLEAN;
BEGIN
  SELECT INTO l_exists EXISTS (
    SELECT 1
    FROM
	  information_schema.tables 
    WHERE
	  table_schema = p_schema_name
      AND
	    table_name = p_table_name
    );
  RETURN l_exists;
END;
$$
LANGUAGE plpgsql
STABLE
SECURITY DEFINER;
COMMENT ON FUNCTION table_exists(TEXT, TEXT) IS
$$
Given a schema name and table name, queries the 'information_schema.tables' table and returns TRUE if the table is found
and FALSE if not.
We could use the R DBI 'dbExistsTable()' to do this but the PL/pgSQL function can be used by clients other than R DBI.
Example call: SELECT * FROM table_exists('public', 'iris');
$$;

CREATE OR REPLACE FUNCTION drop_table(p_schema_name TEXT, p_table_name TEXT)
RETURNS TEXT
AS
$$
DECLARE
  l_exists BOOLEAN := table_exists(p_schema_name, p_table_name);
  l_full_table_name TEXT := p_schema_name || '.' || p_table_name;
BEGIN
  IF l_exists THEN
    EXECUTE FORMAT('DROP TABLE %s', l_full_table_name);
	RETURN FORMAT('Table %s dropped!', l_full_table_name);
  END IF;
  RETURN FORMAT('Table %s does not exist!', l_full_table_name);
END;
$$
LANGUAGE plpgsql
VOLATILE -- has to be because we are dropping a table
SECURITY DEFINER;
COMMENT ON FUNCTION drop_table(TEXT, TEXT) IS
$$
DROPs the table referenced by the given schema and table names and returns a text message.
It first checks that the table exists by calling the function 'table_exists()'. If it does, it drops it
and returns a message to that effect. If it does not exist, it returns a message indicating this.
Functions that execute dynamic SQL as this function does should be deployed and used with caution.
This is especially true for a destructive function such as this one that deletes a database object.
Because it alters the database structure, this table has to be declared 'VOLATILE'.
Example: SELECT * FROM drop_table('public', 'iris');
$$;

CREATE OR REPLACE FUNCTION get_data_for_species(p_species_name TEXT)
RETURNS TABLE(sepal_length FLOAT8, sepal_width FLOAT8, petal_length FLOAT8, petal_width FLOAT8, species TEXT)
AS
$$
BEGIN
  RETURN QUERY
  SELECT
    "Sepal.Length",
    "Sepal.Width",
    "Petal.Length",
    "Petal.Width",
    "Species"
  FROM
    iris
  WHERE
    "Species" = p_species_name;
END;
$$
LANGUAGE plpgsql
STABLE
SECURITY DEFINER;
COMMENT ON FUNCTION get_data_for_species(TEXT) IS
$$
Return all rows from the R 'iris' data set for a given species name as a table.
Assumes that the table 'iris' has been loaded from R using the DBI function 'dbWriteTable'.
The double quotes are needed in the SELECT clause to prevent misinterpretation of the periods in the column names
to prevent PostgreSQL from interpreting them as 'table_name.column_name'. The column names in the table here correspond to 
those in the source data frame. The table returned by this function uses the PostgreSQL convention for column names 
(all lower-case) and words separated by underscore.
The numeric values in the source data frame are represent as double precision numbers in PostgreSQL (FLOAT8).
Example: SELECT * FROM get_data_for_species('setosa');
$$
