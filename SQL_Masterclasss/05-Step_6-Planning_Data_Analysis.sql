/* Step 6 - Planning Ahead For Data Analysis */

SET SEARCH_PATH = sql_masterclass;

SELECT *
FROM members;

SELECT *
FROM prices
LIMIT 10;

SELECT *
FROM transactions
LIMIT 10;

-- Create a Base Table

-- Step 1
-- Create a base table that has each mentor's name, region and end of year total quantity for each ticker
-- My Query
DROP TABLE IF EXISTS temp_portfolio_base;

CREATE TEMP TABLE temp_portfolio_base AS (

SELECT first_name, 
	   region,
	   EXTRACT(YEAR FROM txn_date) AS year, 
	   ticker, 
	   ROUND((SUM(CASE WHEN txn_type ~ 'SELL' THEN -quantity
				 	   ELSE quantity 
				       END))::NUMERIC, 2) AS total_quantity
FROM transactions
LEFT JOIN members
	USING(member_id)
WHERE EXTRACT(YEAR FROM txn_date) <> 2021
GROUP BY region, first_name, 
		 EXTRACT(YEAR FROM txn_date), 
		 ticker
ORDER BY first_name, region, year, ticker

);

-- Step 2
-- Inspect the result
SELECT year, ticker, total_quantity
FROM temp_portfolio_base
WHERE first_name ~ 'Abe'
ORDER BY ticker, year; 

-- Step 3
-- Create cumulative sum
-- Create a cumulative sum for Abe which has an independent value for each ticker
SELECT year, ticker, total_quantity, 
	   SUM(total_quantity) OVER(PARTITION BY ticker 
								ORDER BY year
								ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_total_quanitity
FROM temp_portfolio_base
WHERE first_name  ~ 'Abe'
ORDER BY ticker, year;

-- Step 4 
-- Generate an additional cumulative_quantity column for the temp_portfolio_base temp table
-- first alter table and then update, doesn't work 

CREATE TEMP TABLE temp_cum_portfolio AS (

SELECT *,
	   SUM(total_quantity) OVER(PARTITION BY first_name, ticker 
							    ORDER BY year
							    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_quantity
FROM temp_portfolio_base

);

SELECT *
FROM temp_cum_portfolio
WHERE first_name ~ 'Abe';

-- Quetion 1
-- What is the total portfolio value for each mentor at the end of 2020?

-- Quetion 2
-- What is the total portfolio value for each region at the end of 2019?

-- Quetion 3
-- What percentage of regional portfolio values does each mentor contribute at the end of 2018?

-- Quetion 4
-- Does this region contribution percentage change when we look across both Bitcoin and Ethereum portfolios 
-- independently at the end of 2017?