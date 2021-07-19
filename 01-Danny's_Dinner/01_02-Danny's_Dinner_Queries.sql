/* CASE STUDY QUESTIONS */

SET search_path = "01-dannys_diner";

-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id AS customer, SUM(me.price) AS total_spent
FROM sales AS s, menu AS me
WHERE s.product_id = me.product_id
GROUP BY customer_id
ORDER BY total_spent DESC;

-- Alternate
SELECT customer_id AS customer, SUM(price) AS total_spent
FROM sales
LEFT JOIN menu
	USING(product_id)
GROUP BY customer_id
ORDER BY total_spent DESC;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id AS customer, 
	   COUNT(DISTINCT order_date) AS visits
FROM sales
GROUP BY customer_id
ORDER BY customer, visits DESC;

-- 3. What was the first item from the menu purchased by each customer?

WITH items AS (SELECT customer_id AS customer,
	   				  product_name AS first_item, 
	                  RANK() OVER(PARTITION BY customer_id ORDER BY MIN(order_date)) posit
			   FROM sales
			   LEFT JOIN menu 
			   	  USING(product_id)
			   GROUP BY customer, product_name
			   ORDER BY customer)
SELECT customer, first_item
FROM items
WHERE posit = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name, purchases
FROM (SELECT product_id, COUNT(*) AS purchases
	  FROM sales
	  GROUP BY product_id
	  ORDER BY purchases DESC
	  LIMIT 1) AS aux
INNER JOIN menu
	USING(product_id)

-- 5. Which item was the most popular for each customer?

WITH aux AS (SELECT customer_id,
			 product_id,
	   		 COUNT(product_id) AS purchases,
	         RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) post
             FROM sales
			 GROUP BY customer_id, product_id)
SELECT customer_id, product_name
FROM aux
LEFT JOIN menu
	USING(product_id)
WHERE post = 1
ORDER BY customer_id;

-- 6. Which item was purchased first by the customer after they became a member?

SELECT customer_id, join_date, order_date, product_name
FROM (SELECT customer_id, order_date, join_date, product_name,
 			 RANK() OVER(PARTITION BY customer_id ORDER BY order_date) pos
	  FROM sales
	  LEFT JOIN members
		 USING(customer_id)
	  LEFT JOIN menu
		 USING(product_id)
	  WHERE join_date IS NOT NULL 
		    AND order_date > join_date
	  ORDER BY customer_id) AS aux
WHERE pos = 1;

-- 7. Which item was purchased just before the customer became a member?

SELECT customer_id, join_date, order_date, product_name
FROM (SELECT customer_id, order_date, join_date, product_name,
 			 RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) pos
	  FROM sales
	  LEFT JOIN members
		  USING(customer_id)
	  LEFT JOIN menu
		  USING(product_id)
	  WHERE join_date IS NOT NULL 
		    AND order_date < join_date
	  ORDER BY customer_id) AS aux
WHERE pos = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT customer_id, 
	   COUNT(product_name) AS total_items, 
	   SUM(price) AS amount_spent
FROM (SELECT customer_id, order_date, join_date, product_name, price
	  FROM sales
	  LEFT JOIN menu 
		  USING(product_id)
	  LEFT JOIN members
		  USING(customer_id)
	  WHERE join_date IS NOT NULL AND
		    order_date < join_date
	  ORDER BY customer_id) AS aux
GROUP BY customer_id;	 

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT customer_id, 
	   SUM(CASE WHEN product_name LIKE 'sushi' THEN  2*10*price
		        WHEN product_name NOT LIKE 'sushi' THEN 10*price
	   	   END) AS points
FROM sales
LEFT JOIN menu
	USING(product_id)
GROUP BY customer_id
ORDER BY points DESC;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH aux AS 
	   (SELECT customer_id, join_date, order_date, 
	           (order_date - join_date) AS diff,
	           product_name, price,
			   CASE WHEN ((order_date - join_date) BETWEEN 0 AND 7) THEN 2*10*price
					WHEN (((order_date - join_date) NOT BETWEEN 0 AND 7) AND product_name LIKE 'sushi') THEN 2*10*price
					WHEN (((order_date - join_date) NOT BETWEEN 0 AND 7) AND product_name NOT LIKE 'sushi') THEN 10*price
	           END AS points
	   FROM sales
	   LEFT JOIN members
	      USING(customer_id)
	   LEFT JOIN menu
		  USING(product_id)
	   WHERE join_date IS NOT NULL AND
			 DATE_PART('month', order_date) <= 1)
SELECT customer_id, SUM(points) AS total_points
FROM aux
GROUP BY customer_id
ORDER BY total_points DESC;

/* JOIN ALL THE THINGS */

SELECT customer_id, order_date, product_name, price,
	   CASE WHEN (order_date > join_date) THEN 'Y'
	        ELSE 'N' 
	   END AS member
FROM sales
LEFT JOIN menu
	USING(product_id)
LEFT JOIN members
	USING(customer_id)
ORDER BY customer_id, order_date;

/* RANKING ALL THE THINGS */

SELECT customer_id, order_date, product_name, price, member,   
	   CASE WHEN member LIKE 'Y' THEN RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
	   END AS ranking
FROM (SELECT customer_id, order_date, product_name, price,
	  CASE WHEN (order_date > join_date) THEN 'Y'
	       ELSE 'N' END AS member
	  FROM sales
	  LEFT JOIN menu
		  USING(product_id)
	  LEFT JOIN members
		  USING(customer_id)
	  ORDER BY customer_id, order_date) AS aux

