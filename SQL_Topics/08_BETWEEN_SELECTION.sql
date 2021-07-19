-- RANGE SELECTION 

-- BETWEEN -- AND -- compares two values

SELECT *
FROM author 
WHERE pages >= 290 AND pages <= 300

-- Is the same that above

SELECT *
FROM author
WHERE pages BETWEEN 290 AND 300