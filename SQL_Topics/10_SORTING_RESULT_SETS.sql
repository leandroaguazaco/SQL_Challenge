-- SORTING RESULT SETS

-- ORDER BY atribute o column 

SELECT *
FROM author
ORDER BY author_id;

-- By default the result is sorted in ascending order

SELECT *
FROM author
WHERE country LIKE 'C%'
ORDER BY city DESC;

-- Specifying column sequence number

SELECT *
FROM author
ORDER BY 2 DESC;

