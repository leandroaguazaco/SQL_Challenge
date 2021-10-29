/* Step 3 - Daily Prices */

SET SEARCH_PATH = sql_masterclass;

-- Prices table

SELECT *
FROM prices
LIMIT 10;

-- Question 1: Now many total records do we haver in the trading.prices table?

SELECT COUNT(*) AS total_records
FROM prices;

-- Question 2: How many records are there per ticker value?

SELECT ticker, COUNT(*) AS total_records
FROM prices
GROUP BY ticker;

-- Question 3: What is the minimum and maximum market_date values?

SELECT 
	MAX(market_date) AS maximun_market_date, 
	MIN(market_date) AS minimum_market_date
FROM prices;

-- Question 4: Are there differences in the minimum and maximum market_Date values for each ticker?

SELECT
	ticker,
	MIN(market_date) AS min_market_date,
	MAX(market_date) AS max_market_date
FROM prices
GROUP BY ticker;

-- Question 5: What is the average of the price column for Bitcoin records during the year 2020?

SELECT AVG(price) as avg_price
FROM prices 
WHERE ticker ~ 'BTC' AND
	  EXTRACT(YEAR FROM market_date) = 2020;
	  
-- Question 6: What is the monthly average of the price column for Ethereum in 2020?
-- 			   Sort the output in chronological order and also round the average price value to 2 decimal places.

SELECT EXTRACT(MONTH FROM market_date) AS month,
	   ROUND(AVG(price)::NUMERIC, 2) AS avg_price
FROM prices
WHERE ticker ~ 'ETH' AND
	  EXTRACT(YEAR FROM market_date) = 2020
GROUP BY EXTRACT(MONTH FROM market_date);

-- Question 7: Are there any duplicate market_date values for any ticker value in our table?

SELECT ticker, 
	   COUNT(market_date) AS total_count,
	   COUNT(DISTINCT market_date) AS unique_count
FROM prices
GROUP BY ticker;

-- Question 8: How many days from the trading.prices table exist where the 
-- 			   high price of Bitcoin is over $30.000?

SELECT COUNT(*) AS day_count
FROM prices
WHERE ticker ~ 'BTC' AND
	  high > 30000;

-- Question 9: How many "breakout" days were there in 2020 where the price column
-- 			   is greater than the open column for each ticker?

SELECT ticker, 
	   COUNT(*) AS breakout_days
FROM prices
WHERE price > open AND
	  EXTRACT(YEAR FROM market_date) = 2020
GROUP BY ticker;

-- Question 10: How many "non_breakout" days were there in 2020 where the price column
-- 			is less than the open column for each ticker?

SELECT ticker,
 	   COUNT(*) AS non_breakout_days
FROM prices
WHERE price < open AND
	  EXTRACT(YEAR FROM market_date) = 2020
GROUP BY ticker;

-- Question 11: What percentage of the day in 2020 where breakout days vs non breakout days?
--			 	Round the percentage to 2 decimal places

WITH 
breakout AS (
SELECT ticker, 
	   COUNT(*) AS breakout_days
FROM prices
WHERE price > open AND
	  EXTRACT(YEAR FROM market_date) = 2020
GROUP BY ticker),

non_breakout AS (
SELECT ticker,
 	   COUNT(*) AS non_breakout_days
FROM prices
WHERE price < open AND
	  EXTRACT(YEAR FROM market_date) = 2020
GROUP BY ticker), 

total_day AS (
SELECT ticker, COUNT(*) + 0.0 as market_days
FROM prices
WHERE EXTRACT(YEAR FROM market_date) = 2020
GROUP BY ticker)

SELECT ticker, 
	   breakout_days, 
	   non_breakout_days,
	   ROUND((breakout_days/market_days), 2) AS percentage_breakout, 
	   ROUND((non_breakout_days/market_days), 2) AS percentage_nobreakout
FROM breakout 
LEFT JOIN non_breakout
	USING(ticker)
LEFT JOIN total_day
	USING(ticker);
	
-- Alternative 

SELECT ticker,
	   ROUND(SUM(CASE WHEN price > open THEN 1 ELSE 0 END)/COUNT(*)::NUMERIC, 2) AS breakout_percentage, 
	   ROUND(SUM(CASE WHEN price < open THEN 1 ELSE 0 END)/COUNT(*)::NUMERIC , 2) AS non_breakout_percentage
FROM prices
WHERE EXTRACT(YEAR FROM market_date) = 2020
GROUP BY ticker;


