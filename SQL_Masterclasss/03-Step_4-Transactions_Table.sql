/* STEP 4 - TRANSACTIONS TABLE */

SET SEARCH_PATH = sql_masterclass;

SELECT *
FROM transactions
LIMIT 10;

-- Question 1: 
-- How many records are there in the trading.transactions table?

SELECT COUNT(*)
FROM transactions;

-- Question 2:
-- How many unique transactions are there?

SELECT COUNT(DISTINCT txn_id)
FROM transactions;

-- Question 3:
-- How many buy and sell transactions are there for Bitcoin?

SELECT txn_type, COUNT(*) AS transactions
FROM transactions
WHERE ticker ~ 'BTC'
GROUP BY txn_type;

-- Question 4: 
-- For each year, calculate the following buy and sell metrics for Bitcoin:
--- total transaction count
--- total quantity
--- average quantity per transaction
--- Also round the quantity columns to 2 decimal places.

SELECT EXTRACT(YEAR FROM txn_date) AS year, 
	   txn_type, 
	   COUNT(*)::NUMERIC AS total_count, 
	   ROUND(SUM(quantity)::NUMERIC, 2) AS total_quantity,
	   ROUND(AVG(quantity)::NUMERIC, 2) AS avg_quantity	   
FROM transactions
WHERE ticker ~ 'BTC'
GROUP BY EXTRACT(YEAR FROM txn_date), 
		 txn_type
ORDER BY year, txn_type;

-- Question 5:
-- What was the monthly total quantity purchased and sold for Ethereum in 2020?

SELECT EXTRACT(MONTH FROM txn_date) AS month, 
	   txn_type, 
	   SUM(quantity) AS total_quantity
FROM transactions
WHERE ticker ~ 'ETH' AND
      EXTRACT(YEAR FROM txn_date) = 2020
GROUP BY EXTRACT(MONTH FROM txn_date),
		 txn_type
ORDER BY month;

-- Alternative 1

WITH 
buy AS (

	SELECT EXTRACT(MONTH FROM txn_date) AS month, 
		   ROUND(SUM(quantity)::NUMERIC, 2) AS total_buy
	FROM transactions
	WHERE ticker ~'ETH' AND
		  txn_type ~ 'BUY' AND
		  EXTRACT(YEAR FROM txn_date) = 2020
	GROUP BY EXTRACT(MONTH FROM txn_date)), 

sell AS (
	
	SELECT EXTRACT(MONTH FROM txn_date) AS month, 
		   ROUND(SUM(quantity)::NUMERIC, 2) AS total_sell
	FROM transactions
	WHERE ticker ~'ETH' AND
		  txn_type ~ 'SELL' AND
		  EXTRACT(YEAR FROM txn_date) = 2020
	GROUP BY EXTRACT(MONTH FROM txn_date))

SELECT month, total_buy, total_sell
FROM buy 
LEFT JOIN sell
	USING(month);

-- Altenative 2

SELECT EXTRACT(MONTH FROM txn_date) AS month, 
	   ROUND(SUM(CASE WHEN txn_type ~ 'BUY' THEN quantity ELSE 0 END)::NUMERIC, 2) AS total_buy, 
	   ROUND(SUM(CASE WHEN txn_type ~ 'SELL' THEN quantity ELSE 0 END)::NUMERIC, 2) AS total_sell 
FROM transactions
WHERE EXTRACT(YEAR FROM txn_date) = 2020 AND
	  ticker ~ 'ETH'
GROUP BY EXTRACT(MONTH FROM txn_date)
ORDER BY month;

-- Question 6:
-- Summarise all buy and sell transactions for each member_id by generating 1 row for 
-- each member with the following additional columns:
--- Bitcoin buy quantity
--- Bitcoin sell quantity
--- Ethereum buy quantity
--- Ethereum sell quantity

