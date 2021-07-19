-- ANTI JOINS

-- Chooses records in the first table where a condition IS NOT met in the second table

SELECT president, country, continent
FROM presidents
WHERE country NOT IN 
	(SELECT country
	 FROM states
	 WHERE indep_year < 1800)

-- A query that sits inside another query

