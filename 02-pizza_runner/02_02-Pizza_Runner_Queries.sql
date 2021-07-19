/* CASE STUDY QUESTIONS */

SET search_path = "02-pizza_runner";

-- A.Pizza Metrics

-- A1.How many pizzas were ordered?

SELECT COUNT(*) AS pizzas_ordered
FROM customer_orders;

-- A2.How many unique customer orders were made?

SELECT COUNT(DISTINCT customer_id) AS unique_customer_orders
FROM customer_orders;

-- A3.How many successful orders were delivered by each runner?

UPDATE runner_orders -- Auxiliary
SET cancellation = NULL
WHERE cancelLation NOT IN ('Restaurant Cancellation', 'Customer Cancellation');

SELECT runner_id, COUNT(*) AS successful_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- A4.How many of each type of pizza was delivered?

SELECT pizza_id, pizza_name, COUNT(*) AS delivers
FROM customer_orders
LEFT JOIN runner_orders
	USING(order_id)
LEFT JOIN pizza_names
	USING(pizza_id)
WHERE cancellation IS NULL
GROUP BY pizza_id, pizza_name;

-- A5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, pizza_name, COUNT(*) AS orders
FROM customer_orders
INNER JOIN pizza_names
	USING(pizza_id)
GROUP BY customer_id, pizza_name
ORDER BY customer_id;

-- A6.What was the maximum number of pizzas delivered in a single order?

SELECT MAX(maximun_pizzas) as max_number_pizzas_delivered
FROM (SELECT order_id, COUNT(*) AS maximun_pizzas
	 FROM customer_orders
	 LEFT JOIN runner_orders
		 USING(order_id)
	 WHERE cancellation IS NULL
	 GROUP BY order_id
	 ORDER BY order_id) AS aux;

-- A7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

UPDATE customer_orders -- Auxiliary
SET exclusions = NULL
WHERE exclusions IN ('', 'null');

UPDATE customer_orders -- Auxiliary
SET extras = NULL
WHERE extras IN ('', 'null');

/*CREATE TABLE customer_orders_modified AS -- Auxiliary
	(SELECT order_id, customer_id, pizza_id, exclusions_m::INTEGER, extras_m::INTEGER, order_date
	FROM customer_orders
	LEFT JOIN LATERAL UNNEST(STRING_TO_ARRAY(exclusions, ', ')) AS exclusions_m ON TRUE
	LEFT JOIN LATERAL UNNEST(STRING_TO_ARRAY(extras, ', ')) AS extras_m ON TRUE
	ORDER BY order_id);*/

CREATE TEMP TABLE changes AS (SELECT customer_id, COUNT(*) AS pizzas_least_1_change
							  FROM customer_orders
							  INNER JOIN runner_orders
								  USING(order_id)
							  WHERE cancellation IS NULL AND
								    (exclusions IS NOT NULL OR extras IS NOT NULL)
							  GROUP BY customer_id)

CREATE TEMP TABLE no_changes AS (SELECT customer_id, COUNT(*) AS pizzas_without_changes
							     FROM customer_orders
							     INNER JOIN runner_orders
							     USING(order_id)
							     WHERE cancellation IS NULL AND
									   exclusions IS NULL AND
									   extras IS NULL
							     GROUP BY customer_id)

INSERT INTO changes
	(customer_id, pizzas_least_1_change)
VALUES 
	(101, NULL),
	(102, NULL)

SELECT *
FROM changes
LEFT JOIN no_changes
	USING(customer_id)
ORDER BY customer_id;
		 
-- A8.How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) AS pizzas
FROM customer_orders
LEFT JOIN runner_orders
	USING(order_id)
WHERE cancellation IS NULL AND
	  exclusions IS NOT NULL AND
	  extras IS NOT NULL;

-- A9.What was the total volume of pizzas ordered for each hour of the day?

SELECT EXTRACT(HOUR FROM order_date) AS order_hour, 
	   COUNT(*) AS pizzas_ordered
FROM customer_orders
GROUP BY order_hour
ORDER BY pizzas_ordered DESC;

