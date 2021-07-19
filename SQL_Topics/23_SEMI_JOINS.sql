-- SEMI JOINS

-- Use a right table to determine which records to keep in the left table, similar to WHERE clause dependent on the values of a second table

SELECT president, country, continent
FROM presidents
WHERE country IN 
	(SELECT country
	 FROM states
	 WHERE indep_year < 1800)

-- A query that sits inside another query

-- Select distinct fields
SELECT DISTINCT name
  -- From languages
  FROM languages
-- Where in statement
WHERE code IN
  -- Subquery
  (SELECT code
   FROM countries
   WHERE region = 'Middle East')
-- Order by name
ORDER BY name;