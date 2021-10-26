# 0. Libraries ====

library(tidyverse)
library(DBI)
library(RPostgres)
library(dtplyr)
library(dbplyr)

# 1. Read and Load Data ====

members <- read_csv(file = "SQL_Masterclasss/Data/members.csv")
str(members)
head(members)

prices <- read_csv(file = "SQL_Masterclasss/Data/prices.csv")
str(prices)
head(prices)

transactions <- read_csv(file = "SQL_Masterclasss/Data/transactions.csv")
str(transactions)
head(transactions)


# 2. Connecting to DB ====

sql_masterclass_db <- dbConnect(drv = Postgres(), 
                               dbname = "8-Week-SQL-Challenge", 
                               host = "localhost", 
                               port = 5432, 
                               user = "postgres", 
                               password = Sys.getenv("PostgreSQL_Password"), 
                               bigint = "integer")

dbExecute(conn = sql_masterclass_db, 
          'SET SEARCH_PATH = sql_masterclass;')

dbListTables(conn = sql_masterclass_db)

# 3. Export Data to PostgreSQL ====

# 3.1 Members Table ==== 

dbWriteTable(conn = sql_masterclass_db, 
             name = "members", 
             value = members, 
             overwrite = TRUE)

dbListFields(conn = sql_masterclass_db, 
             name = "members")

dbGetQuery(conn = sql_masterclass_db, 
           'SELECT *
            FROM members;')

# 3.2 Prices Table ====

dbWriteTable(conn = sql_masterclass_db, 
             name = "prices", 
             value = prices, 
             overwrite = TRUE)

dbListFields(conn = sql_masterclass_db, 
             name = "prices")

dbGetQuery(conn = sql_masterclass_db, 
           'SELECT COUNT(*)
            FROM prices;')

dbGetQuery(conn = sql_masterclass_db, 
           'SELECT *
            FROM prices
            LIMIT 5;')

# 3.3 Transactions Table  ====

dbWriteTable(conn = sql_masterclass_db, 
             name = "transactions", 
             value = transactions,  
             overwrite = TRUE)

dbListFields(conn = sql_masterclass_db, 
            name = "transactions")

dbGetQuery(conn = sql_masterclass_db, 
           'SELECT COUNT(*)
            FROM transactions;')

dbGetQuery(conn = sql_masterclass_db, 
           'SELECT *
            FROM transactions
            LIMIT 10;')