-- A10.What was the volume of orders for each day of the week?

SELECT CASE WHEN order_day = 0 THEN 'Sunday'
	   		WHEN order_day = 1 THEN 'Monday'
			WHEN order_day = 2 THEN 'Tuesday'
			WHEN order_day = 3 THEN 'Wednesday'
			WHEN order_day = 4 THEN 'Thursday'
			WHEN order_day = 5 THEN 'Friday'
	        ELSE 'Saturday' END AS name_day, 
		pizzas_ordered
FROM (SELECT EXTRACT(DOW FROM order_date) AS order_day, 
	         COUNT(*) AS pizzas_ordered
	  FROM customer_orders
	  GROUP BY order_day
	  ORDER BY order_day) AS aux;

-- B.Runner and Customer Experience

UPDATE runner_orders -- Auxiliary
SET distance = NULL
WHERE distance = 'null';

UPDATE runner_orders -- Auxiliary
SET pickup_time = NULL
WHERE pickup_time = 'null';

UPDATE runner_orders -- Auxiliary
SET duration = NULL
WHERE duration = 'null';

SELECT REGEXP_REPLACE(
	   		REGEXP_REPLACE(
				 REGEXP_REPLACE(duration, 'mins', ''), 'minute', ''), 's', '')
FROM runner_orders;

-- the same as the previuos 

SELECT  * --duration, REGEXP_REPLACE(duration, '[a-z]', '', 'g')
FROM runner_orders;

CREATE TABLE runner_orders_modified AS 
	(SELECT order_id, runner_id, 
	 		pickup_time::TIMESTAMP, 
	 		distance_kms::NUMERIC,
	 		duration_mins::NUMERIC, 
	 		cancellation
	FROM runner_orders
	LEFT JOIN LATERAL REGEXP_REPLACE(distance, '[a-z]', '', 'g') AS distance_kms ON TRUE
	LEFT JOIN LATERAL REGEXP_REPLACE(duration, '[a-z]', '', 'g') AS duration_mins ON TRUE);

-- B.1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT CASE WHEN day_registration BETWEEN 1 AND 7 THEN 1
			WHEN day_registration BETWEEN 8 AND 14 THEN 2
	        ELSE 3 END AS week,
	   COUNT(*) AS runners_signedup
FROM (SELECT registration_date, 
	         EXTRACT(DAY FROM registration_date) AS day_registration
      FROM runners) AS aux
GROUP BY week
ORDER BY week;

-- B.2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT runner_id, AVG(DISTINCT(diff_time)) AS avg_time_arrive
FROM (SELECT order_id, runner_id, customer_id, distance_kms, 
	         duration_mins, order_date, pickup_time,
	         (pickup_time - order_date) AS diff_time
      FROM runner_orders_modified
      RIGHT JOIN customer_orders
	  	 USING(order_id)
      WHERE pickup_time IS NOT NULL 
      ORDER BY runner_id) AS aux
WHERE diff_time > INTERVAL '00:00:00' -- Revisar
GROUP BY runner_id;

SELECT TIMESTAMP '2020-01-02 12:12:37' - TIMESTAMP '2020-01-02 11:51:23';
SELECT TIMESTAMP '2019-09-26 00:12:27' - INTERVAL '00 hr, 51 min, 23 s';

-- B.3 Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- B.4 What was the average distance travelled for each runner?

SELECT runner_id, ROUND(AVG(distance_kms), 2) AS avg_distance_kms
FROM runner_orders_modified
GROUP BY runner_id; 

-- B.5 What was the difference between the longest and shortest delivery times for all orders?

SELECT (MAX(duration_mins) - MIN(duration_mins)) AS diff_mins
FROM runner_orders_modified;

-- B.6 What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT order_id, runner_id, ROUND((distance_kms)/(duration_mins/60), 2) AS speed_km_hr
FROM runner_orders_modified
WHERE distance_kms IS NOT NULL
ORDER BY runner_id, order_id;

-- B.7 What is the successful delivery percentage for each runner?

