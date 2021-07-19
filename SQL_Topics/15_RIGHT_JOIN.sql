-- RIGHT JOIN OR RIGHT OUTER JOIN

SELECT attributes_selected
FROM nametable-- left table
RIGHT JOIN nametable
	ON matchstatement -- use match between primary key and foreign key
RIGHT JOIN nametable
	ON matchstatement; -- use match between primary key and foreign key