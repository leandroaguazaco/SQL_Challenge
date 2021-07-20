SET search_path = "03-Foodie_Fi";

/* SECTION A - CUSTOMER JOURNEY */

SELECT *
FROM subscriptions
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19);

/* SECTION B - DATA ANALISYS QUESTIONS */

-- B.1 How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id)
FROM subscriptions;

-- B.2 What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT EXTRACT(month FROM start_date) AS month, 
	   COUNT(*) AS trial_subsc 
FROM subscriptions
WHERE plan_id = 0
GROUP BY month
ORDER BY month;

-- B.3 What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT plan_name, COUNT(*) AS subsc
FROM subscriptions
INNER JOIN plans
	USING(plan_id)
WHERE EXTRACT(year FROM start_date) > 2020
GROUP BY plan_name
ORDER BY subsc DESC;

-- B.4 What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT COUNT(plan_id), 
	   ROUND(COUNT(plan_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id)
							           FROM subscriptions), 2) AS percentage
FROM subscriptions
WHERE plan_id = 4;

-- B.5 How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

CREATE TEMP TABLE customers AS (
	SELECT *
	FROM subscriptions
	WHERE customer_id IN (SELECT customer_id
						  FROM subscriptions
						  WHERE plan_id IN (0, 4)
						  GROUP BY customer_id
						  HAVING COUNT(*) > 1
						  ORDER BY customer_id) AND
		  plan_id IN (0, 4)
)

SELECT COUNT(*) AS subscribers, 
	   ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) 
								 FROM subscriptions), 2) AS percentage
FROM (SELECT c1.customer_id, (c1.start_date - c2.start_date) AS diff
	  FROM customers AS c1
	  INNER JOIN customers AS c2
	  	  USING(customer_id)
	  WHERE c1.plan_id > c2.plan_id) AS aux
WHERE diff = 7;

-- B.6 What is the number and percentage of customer plans after their initial free trial?

SELECT plan_name, COUNT(*) AS number, ROUND(COUNT(*)/10.0, 2) AS percentage
FROM (SELECT *,
	         RANK() OVER(PARTITION BY customer_id ORDER BY start_date) AS rank
      FROM subscriptions
      WHERE plan_id != 0
      ORDER BY customer_id) AS aux
INNER JOIN plans
	USING(plan_id)
WHERE rank = 1
GROUP BY plan_name
ORDER BY number DESC;

-- B.7 What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH positions AS ( 
	SELECT *,
		   RANK() OVER(PARTITION BY customer_id ORDER BY start_date DESC) AS rank 
	FROM subscriptions       
	INNER JOIN plans
		USING(plan_id)
	WHERE start_date <= DATE '2020-12-31'
)

SELECT plan_name, COUNT(*) AS customers, ROUND(COUNT(*)/10.0 , 2) AS percentage
FROM positions
WHERE rank = 1
GROUP BY plan_name
ORDER BY customers DESC;

-- B.8 How many customers have upgraded to an annual plan in 2020?

SELECT COUNT(*)
FROM subscriptions
WHERE EXTRACT(year FROM start_date) = 2020 AND
	  plan_id = 3;

-- B.9 How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH aux1 AS ( 
	 SELECT *
	 FROM subscriptions AS c1
	 WHERE plan_id = 3), 
	 
	 aux2 AS ( 
	 SELECT *
	 FROM subscriptions AS c1
	 WHERE plan_id = 0)
	
SELECT ROUND(AVG(aux1.start_date - aux2.start_date), 2) AS avg
FROM aux1 
LEFT JOIN aux2
	USING(customer_id);

-- B.10 Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH aux1 AS ( 
	 SELECT *
	 FROM subscriptions AS c1
	 WHERE plan_id = 3), 
	 
	 aux2 AS ( 
	 SELECT *
	 FROM subscriptions AS c1
	 WHERE plan_id = 0)

SELECT CASE WHEN (aux1.start_date - aux2.start_date) BETWEEN 0 AND 30 THEN '0-30'
			WHEN (aux1.start_date - aux2.start_date) BETWEEN 31 AND 60 THEN '31-60'
			WHEN (aux1.start_date - aux2.start_date) BETWEEN 61 AND 90 THEN '61-90'
			WHEN (aux1.start_date - aux2.start_date) BETWEEN 91 AND 120 THEN '91-120'
			WHEN (aux1.start_date - aux2.start_date) BETWEEN 121 AND 150 THEN '121-150'
			WHEN (aux1.start_date - aux2.start_date) BETWEEN 151 AND 180 THEN '151-180'
			WHEN (aux1.start_date - aux2.start_date) BETWEEN 181 AND 210 THEN '181-210'
			WHEN (aux1.start_date - aux2.start_date) BETWEEN 211 AND 240 THEN '211-240'
			WHEN (aux1.start_date - aux2.start_date) BETWEEN 241 AND 270 THEN '241-270'
			WHEN (aux1.start_date - aux2.start_date) BETWEEN 271 AND 300 THEN '271-300'
			WHEN (aux1.start_date - aux2.start_date) BETWEEN 301 AND 330 THEN '301-330'
			ELSE '>330' END AS range, 
			COUNT(*) AS days
FROM aux1 
LEFT JOIN aux2
	USING(customer_id)
GROUP BY range
ORDER BY days DESC;

-- B.11 How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

SELECT COUNT(*)
FROM (SELECT customer_id, 
	         ARRAY_TO_STRING(ARRAY_AGG(plan_id ORDER BY rank), ',') AS plan_hist
      FROM (SELECT *, 
			       RANK() OVER(PARTITION BY customer_id ORDER BY start_date) AS rank
            FROM subscriptions
	        WHERE EXTRACT(year FROM start_date) = 2020) AS aux
      GROUP BY customer_id) AS aux2
WHERE plan_hist ~ '.*(2,1).*';

/* SECTION C - CHALLENGE PAYMENT QUESTION */

SELECT customer_id, plan_id, plan_name, start_date, price
FROM subscriptions
INNER JOIN plans
	USING(plan_id);

