-- EXCEPT

-- Allows you to include only the records that are in one table, but not the other.

-- Only the records that apper in the left table BUT DO NOT apper in the right table are included.

SELECT name
    FROM cities
	EXCEPT
SELECT capital
    FROM countries;