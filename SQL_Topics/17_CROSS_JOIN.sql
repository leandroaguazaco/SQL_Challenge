-- CROSS JOIN
-- ALL POSSIBLE COMBINATION BETWEEN TABLES
SELECT attributes_selected
FROM nametable-- left table
CROSS JOIN nametable
	ON matchstatement -- use match between primary key and foreign key
