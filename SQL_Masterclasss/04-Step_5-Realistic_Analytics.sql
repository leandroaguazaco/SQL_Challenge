/* REALISTIC ANALYTICS */

SET SEARCH_PATH = sql_masterclass;

SELECT *
FROM transactions
LIMIT 10;

SELECT *
FROM members
LIMIT 5;

SELECT *
FROM prices
LIMIT 5;

/* Analyse the Ranges  */

-- Question 1:
-- What is the earliest and latest date of transactions for all members?

SELECT MAX(txn_date) AS lasted, 
	   MIN(txn_date) AS earliest
FROM transactions;

-- Questiion 2:
-- What is the range of market_date values available in the prices data?

SELECT MAX(market_date) AS lasted, 
	   MIN(market_date) AS earliest
FROM prices;

/* Join datasets */

-- Question 3:
-- Which top 3 mentors have the most Bitcoin quantity as of the 29th of August?

SELECT first_name, 
	   ROUND(SUM(CASE WHEN txn_type ~ 'SELL' THEN -quantity 
				 	  ELSE quantity 
				      END)::NUMERIC , 2) AS bitcoin_quantity
FROM transactions
LEFT JOIN members
	USING(member_id)
WHERE ticker ~ 'BTC'
GROUP BY first_name
ORDER BY bitcoin_quantity DESC
LIMIT 3;

/* Calculating Portffolio Value */

-- Quesiton 4:
-- What is total value of all Ethereum portfolios for each region at the end date of our analysis? 
-- Order the output by descending portfolio value

WITH aux AS (

SELECT ticker, price
FROM prices
WHERE ticker ~ 'ETH' AND
	  market_date = '2021-08-29'

)

SELECT region, 
	   ROUND((SUM(CASE WHEN txn_type ~ 'SELL' THEN -quantity
					   ELSE quantity
					   END) * price)::NUMERIC , 2) AS final_value, 
	   ROUND((AVG(CASE WHEN txn_type ~ 'SELL' THEN -quantity
				 	   ELSE quantity
				 	   END) * price)::NUMERIC , 2) AS avg_value
FROM transactions 
INNER JOIN aux
	USING(ticker)
INNER JOIN members
	USING(member_id)
GROUP BY region, price
ORDER BY avg_value DESC;

-- Question 5:
-- What is the average value of each Ethereum portfolio in each region? Sort this output in descending order

WITH eth_price AS (

SELECT ticker, price
FROM prices
WHERE ticker ~ 'ETH' AND
	  market_date = '2021-08-29'

)

SELECT region, final_value, members_count,
	   ROUND((final_value/members_count)::NUMERIC, 2) AS avg_value
FROM (
	SELECT region,
		   ROUND((SUM(CASE WHEN txn_type ~ 'SELL' THEN -quantity
						   ELSE quantity
						   END) * price)::NUMERIC , 2) AS final_value, 
		   COUNT(DISTINCT first_name) AS members_count	
	FROM transactions
	INNER JOIN eth_price
		USING(ticker)
	INNER JOIN members
		USING(member_id)
	GROUP BY region, price
	  ) AS aux3
ORDER BY avg_value DESC;

