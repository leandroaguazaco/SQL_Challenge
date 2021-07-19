-- INSERT statement
-- Agregar filas a una tabla después de haber sido creada

-- Insert simple rows

INSERT INTO author 
(author_id, lastname, firstname, email, city, country)
VALUES 
('A1', 'Chong', 'Raul', 'rfc@IBM.com', 'Toronto', 'CA');

INSERT INTO author
(author_id, lastname, firstname, email, city, country)
VALUES 
('A2', 'Ahuja', 'Rav', 'ra@IMB.com', 'Toronto', 'CA');

-- Delete a row

DELETE FROM author
WHERE author_id = 'A2';

-- Select all table

select * from author;

-- Insert multiple rows

INSERT INTO author
(author_id, lastname, firstname, email, city, country)
VALUES 
('A3', 'Aguazaco', 'Leandro', 'flar@IMB.com', 'Tunja', 'CO'),
('A4', 'Rodríguez', 'Felipe', 'fel@IMB.com', 'Buenos Aires', 'AR');
