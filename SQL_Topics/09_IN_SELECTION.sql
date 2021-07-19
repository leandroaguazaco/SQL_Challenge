-- IN selection 

-- Retriving rows using a set of values

SELECT *
FROM author
WHERE country IN ('CO', 'CA');

-- the last is the same than

SELECT *
FROM author
WHERE country = 'CO' OR country = 'CA';