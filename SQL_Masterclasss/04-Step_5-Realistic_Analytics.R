# 0. Libraries ====

library(tidyverse)
library(data.table)
library(lubridate)
library(dtplyr)
library(DBI)
library(RPostgres)

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

dbListFields(conn = sql_masterclass_db, 
             name = "transactions")

# 3. Queries ====

# 3.1 Question 1 ====
# What is the earliest and latest date of transactions for all members?

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  summarize(earliest = min(txn_date), 
            lasted = max(txn_date))

tbl(src = sql_masterclass_db, 
    "transactions") %>% 
  lazy_dt() %>% 
  summarize(across(.cols = txn_date, 
                   .fns = list(min, 
                               max), 
                   .names = "{.fn}_{.col}"))

# 3.2 Question 2 ====
# What is the range of market_date values available in the prices data?

tbl(src = sql_masterclass_db, 
    "prices") %>% 
  lazy_dt() %>% 
  summarize(across(.cols = market_date, 
                   .fns = list(min, 
                               max), 
                   .names = "{.fn}_{.col}"))
# 3.3 Question 3 ====

# Which top 3 mentors have the most Bitcoin quantity as of the 29th of August?

replicate(n = 10, expr = {
tic()
tbl(src = sql_masterclass_db, # transactions table
    "transactions") %>% 
  lazy_dt() %>% 
  left_join(y = tbl(src = sql_masterclass_db, # members table
                "members") %>% 
                lazy_dt(), 
            by = "member_id") %>% 
  filter(ticker == "BTC") %>% 
  group_by(first_name) %>% 
  summarize(final_quantity = sum(case_when(txn_type == "SELL" ~ -quantity,
                                           TRUE ~ quantity))) %>% 
  ungroup() %>% 
  mutate(final_quantity = round(final_quantity, 2)) %>% 
  arrange(-final_quantity) %>% 
  head(3)
toc(log = TRUE)
})


as.data.frame(t(data.frame(tic.log()))) %>% # from list to dataframe
  remove_rownames() %>% 
  set_names("time") %>% 
  mutate(time = str_remove(time, " sec elapsed"), 
         time = as.numeric(time)) %>% 
  summarize(mean(time)) %>% 
  pull()

# 3.4 Question 4 ====

# What is total value of all Ethereum portfolios for each region at the end date of our analysis? 
# Order the output by descending portfolio value

tbl(src = sql_masterclass_db, # transactions table
    "transactions") %>% 
  lazy_dt() %>% 
  inner_join(y = tbl(src = sql_masterclass_db, # prices table
                     "prices") %>% 
                   lazy_dt() %>%
                   filter(ticker == "ETH", 
                          market_date == "2021-08-29") %>% 
                   select(ticker, price),
             by = "ticker") %>%
  inner_join(y = tbl(src = sql_masterclass_db, # members table
                     "members") %>% 
                   lazy_dt(),
             by = "member_id") %>% 
  group_by(region, price) %>% 
  summarize(final_value = sum(case_when(txn_type == "SELL" ~ -quantity,
                                        TRUE ~ quantity))*price) %>% 
  ungroup() %>% 
  arrange(-final_value) %>% 
  select(-price)

# 3.5 Question 5 ====
# What is the average value of each Ethereum portfolio in each region? 
# Sort this output in descending order

tbl(src = sql_masterclass_db, # transactions table
    "transactions") %>% 
  lazy_dt() %>% 
  inner_join(y = tbl(src = sql_masterclass_db, # prices table
                     "prices") %>% 
               lazy_dt() %>%
               filter(ticker == "ETH", 
                      market_date == "2021-08-29") %>% 
               select(ticker, price),
             by = "ticker") %>%
  inner_join(y = tbl(src = sql_masterclass_db, # members table
                     "members") %>% 
               lazy_dt(),
             by = "member_id") %>% 
  group_by(region, price) %>% 
  summarize(final_value = sum(case_when(txn_type == "SELL" ~ -quantity,
                                        TRUE ~ quantity))*price,
            mentor_count = n_distinct(first_name)) %>% 
  ungroup() %>% 
  select(-price) %>% 
  mutate(avg_value = final_value/mentor_count) %>% 
  arrange(-avg_value)
