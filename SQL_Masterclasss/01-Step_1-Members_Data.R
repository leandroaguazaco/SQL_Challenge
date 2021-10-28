# 0. Libraries ====

library(tidyverse)
library(data.table)
library(DBI)
library(RPostgres)
library(dtplyr)
library(dbplyr)

# 1. Database connection ====

sql_masterclass_db <- dbConnect(drv = Postgres(), 
                                dbname = "8-Week-SQL-Challenge", 
                                host = "localhost", 
                                port = 5432, 
                                user = "postgres", 
                                password = Sys.getenv("PostgreSQL_Password"), 
                                bigint = "integer")

# 2. Set Schema ====

dbExecute(conn = sql_masterclass_db, 
          "SET SEARCH_PATH = sql_masterclass;")

dbListTables(conn = sql_masterclass_db)

# 3. Step1 - Members Data ====

# 3.1 Question 1 ====

# Show only the top 5 rows from the trading.members table

tbl(src = sql_masterclass_db, 
    "members") %>% 
  lazy_dt() %>% 
  head(5) %>% # slice(1:5) 
  collect()

# 3.2 Question 2 ====

# Sort all the rows in the table by first_name in alphabetical order and show the top 3 rows

tbl(src = sql_masterclass_db, 
    "members") %>% 
  lazy_dt() %>% 
  arrange(first_name) %>% 
  head(3)

# 3.3 Question 3 ====

# Which records from trading.members are from the United States region?

tbl(src = sql_masterclass_db, 
    "members") %>% 
  lazy_dt() %>% 
  filter(region == "United States")

# 3.4 Question 4 ====

# Select only the member_id and first_name columns for members who are not from Australia

tbl(src = sql_masterclass_db, 
    "members") %>% 
  lazy_dt() %>% 
  filter(region != "Australia") %>% 
  select(member_id, first_name)
  
# 3.5 Question 5 ====

# Return the unique region values from the trading.members table and 
# sort the output by reverse alphabetical order

tbl(src = sql_masterclass_db, 
    "members") %>% 
  lazy_dt() %>% 
  select(region) %>% 
  distinct() %>% 
  arrange(-region)

# 3.6 Question 6 ====

# How many mentors are there from Australia or the United States?

tbl(src = sql_masterclass_db, 
    "members") %>% 
  lazy_dt() %>% 
  filter(region %in% c("Australia", "United States")) %>% 
  collect() %>% 
  nrow()

# 3.7 Question 7 ====

# How many mentors are not from Australia or the United States?

tbl(src = sql_masterclass_db, 
    "members") %>% 
  lazy_dt() %>% 
  filter(!region %in% c("Australia", "United States")) %>% 
  collect() %>% 
  nrow()

# 3.8 Question 8 ====

# How many mentors are there per region? Sort the output
# by regions with the most mentors to the least

tbl(src = sql_masterclass_db, 
    "members") %>% 
  lazy_dt() %>% 
  group_by(region) %>% 
  summarize(mentor_count = n()) %>% 
  ungroup() %>% 
  arrange(-mentor_count)

# 3.9 Question 9 ====

# How many US mentors and non US mentors are there?

tbl(src = sql_masterclass_db, 
    "members") %>% 
  lazy_dt() %>% 
  mutate(origin = case_when(region == "United States" ~ "US", 
                            TRUE ~ "Non US")) %>% 
  group_by(origin) %>% 
  summarize(mentor_count = n())

# 3.10 Question 10 ====

# How many mentors have a first name starting with a letter before 'E'?

tbl(src = sql_masterclass_db, 
    "members") %>%
  lazy_dt() %>% 
  filter(str_detect(string = first_name, 
                    pattern = "(.*E.*)|(.*e.*)")) %>%
  collect() %>% 
  nrow()


