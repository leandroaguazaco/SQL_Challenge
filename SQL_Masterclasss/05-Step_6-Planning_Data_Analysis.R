# 0. Libraries ====

library(DBI)
library(RPostgres)
library(tidyverse)
library(data.table)
library(dtplyr)
library(lubridate)

# 1. Connecting to Database ====

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


# 3. Planning Data Analysis ====

# 3.1 Step 1 ====
# Create a base table that has each mentor's name, region and end of 
# year total quantity for each ticker

temp_portfolio_base <- 
tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  left_join(y = tbl(src = sql_masterclass_db,
                    "members") %>% 
                  lazy_dt(), 
            by = "member_id") %>% 
  mutate(year = year(txn_date)) %>%
  filter(year != 2021) %>% 
  group_by(first_name, region, year, ticker) %>% 
  summarize(total_quantity = sum(case_when(txn_type == "SELL" ~ -quantity, 
                                           TRUE ~ quantity))) %>% 
  arrange(first_name, ticker, year) %>% 
  ungroup()

# 3.2 Step 2 ====
# Inspect the result

temp_portfolio_base %>% 
  filter(first_name == "Abe") %>% 
  arrange(ticker, year) %>% 
  collect()

# 3.3 Step 3 ====
# Create a cumulative sum for Abe which has an independent value for each ticker

temp_portfolio_base %>% 
  filter(first_name == "Abe") %>% 
  arrange(ticker, year) %>% 
  group_by(ticker, region, first_name) %>% 
  summarize(cum_quantity = cumsum(total_quantity)) %>% 
  ungroup() %>% 
  collect()
  
# 3.4 Step 4 ==== 
# Generate an additional cumulative_quantity column for the temp_portfolio_base

temp_portfolio_base <- temp_portfolio_base %>% 
  group_by(first_name, ticker) %>% 
  mutate(cum_quantity = cumsum(total_quantity)) %>% 
  ungroup()
