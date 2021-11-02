# 0. Libraries ====

library(tidyverse)
library(dtplyr)
library(data.table)
library(lubridate)
library(stringr)
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
  filter(ticker == "ETH", 
         year(txn_date) == 2020) %>% 
  group_by(month(txn_date), txn_type) %>% 
  summarize(total_quantity = sum(quantity)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = txn_type, 
              values_from = total_quantity) %>% 
  collect() %>% 
  bind_cols(tibble(month = month.name)) %>% 
  select(month, BUY, SELL)

# 3.6 Question 6 ====

# Summaries all buy and sell transactions for each member_id by generating 1 row for each member with the following additional columns:
  
# Bitcoin buy quantity
# Bitcoin sell quantity
# Ethereum buy quantity
# Ethereum sell quantity

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  group_by(member_id, ticker, txn_type) %>% 
  summarize(total_quantity = sum(quantity)) %>% 
  ungroup() %>% 
  mutate(type = str_c(ticker, txn_type, 
                      sep = "_")) %>% 
  select(member_id, type, total_quantity) %>% 
  pivot_wider(names_from = type, 
              values_from = total_quantity) %>% 
  collect()

# 3.7 Question 7 ====

# What was the final quantity holding of Bitcoin for each member? 
# Sort the output from the highest BTC holding to lowest

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  filter(ticker == "BTC") %>% 
  group_by(member_id, txn_type) %>% 
  summarize(final_quantity = sum(quantity)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = txn_type, 
              values_from = final_quantity) %>% 
  mutate(final_quantity = BUY - SELL) %>% 
  select(member_id, final_quantity) %>% 
  arrange(desc(final_quantity)) %>% 
  collect()

# 3.8 Question 8 ====

# Which members have sold less than 500 Bitcoin? 
# Sort the output from the most BTC sold to least

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  filter(ticker == "BTC", 
         txn_type == "SELL") %>% 
  group_by(member_id) %>% 
  summarize(total_sold = sum(quantity)) %>% 
  ungroup() %>% 
  filter(total_sold < 500) %>% 
  arrange(desc(total_sold))

  
# 3.9 Question 9 ====

# What is the total Bitcoin quantity for each member_id owns after 
# adding all of the BUY and SELL transactions from the transactions 
# table? Sort the output by descending total quantity

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  filter(ticker == "BTC") %>% 
  group_by(member_id, txn_type) %>% 
  summarize(total_quantity = sum(quantity)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = txn_type, 
              values_from = total_quantity) %>% 
  mutate(quantity_diff = round(abs(BUY - SELL), 2)) %>% 
  select(member_id, quantity_diff) %>% 
  arrange(-quantity_diff) %>% 
  collect()
  

# 3.10 Question 10 ====

# Which member_id has the highest buy to sell ratio by quantity?

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  group_by(member_id, txn_type) %>% 
  summarize(total_quantity =  sum(quantity)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = txn_type, 
              values_from = total_quantity) %>% 
  mutate(ratio = round(BUY/SELL, 2)) %>% 
  arrange(-ratio)
  #slice_max(order_by = ratio)

# 3.11 Question 11 ====

# For each member_id - which month had the highest total 
# Ethereum quantity sold`?

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  filter(ticker == "ETH", 
         txn_type == "SELL") %>% 
  group_by(member_id, month(txn_date)) %>% 
  summarize(total_quantity = sum(quantity)) %>% 
  slice_max(order_by = total_quantity) %>% 
  ungroup() %>% 
  arrange(-total_quantity) %>% 
  collect()
