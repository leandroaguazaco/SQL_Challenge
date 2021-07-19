-- DELETE FROM statement 

DELETE FROM author 
WHERE author_id ='A2';

DELETE FROM author 
WHERE author_id IN ('A1', 'A3');

SELECT *
FROM author;

-- Delete a table

DROP TABLE author