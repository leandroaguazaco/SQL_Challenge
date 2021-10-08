CREATE TABLE seconds (
	seconds INTEGER NOT NULL -- Integers represents either second, day, month
);

INSERT INTO seconds
	(seconds)
VALUES
	('120'), -- Integer
	('30'),
	('300');

SELECT *
FROM seconds;

-- To convert an integer to an interval, then to operate with TIMESTAMP
SELECT TIMESTAMP '1971-11-02 08:00:40' + (seconds ||' SECOND')::INTERVAL
FROM seconds;