SELECT member_id, 
	   ROUND(SUM(CASE WHEN (ticker ~ 'BTC' AND txn_type ~ 'BUY') THEN quantity ELSE 0 END)::NUMERIC, 2) AS total_BTC_buy,
	   ROUND(SUM(CASE WHEN (ticker ~ 'BTC' AND txn_type ~ 'SELL') THEN quantity ELSE 0 END)::NUMERIC, 2) AS total_BTC_sell,
	   ROUND(SUM(CASE WHEN (ticker ~ 'ETH' AND txn_type ~ 'BUY') THEN quantity ELSE 0 END)::NUMERIC, 2) AS total_ETH_buy,
	   ROUND(SUM(CASE WHEN (ticker ~ 'ETH' AND txn_type ~ 'SELL') THEN quantity ELSE 0 END)::NUMERIC, 2) AS total_ETH_sell
FROM transactions
GROUP BY member_id;

-- Questioin 7:
-- What was the final quantity holding of Bitcoin for each member? Sort the output from the highest BTC holding to lowest

SELECT member_id, 
	   ROUND((total_buy - total_sell)::NUMERIC, 2) AS final_quantity_holding
FROM (SELECT member_id, 
	         SUM(CASE WHEN txn_type ~ 'BUY' THEN quantity ELSE 0 END) AS total_buy, 
	   		 SUM(CASE WHEN txn_type ~ 'SELL' THEN quantity ELSE 0 END) AS total_sell
	  FROM transactions
	  WHERE ticker ~ 'BTC'
	  GROUP BY member_id) AS aux1
ORDER BY final_quantity_holding DESC;

-- Question 8:
-- Which members have sold less than 500 Bitcoin? Sort the output from the most BTC sold to least

SELECT member_id, 
	   ROUND(SUM(quantity)::NUMERIC, 2) AS btc_sold
FROM transactions
WHERE ticker ~ 'BTC' AND
	  txn_type ~ 'SELL'
GROUP BY member_id
HAVING SUM(quantity) < 500
ORDER BY btc_sold DESC;

-- Question 9:
-- What is the total Bitcoin quantity for each member_id owns after adding all of the BUY and SELL 
-- transactions from the transactions table? Sort the output by descending total quantity

SELECT member_id, 
	   ROUND(SUM(CASE WHEN txn_type ~ 'BUY' THEN quantity
				      WHEN txn_type ~ 'SELL' THEN -quantity
				      END)::NUMERIC, 2) AS quantity_diff
FROM transactions
WHERE ticker ~ 'BTC'
GROUP BY member_id
ORDER BY quantity_diff DESC;

-- Question 10:
-- Which member_id has the highest buy to sell ratio by quantity?

SELECT member_id, 
	   ROUND((SUM(CASE WHEN txn_type ~ 'BUY' THEN quantity ELSE 0 END) / 
	   SUM(CASE WHEN txn_type ~ 'SELL' THEN quantity ELSE 0 END))::NUMERIC, 2) AS ratio
FROM transactions
GROUP BY member_id
ORDER BY ratio DESC;

-- Question 11:
-- For each member_id - which month had the highest total Ethereum quantity sold`?

WITH eth_sold AS (
	
SELECT *, 
	   RANK() OVER(PARTITION BY member_id ORDER BY quantity_sold DESC) AS rank
FROM (SELECT member_id, 
	      	 EXTRACT(MONTH FROM txn_date) AS month,
	   		 SUM(quantity) AS quantity_sold
	  FROM transactions
	  WHERE ticker ~ 'ETH' AND
		    txn_type ~ 'SELL'
	  GROUP BY member_id, 
			   EXTRACT(MONTH FROM txn_date)) AS aux
ORDER BY member_id, month

)

SELECT member_id, month, 
       ROUND(quantity_sold::NUMERIC, 2) AS quantity_sold
FROM eth_sold
WHERE rank = 1
ORDER BY quantity_sold DESC;