SELECT runner_id, ROUND((COUNT(duration_mins)::NUMERIC(2)/COUNT(*))*100, 2) AS percentage
FROM runner_orders_modified
GROUP BY runner_id;

-- C. Ingredient Optimisation

-- C.1 What are the standard ingredients for each pizza?

WITH ingredients AS 
	 (SELECT pizza_id, UNNEST(STRING_TO_ARRAY(toppings, ','))::INTEGER AS toppings
	  FROM pizza_recipes)
SELECT pizza_id, pizza_name, toppings, topping_name
FROM ingredients
LEFT JOIN pizza_names
	USING(pizza_id)
LEFT JOIN pizza_toppings 
	ON toppings = topping_id
ORDER BY pizza_id, toppings;

-- C.2 What was the most commonly added extra?

SELECT topping_name AS most_commonly_extra, COUNT(*) 
FROM (SELECT UNNEST(STRING_TO_ARRAY(extras, ','))::INTEGER AS ingr_extras
	  FROM customer_orders) AS aux
LEFT JOIN pizza_toppings 
	ON ingr_extras = topping_id
GROUP BY topping_name
ORDER BY COUNT(*) DESC
LIMIT 1;

-- C.3 What was the most common exclusion?

SELECT topping_name AS most_comon_exclusion, COUNT(*)
FROM (SELECT UNNEST(STRING_TO_ARRAY(exclusions, ','))::INTEGER AS ingr_excluded
      FROM customer_orders) AS aux
LEFT JOIN pizza_toppings
	ON ingr_excluded = topping_id
GROUP BY topping_name
ORDER BY COUNT(*) DESC
LIMIT 1;

-- C.4 Generate an order item for each record in the customers_orders table in the format of one of the following:

-- Meat Lovers
SELECT *, 
	   CASE WHEN pizza_id = 1 THEN ROW_NUMBER() OVER(PARTITION BY pizza_id)
	   		ELSE 0 END AS item 
FROM customer_orders;

-- Meat Lovers - Extra Bacon
SELECT *,
       CASE WHEN pizza_id = 1 AND (extras ~ '(^1)|(.+1.+)|(1$)') THEN DENSE_RANK() OVER(PARTITION BY pizza_id ORDER BY order_date)
	   ELSE 0 END AS item
FROM customer_orders;

-- C.5 Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- C.5.1 Create a function to calculate differences between two arrays
CREATE OR REPLACE FUNCTION ARRAY_DIFF(array1 anyarray, array2 anyarray)
	RETURNS anyarray 
	LANGUAGE SQL 
	IMMUTABLE 
AS $BODY$ SELECT COALESCE(ARRAY_AGG(elem), '{}')
		  FROM UNNEST(array1::INTEGER[]) AS elem
		  WHERE elem <> ALL(array2::INTEGER[]) $BODY$;

-- C.5.2 Import module
CREATE EXTENSION IF NOT EXISTS intarray; -- dowload module intarray
DROP EXTENSION intarray; -- delete module

-- C.5.3 Getting a function to aggregate toppings id in unique array by each order
CREATE TEMP TABLE IF NOT EXISTS customer_orders_temp AS (
WITH aux AS (
SELECT order_id, customer_id, pizza_id, toppings, exclusions, extras, toppings || extras AS recipes
FROM (SELECT order_id, customer_id, pizza_id, 
			 STRING_TO_ARRAY(toppings, ',')::INTEGER[] AS toppings,
			 STRING_TO_ARRAY(exclusions, ',')::INTEGER[] AS exclusions,
			 STRING_TO_ARRAY(extras, ',')::INTEGER[] AS extras
	  FROM customer_orders
	  LEFT JOIN pizza_recipes
	  		USING(pizza_id)) AS aux)
	
SELECT order_id, customer_id, pizza_id, toppings, exclusions, extras,
	   SORT(CASE WHEN exclusions IS NOT NULL THEN ARRAY_DIFF(recipes, exclusions) -- Sort is a function from imported module "intarray"
				 ELSE recipes END) AS final_recipes
FROM aux);

