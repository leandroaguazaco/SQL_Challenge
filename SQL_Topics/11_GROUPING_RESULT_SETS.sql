-- GROUPING RESULTS SETS

SELECT DISTINCT country -- Select distinct atributes
FROM author;

SELECT country
FROM author
GROUP BY country;

SELECT country, COUNT (country) AS conteo
FROM author
GROUP BY country;

-- Add condition by 'HAVING' keyword, it work only with 'GROUP BY' clause

SELECT country AS pais, COUNT (country) AS conteo -- AS keyword proporciona un nombre a la columna o campo
FROM author
GROUP BY country
HAVING COUNT (country) < 2;
