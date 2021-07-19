-- FULL JOIN

-- ALL rows of tables

SELECT attributes_selected
FROM nametable-- left table
FULL JOIN nametable
	ON matchstatement -- use match between primary key and foreign key
