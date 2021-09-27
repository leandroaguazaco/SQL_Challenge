# 0. Libraries ====
library(tidyverse)
library(dbplyr)
library(odbc)
library(DBI)
library(RPostgres)

# 1. Connect to and Check a PostgreSQL database ====

sql_challenge_db <- DBI::dbConnect(
  drv = RPostgres::Postgres(), 
  dbname = "8-Week-SQL-Challenge", 
  host = "localhost",
  port = 5432,
  user = "postgres",
  password = Sys.getenv("PostgreSQL_Password"), 
  bigint = "integer")

# 1.1 Set schema

# Alternative 1
dbGetQuery(conn = sql_challenge_db, 
           statement = 'SET SEARCH_PATH = "04-data_bank";')

# Alternative 2
dbExecute(conn = sql_challenge_db, 
          statement = 'SET SEARCH_PATH = "04-data_bank";')

# 1.2 List database tables

dbListTables(sql_challenge_db)

# 1.3 Fields inside tables

dbListFields(conn = sql_challenge_db, 
             name = "customer_nodes")

# 1.4 Consulting a table

# Not hold the data itself
tbl(sql_challenge_db, "customer_nodes") %>% 
  head()

# 1.4 Disconnect from the database 

# Always have R disconnect from the database when you're done
dbDisconnect(sql_challenge_db)

# 2. Queries ====

