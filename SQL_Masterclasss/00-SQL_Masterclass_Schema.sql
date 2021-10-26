CREATE SCHEMA sql_masterclass;
SET SEARCH_PATH = sql_masterclass;

CREATE TABLE members();
CREATE TABLE prices();
CREATE TABLE transactions();

-- Creating these indexes after loading data
-- Will make things run much faster!!!

CREATE INDEX 
	ON prices (ticker, market_date);
	
CREATE INDEX 
	ON transactions (txn_date, ticker);

CREATE INDEX 
	ON transactions (txn_date, member_id);
	
CREATE INDEX 
	ON transactions (member_id);
	
CREATE INDEX 
	ON transactions (ticker);