SET SEARCH_PATH = "04-data_bank";

/* SECTION A: Customer Nodes Exploration */

-- A1. How many unique nodes are there on the Data Bank system?

-- Alternative 1
SELECT COUNT(DISTINCT node_id) AS nodes
FROM customer_nodes;

-- Alternative 2
SELECT COUNT(DISTINCT node_id) * COUNT(DISTINCT region_id) AS unique_nodes
FROM customer_nodes;

-- A2. What is the number of nodes per region?

SELECT region_id, COUNT(DISTINCT node_id) AS node
FROM customer_nodes
GROUP BY region_id
ORDER BY region_id;

-- A3. How many customers are allocated to each region?

SELECT region_id, COUNT(DISTINCT customer_id) AS customers
FROM customer_nodes
GROUP BY region_id
ORDER BY region_id;

-- A4. How many days on average are customers reallocated to a different node?

SELECT * -- Identifying rows with errors in dates
FROM customer_nodes
WHERE EXTRACT(YEAR FROM end_date) = 9999;

ALTER TABLE customer_nodes -- Change the colum type from DATE to text (VARCHAR)
ALTER COLUMN end_date
SET DATA TYPE VARCHAR;

SELECT *
FROM customer_nodes
WHERE end_date ~ '^9.+';

UPDATE customer_nodes -- Update end date from rows where error was identified
SET end_date = REGEXP_REPLACE(end_date, '9999', '2020')
WHERE end_date ~ '^9{4}';

ALTER TABLE customer_nodes
ALTER COLUMN end_date
SET DATA TYPE DATE USING end_date::DATE; -- Implicit conversion

-- Alternative 1: 
SELECT ROUND(AVG(end_date - start_date), 2) AS avg_reallocated_days
FROM customer_nodes;

-- Alternative 2:
SELECT ROUND(AVG(avg_by_customer), 2) AS avg_reallocated_days
FROM (SELECT customer_id, 
		     AVG(end_date - start_date) OVER(PARTITION BY customer_id) AS avg_by_customer
	  FROM customer_nodes) AS aux;

-- A5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

SELECT region_id, 
	   PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY reallocation_days) AS media,
	   PERCENTILE_DISC(0.8) WITHIN GROUP (ORDER BY reallocation_days) AS "80th_percentile",
	   PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY reallocation_days) AS "95th_percentile"
FROM (SELECT region_id,
	 		 (end_date - start_date) AS reallocation_days
	  FROM customer_nodes) AS aux
GROUP BY region_id;

/* SECTION B. Customer Transactions */

-- 1. What is the unique count and total amount for each transaction type?

SELECT txn_type, COUNT(*) AS unique_count, SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type
ORDER BY unique_count, total_amount;

-- 2. What is the average total historical deposit counts and amounts for all customers?

SELECT ROUND(AVG(total_count), 2) AS avg_total_count, -- average for all customers
	   ROUND(AVG(total_amount), 2) AS avg_total_amount
FROM (SELECT customer_id, -- average deposit and amount by customer
	   		 COUNT(txn_type) AS total_count, 
	   		 SUM(txn_amount) AS total_amount
	  FROM customer_transactions
	  WHERE txn_type LIKE 'deposit'
	  GROUP BY customer_id
	  ORDER BY total_count DESC, total_amount DESC) AS aux;

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH custom_table AS (
SELECT txn_month, 
	   customer_id,
	   ARRAY_AGG(txn_type)::VARCHAR(50) AS tnx_make
FROM (SELECT customer_id,  
	         EXTRACT(MONTH FROM txn_date) AS txn_month, 
	         txn_type, 
	         COUNT(txn_type) AS transactions
      FROM customer_transactions
      GROUP BY customer_id,  
	  	       EXTRACT(MONTH FROM txn_date), 
	           txn_type
      HAVING (txn_type ~ 'deposit' AND COUNT(txn_type) > 1) OR
	         (txn_type IN ('purchase', 'withdrawal') AND COUNT(txn_type) = 1)) AS aux1
GROUP BY txn_month, customer_id
HAVING ARRAY_AGG(txn_type)::VARCHAR(50) IN ('{deposit,purchase}', 
										    '{purchase,deposit}', 
										    '{deposit,withdrawal}', 
										    '{withdrawal,deposit}', 
										    '{deposit,purchase,withdrawal}', 
										    '{deposit,withdrawal,purchase}', 
										    '{withdrawal,deposit,purchase}',
										    '{purchase,deposit,withdrawal}',
										    '{purchase,withdrawal,deposit}', 
										    '{withdrawal,purchase,desposit}')
ORDER BY txn_month, customer_id)

SELECT txn_month, COUNT(customer_id) AS customers
FROM custom_table
GROUP BY txn_month
ORDER BY txn_month;

-- 4. What is the closing balance for each customer at the end of the each month?

CREATE TEMP TABLE balance AS (
WITH deposits AS (
SELECT customer_id, -- Total deposits by month
       EXTRACT(MONTH FROM txn_date) AS txn_month, 
       SUM(txn_amount) AS total_deposits
FROM customer_transactions
WHERE txn_type ~ 'deposit'
GROUP BY customer_id, EXTRACT(MONTH FROM txn_date)
ORDER BY customer_id, txn_month),

	 withdrawls AS (
SELECT customer_id,  -- Total purchases and withdrawls by month
       EXTRACT(MONTH FROM txn_date) AS txn_month,
	   SUM(txn_amount) AS total_withdrawls
FROM customer_transactions
WHERE txn_type IN ('purchase', 'withdrawal')
GROUP BY customer_id, EXTRACT(MONTH FROM txn_date)
ORDER BY customer_id, txn_month)

SELECT customer_id, txn_month, total_deposits, total_withdrawls
FROM deposits
FULL JOIN withdrawls
	USING(customer_id, txn_month)
);

UPDATE balance -- Deleting null values, to run once
SET total_deposits = 0
WHERE total_deposits IS NULL;

UPDATE balance -- Deleting null values, to run once
SET total_withdrawls = 0
WHERE total_withdrawls IS NULL;

-- Using cumulative sum
SELECT customer_id, txn_month, total_deposits, total_withdrawls, month_balance,
	   SUM(month_balance) OVER(PARTITION BY customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance
FROM (
SELECT *, (total_deposits - total_withdrawls) AS month_balance
FROM balance
ORDER BY customer_id, txn_month
) AS aux3;

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?


