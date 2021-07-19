-- STRINGS PATTERNS

-- LIKE predicate: seleccionar a través de los carácteres de un string

-- Seleccionar firstnames que comiencen con la letra 'R'
SELECT firstname
FROM author
WHERE firstname LIKE 'R%';

SELECT *
FROM author
WHERE city LIKE 'T%';

-- LIKE es el predicado empleado para buscar un patrón en una columna o atributo 
-- % WILCARD CHARACTER, corresponde a carácteres perdidos

-- R% 'INICIANDO' AFTER THE PATTERN: seleccinar email y country, de la relación author, donde lastname comienza con 'Ag'
SELECT email, country
FROM author
WHERE lastname LIKE 'Ag%'; -- la seleccion es sensible al uso de mayúsculas y minúsculas A != a

-- %R 'TERMINANDO' BEFORE the pattern: seleccionar author_id y firstname donde el nombre de la ciudad termina en letra a
SELECT author_id, firstname
FROM author
WHERE city LIKE '%a'; 

-- %R% BOTH BEFORE AND AFTER THE PATTERN o que contenga en cualquier posición exceptuando el inicio o final
SELECT *
FROM author
WHERE city LIKE '%j%';