-- C.5.4 
CREATE OR REPLACE FUNCTION RECIPE(array1 anyarray)
	RETURNS TEXT
	LANGUAGE SQL 
	IMMUTABLE 
AS $BODY$ SELECT ARRAY_TO_STRING(ARRAY_AGG(CASE WHEN numb_ext > 1 THEN (numb_ext || 'x' || topping_name)
												ELSE topping_name 
												END), ', ') AS recipe
		  FROM (SELECT topping_name, COUNT(*) AS numb_ext
			    FROM UNNEST(array1::INTEGER[]) AS id_top
			    LEFT JOIN pizza_toppings
				    ON topping_id = id_top
			    GROUP BY topping_name
			    ORDER BY topping_name) AS aux 
	$BODY$;

-- C.5.5
SELECT order_id, customer_id, pizza_id, exclusions, extras, final_recipes,
	   CASE WHEN pizza_id = 1 THEN ('Meat Lovers: ' || RECIPE(final_recipes))
	   		ELSE ('Vegetarian: ' || RECIPE(final_recipes)) END AS recipe_text
FROM customer_orders_temp;

-- C.6 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

SELECT topping_name, COUNT(*) AS portions
FROM (SELECT order_id, UNNEST(final_recipes) AS final_recipes
	  FROM customer_orders_temp) AS aux
LEFT JOIN pizza_toppings 
	ON final_recipes = topping_id
LEFT JOIN runner_orders
	USING(order_id)
WHERE cancellation IS NULL
GROUP BY topping_name
ORDER BY portions DESC;

-- D. Pricing and Ratings

-- D.1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT SUM(CASE WHEN pizza_id = 1 THEN 12
		   		ELSE 10
		   		END) AS total_money
FROM customer_orders
LEFT JOIN runner_orders
	USING(order_id)
WHERE cancellation IS NULL;

-- D.2 What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra.

SELECT SUM(CASE WHEN pizza_id = 1 AND extras ~ '(.*4.*)' THEN 13 
			    WHEN pizza_id = 2 AND extras ~ '(.*4.*)' THEN 11 
			    WHEN pizza_id = 1 THEN 12
			    WHEN pizza_id = 2 THEN 10
			    END) AS cost
FROM customer_orders
LEFT JOIN runner_orders
	USING(order_id)
WHERE cancellation IS NULL;

-- D.3 

CREATE TABLE ratings (
	order_id INTEGER,
	rating INTEGER CHECK(rating BETWEEN 1 AND 5)
);

INSERT INTO ratings
	(order_id, rating)
VALUES
	(1, 2), 
	(2, 2), 
	(3, 4), 
	(4, 3),
	(5, 5), 
	(6, NULL),
	(7, 3),
	(8, 1),
	(9, NULL),
	(10, 1);

SELECT *
FROM ratings;

-- D.4

SELECT order_id, customer_id, runner_id, rating, order_date, pickup_time, 
	   (pickup_time - order_date) AS Time_between_order_pickup,
	   duration_mins, 
	   ROUND((distance_kms/(duration_mins/60)), 2) AS avg_speed_km_hr,
	   total_pizzas
FROM (SELECT order_id, rating, customer_id, order_date, 
	  		 COUNT(pizza_id) AS total_pizzas
      FROM customer_orders
      LEFT JOIN ratings
	      USING(order_id)
      GROUP BY order_id, rating, customer_id, order_date
      ORDER BY order_id) as aux
LEFT JOIN runner_orders_modified
	USING(order_id)
ORDER BY order_id;

-- D.5

SELECT SUM(cost) AS total_money
FROM (SELECT order_id,
		     SUM(CASE WHEN pizza_id = 1 THEN 12 
				 	  ELSE 10 END) - distance_kms*0.3 AS cost	   
	  FROM customer_orders
	  LEFT JOIN runner_orders_modified
		  USING(order_id)
	  WHERE cancellation IS NULL
	  GROUP BY order_id, distance_kms) AS aux;

