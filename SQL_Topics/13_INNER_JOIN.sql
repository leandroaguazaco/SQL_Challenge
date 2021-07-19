-- INNER_JOIN

-- corresponds to intercept, in both tables
-- Entidades que están en A y B

SELECT attributes_selected -- an alias can be used to identifying tables
FROM nametable 
INNER JOIN nametable 
	ON matchstatement -- use match between primary key and foreign key
INNER JOIN nametable 
	ON matchstatement -- aggregate more tables and match statements