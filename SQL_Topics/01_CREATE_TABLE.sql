CREATE TABLE public.author (
	author_id CHAR (2) PRIMARY KEY NOT NULL, 
	lastname VARCHAR (15) NOT NULL, 
	firstname VARCHAR (15) NOT NULL, 
	email VARCHAR (40), 
	city VARCHAR (15), 
	country CHAR (2)
);

CREATE TABLE public.author (
	author_id CHAR (2) NOT NULL, 
	lastname VARCHAR (15) NOT NULL, 
	firstname VARCHAR (15) NOT NULL, 
	email VARCHAR (40), 
	city VARCHAR (15), 
	country CHAR (2), 
	CONSTRAINT pk_prueba_2 PRIMARY KEY (author_id)
);

/*Existen diferentes formas para designar PRIMARY KEY*/
/*Al momento de crear la tabla se puede seleccionar el esquema al cual debe pertenecer la base de datos, declaración CREATE TABLE felipe.*/

CREATE TABLE plans (
	plan_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
	plan_name VARCHAR(13) NOT NULL,
	price DECIMAL(5, 2)
);