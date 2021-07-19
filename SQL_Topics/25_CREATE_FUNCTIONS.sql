-- Create a function to calculate differences between two arrays
CREATE OR REPLACE FUNCTION ARRAY_DIFF(array1 anyarray, array2 anyarray)
	RETURNS anyarray 
	LANGUAGE SQL 
	IMMUTABLE 
AS $BODY$ SELECT COALESCE(ARRAY_AGG(elem), '{}')
		  FROM UNNEST(array1::INTEGER[]) AS elem
		  WHERE elem <> ALL(array2::INTEGER[]) 
   $BODY$;

-- Import module
CREATE EXTENSION IF NOT EXISTS intarray; -- dowload module intarray
DROP EXTENSION intarray; -- delete modul