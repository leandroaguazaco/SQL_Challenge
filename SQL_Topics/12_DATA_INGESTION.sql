-- DATA INGESTION

-- Load data from .csv file

COPY 
departments(dept_id_dep, dep_name, manager_id, loc_id) -- table name (attributes)
FROM 'D:\Archivo Personal\Cursos\SQL\Lab3' -- local location files
DELIMITER ',' -- delimiter's type
CSV HEADER; -- Optional, not necessary if the origin file dosen't contanin column names