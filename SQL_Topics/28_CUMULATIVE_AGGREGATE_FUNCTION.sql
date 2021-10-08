
-- Cumulative aggrefate function: SUM()
-- Using window functions 

SELECT *,
	   SUM(month_balance) OVER(PARTITION BY customer_id ROWS   	   BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance
FROM table