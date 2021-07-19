-- LEFT JOIN Or LEFT OUTER JOIN

-- TableA 'unión' (TableA 'intercepción' TableB)

SELECT attributes_selected
FROM nametable-- left table
LEFT JOIN nametable
	ON matchstatement -- use match between primary key and foreign key
LEFT JOIN nametable
	ON matchstatement; -- use match between primary key and foreign key