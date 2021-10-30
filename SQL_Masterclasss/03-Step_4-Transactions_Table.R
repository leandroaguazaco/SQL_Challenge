# 0. Libraries ====

library(tidyverse)
library(dtplyr)
library(data.table)
library(lubridate)
library(DBI)
library(RPostgres)

# 1. Connection to Database ====

sql_masterclass_db <- dbConnect(drv = Postgres(), 
                                dbname = "8-Week-SQL-Challenge", 
                                host = "localhost", 
                                port = 5432, 
                                user = "postgres", 
                                password = Sys.getenv("PostgreSQL_Password"), 
                                bigint = "integer")

dbDisconnect(conn = sql_masterclass_db)

# 2. Set Schema ====

dbExecute(conn = sql_masterclass_db, 
          "SET SEARCH_PATH = sql_masterclass;")

dbListTables(conn = sql_masterclass_db)

dbListFields(conn = sql_masterclass_db, 
             name = "transactions")

dbGetQuery(conn = sql_masterclass_db, 
           "SELECT *
            FROM transactions
            LIMIT 10;")

# 3. Step 4 -Transactions Table ====

# 3.1 Question 1 ====

# How many records are there in the trading.transactions table?

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  nrow(.)

# 3.2 Question 2 ====

# How many unique transactions are there?

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  summarize(unique_transactions = n_distinct(txn_id))

# 3.3 Question 3 ====

# How many buy and sell transactions are there for Bitcoin?

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  filter(ticker == "BTC") %>% 
  group_by(txn_type) %>% 
  summarize(type_count = n()) %>% 
  ungroup()

# 3.4 Question 4 ==== 

# For each year, calculate the following buy and sell metrics for Bitcoin:

# total transaction count
# total quantity
# average quantity per transaction

# Also round the quantity columns to 2 decimal places.

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  filter(ticker == "ETH") %>% 
  group_by(year(txn_date), txn_type) %>% 
  summarize(total_count = n(), 
            total_quantity = round(sum(quantity), 2), 
            avg_quantity = round(mean(quantity), 2)) %>% 
  ungroup() %>% 
  rename(year = `year(txn_date)`) %>% 
  collect() 

# 3.5 Question 5 ====

# What was the monthly total quantity purchased and sold 
# for Ethereum in 2020?

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  mutate(txn_type = factor(txn_type)) %>% 
  distinct(txn_type)
