CREATE SCHEMA picking_survey_group;

SET SEARCH_PATH = picking_survey_group;

CREATE TABLE users_devices (
	user_id INTEGER NOT NULL,
	devices TEXT[], -- Declaration of Arrays types
	device_ids INTEGER[],
	user_create_time INTEGER,
	total_spend INTEGER, 
	country TEXT, 
	CONSTRAINT user_devices_pk PRIMARY KEY(user_id)
)

INSERT INTO users_devices 
	(user_id, devices, device_ids, user_create_time, total_spend, country) 
VALUES
	(1, '{watch, computer, phone}', '{1, 2, 3}', 1, 123, 'USA'); -- Array value input

INSERT INTO users_devices
VALUES
	(2, '{watch, phone}', '{1, 3}', 1, 200, 'CO'),
	(3, '{computer, phone}', '{2, 3}', 3, 560, 'UK'),
	(4, '{watch, computer}', '{1, 2}', 3, 125, 'UK');

SELECT *
FROM users_devices;

-- Accesing Arrays 

SELECT devices[2], device_ids[2] -- Array subscript numbers
FROM users_devices;

SELECT devices[1:2] -- Rectangular slices of an array
FROM users_devices;

-- Current Dimension 

SELECT ARRAY_DIMS(devices) -- Dimensions of an array
FROM users_devices;

SELECT ARRAY_UPPER(devices, 1) -- Return the upper bound of a specified array dimension
FROM users_devices;

SELECT ARRAY_LOWER(devices, 1) -- Return the lower bound of a specified array dimension
FROM users_devices;

SELECT ARRAY_LENGTH(devices, 1) -- Length of arrays
FROM users_devices;

SELECT CARDINALITY(devices) -- Cardinality returns the total number of elements in an array across all dimensions
FROM users_devices;

-- Modifiyin Arrays

UPDATE users_devices
SET devices[1] = 'phone' -- Or updated in a slice, ei [1:2] = '{phone, computer}'
WHERE user_id = 4;

UPDATE users_devices
SET device_ids[1] = 3
WHERE user_id = 4;

-- Concatenation Operator

SELECT ARRAY[1, 2] || ARRAY[3, 4]; -- Equal
SELECT ARRAY_CAT(ARRAY[1, 2], ARRAY[3, 4]);

SELECT ARRAY_PREPEND(1, ARRAY[2,3]);

-- ARRAY to String

SELECT ARRAY_TO_STRING(devices, ',')
FROM users_devices;

-- UNNEST

SELECT user_id, 
	   UNNEST(devices)
FROM users_devices;

-- ARRAY_AGG

CREATE TEMP TABLE aux AS (
SELECT user_id, 
	   UNNEST(devices) AS devices
FROM users_devices
);

SELECT user_id, 
	   ARRAY_AGG(devices)
FROM aux
GROUP BY user_id
ORDER BY user_id;