-- SELECT statement

-- Select all table

SELECT *  
FROM author;

-- Select multiple atributes by column names

SELECT author_id, firstname, city 
FROM author;

-- Where clause comparison operator 

SELECT author_id, lastname, email
FROM author
WHERE city = 'Toronto';

SELECT author_id, country
FROM author
WHERE author_id = 'A1';

SELECT lastname, firstname
FROM author
WHERE author_id = 'A1' or city = 'Toronto';