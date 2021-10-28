/* 01-Step_2-Members_Data */

SET SEARCH_PATH = sql_masterclass;

-- Question 1: Show only the top 5 rows from the trading.members table

SELECT *
FROM members
LIMIT 5;

-- Question 2: Sort all the rows in the table by first_name in alphabetical order and show the top 3 rows

SELECT *
FROM members
ORDER BY first_name
LIMIT 3;

-- Question 3: Which records from trading.members are from the United States region?

SELECT *
FROM members
WHERE region ~ 'United States';

-- Question 4: Select only the member_id and first_name columns for members who are not from Australia

SELECT member_id, first_name
FROM members
WHERE region !~ 'Australia';

-- Question 5: Return the unique region values from the trading.members table and sort the output by reverse alphabetical order

SELECT DISTINCT region
FROM members
ORDER BY region DESC;

-- Question 6: How many mentors are there from Australia or the United States?

SELECT COUNT(*) AS mentor_count
FROM members
WHERE region IN ('Australia', 'United States');

-- Question 7: How many mentors are not from Australia or the United States?

SELECT COUNT(*) AS mentor_count
FROM members
WHERE region NOT IN ('Australia', 'United States');

-- Question 8: How many mentors are there per region? Sort the output by regions with the most mentors to the least

SELECT region, COUNT(*) AS mentor_count
FROM members
GROUP BY region
ORDER BY mentor_count DESC;

-- Question 9: How many US mentors and non US mentors are there?

WITH aux AS (
SELECT *,
	   CASE WHEN region ~ 'United States' THEN 'US'
	   		ELSE 'Non US'
	   END AS origin
FROM members)

SELECT origin, COUNT(*) AS mentor_count
FROM aux
GROUP BY origin;

-- Question 10: How many mentors have a first name starting with a letter before 'E'?

SELECT COUNT(*) AS mentor_count
FROM members
WHERE first_name ~* '.*E.*';



