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

dbGetQuery(conn = sql_masterclass_db, 
           "SELECT *
            FROM prices
            LIMIT 10;")

# 3. Step 3 - Daily Prices ====

# 3.1 Question 1 ====

# Now many total records do we have in the trading.prices table?

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  nrow(.)

# 3.2 Question 2 ====

# How many records are there per ticker value?

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  count(ticker)

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  group_by(ticker) %>% 
  summarize(count = n()) %>% 
  ungroup()

# 3.3 Question 3 ====

# What is the minimum and maximum market_date values?

tbl(src = sql_masterclass_db,
    "prices") %>% 
  lazy_dt() %>% 
  summarize(min_date = min(market_date), 
            max_date = max(market_date))

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  summarize(across(.cols = c(market_date), 
                   .fns = list(min, 
                               max), 
                   .names = "{.fn}_{.col}"))

# 3.4 Question 4 ====

# Are there differences in the minimum and maximum market_Date values for each ticker?

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  group_by(ticker) %>% 
  summarize(across(.cols = market_date, 
                   .fns = list(max, 
                               min))) %>% 
  ungroup()

# There are not differences.

# 3.5 Question 5 ====

# What is the average of the price column for Bitcoin records during the year 2020?

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  filter(year(market_date) == 2020, 
         ticker == "BTC") %>% 
  summarize(avg_price = round(mean(price), 2))

# 3.6 Question 6 ====

# What is the monthly average of the price column for Ethereum in 2020?
# Sort the output in chronological order and also round the average price value to 2 decimal places.

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  filter(year(market_date) == 2020, 
         ticker == "ETH") %>% 
  group_by(month(market_date)) %>% 
  summarize(avg_price = round(mean(price), 2)) %>% 
  ungroup() %>% 
  collect() %>% 
  set_names(c("month_id", "avg_price")) %>% 
  bind_cols(tibble(month = month.name)) %>% 
  relocate(month, .before = avg_price) %>% 
  fwrite(file = "prueba.csv")

# 3.7 Question 7 ====

# Are there any duplicate market_date values for any ticker value in our table? 

tbl(src = sql_masterclass_db,
    "prices") %>% 
  lazy_dt() %>% 
  group_by(ticker) %>% 
  summarize(total_days = n(), 
            distinct_days = n_distinct(market_date)) %>% 
  ungroup()

# There aren't duplicate market_date

# 3.8 Question 8 ====

# How many days from the trading.prices table exist where the 
# high price of Bitcoin is over $30.000?

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  filter(ticker == "BTC", 
         price > 30000) %>% 
  collect() %>% 
  nrow(.)

# 3.9 Question 9 ====

# How many "breakout" days were there in 2020 where the price column
# is greater than the open column for each ticker?

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  filter(year(market_date) == 2020, 
         price > open) %>% 
  group_by(ticker) %>% 
  summarize(breakout = n()) %>% 
  ungroup()

# 3.10 Question 10 ====

# How many "non_breakout" days were there in 2020 where the price column
# is less than the open column for each ticker?

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  filter(year(market_date) == 2020, 
         price < open) %>% 
  group_by(ticker) %>% 
  summarize(non_breakout = n()) %>% 
  ungroup()

# 3.11 Question 11 ====

# What percentage of the day in 2020 where breakout days vs non breakout days?
# Round the percentage to 2 decimal places

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  group_by(ticker) %>% 
  summarize(percentage_breakout = round(sum(case_when(price > open ~ 1,
                                                TRUE ~ 0))/nrow(.), 2), 
            percentage_non_breakout = round(sum(case_when(price < open ~ 1,
                                                          TRUE ~ 0))/nrow(.), 2)) %>% 
  ungroup()



