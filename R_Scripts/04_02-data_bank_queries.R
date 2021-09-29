# 0. Libraries ====
library(tidyverse)
library(data.table)
library(dtplyr)
library(lubridate)
library(dbplyr)
library(odbc)
library(DBI)
library(RPostgres)
library(RPostgreSQL)
library(connections)
library(tictoc)
library(nortest)
library(plotly)

# 1.0 Connect to and Check a PostgreSQL database ====

# Alternative 1: DBI package
sql_challenge_db <- DBI::dbConnect(
  drv = RPostgres::Postgres(), 
  dbname = "8-Week-SQL-Challenge", 
  host = "localhost",
  port = 5432,
  user = "postgres",
  password = Sys.getenv("PostgreSQL_Password"))

# Alternative 2: connections package
# https://rstudio.github.io/connections/
# Integrate DBI-compliant packages with the RStudio IDE’s Connection Pane
sql_challenge_db <- connection_open(
  drv = RPostgres::Postgres(), 
  dbname = "8-Week-SQL-Challenge", 
  host = "localhost",
  port = 5432,
  user = "postgres",
  password = Sys.getenv("PostgreSQL_Password"), 
  bigint = "integer")

# 1.1 Set schema ====

# Alternative 1
dbGetQuery(conn = sql_challenge_db, 
           statement = 'SET SEARCH_PATH = "04-data_bank";')

# Alternative 2
dbExecute(conn = sql_challenge_db, 
          statement = 'SET SEARCH_PATH = "04-data_bank";')

# Alternative 3
# Referencing schema inside a retrieving function like tbl()
dbplyr::in_schema(schema = "04-data_bank", 
                  table = "customer_nodes")

# 1.2 List database tables ====

dbListTables(sql_challenge_db)

# 1.3 Fields inside tables ====

dbListFields(conn = sql_challenge_db, 
             name = "customer_nodes")

# 1.4 Consulting a table ====

# Not hold the data itself
tbl(sql_challenge_db, "customer_nodes") %>% 
  head()

tbl(sql_challenge_db, in_schema(schema = "04-data_bank", 
                                table = "customer_nodes"))

# 1.5 Disconnect from the database ====

# Always have R disconnect from the database when you're done
dbDisconnect(sql_challenge_db)

# 2. Queries ====

# Question from Section B: Customer Transactions 
# For each month - how many Data Bank customers make more than 1 deposit and 
# either 1 purchase or 1 withdrawal in a single month?

# SQL statement: SELECT * FROM regions;
dbReadTable(sql_challenge_db, "customer_transactions")

# List tables 
dbListTables(conn = sql_challenge_db)

# List table fields 
dbListFields(conn = sql_challenge_db, 
             name = "customer_transactions")

# 2.0 Measure and save running time of R code ====

tic() # Timer
# here goes the code chunk
time <- toc()
difftime <- time$toc - time$tic # Timer

# 2.1 DBI package functions to run queries ====

# SQL syntax
tic() # Timer 
dbGetQuery(conn = sql_challenge_db, 
           statement = "
      SELECT customer_id, 
             EXTRACT(MONTH FROM txn_date) AS txn_month, 
             txn_type,
             COUNT(txn_type) AS transactions
      FROM customer_transactions
      GROUP BY customer_id, 
               EXTRACT(MONTH FROM txn_date), 
               xn_type
      BY customer_id, txn_month;")
toc() # Timer

# 2.2 dplyr package functions to run queries ====

tic() # Timer
tbl(src = sql_challenge_db, 
    "customer_transactions") %>%
  group_by(customer_id, month(txn_date), txn_type) %>% 
  summarize(transactions = n()) %>% 
  rename(txn_month = `month(txn_date)`) %>% 
  pivot_wider(names_from = txn_type, 
              values_from = transactions) %>%
  filter(deposit > 1) %>% 
  as_tibble() %>% # Allows use tidyr::unite() function
  unite("condition", 
        c(withdrawal, purchase), 
        sep = ",") %>% 
  filter(str_detect(condition, "(NA,1)|(1,NA)|(1,1)")) %>% 
  group_by(txn_month) %>% 
  summarize(customers = n()) %>% 
  arrange(txn_month) %>% 
  ungroup()
toc() # Timer

# 2.3 dtplyr (data.table) package functions to run queries ====

tic() # Timer
tbl(src = sql_challenge_db, 
    "customer_transactions") %>%
  lazy_dt() %>% 
  mutate(txn_month = month(txn_date)) %>% 
  relocate(txn_month, .after = txn_date) %>% 
  group_by(customer_id, txn_month, txn_type) %>% 
  summarize(transactions = n()) %>% 
  pivot_wider(names_from = txn_type, # 
              values_from = transactions) %>%
  filter(!is.na(deposit),
         deposit > 1) %>% 
  mutate(condition = str_c(str_replace_na(withdrawal), 
                           str_replace_na(purchase), 
                           sep = ",")) %>% 
  filter(str_detect(condition, "(NA,1)|(1,NA)|(1,1)")) %>% 
  group_by(txn_month) %>% 
  summarize(customers = n()) %>% 
  arrange(txn_month) %>% 
  ungroup()
toc() # Timer

# 2.4 Comparing running times ====

tibble(dplyr = dplyr,
       dtplyr = dtplyr) %>% 
  pivot_longer(everything(), 
               names_to = "package", 
               values_to = "time") %>% 
  ggplot(aes(x = time, 
             fill = package)) +
    geom_histogram(color = "black", 
                   binwidth = 0.015) + 
    facet_wrap(. ~ package, 
               scales = "free") + 
    theme_bw() +
    theme(legend.position = "none")



