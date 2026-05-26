-- create database cfb_db;
use cfb_db;

-- TABLE 1: Conference Information
CREATE TABLE conference (
	conference_id INT NOT NULL IDENTITY(1,1),
	conference_name varchar(50) NOT NULL,
	CONSTRAINT conference_PK1 PRIMARY KEY (conference_id)
);

BULK INSERT conference FROM [Enter Conferences CSV File]
		WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2);

-- TABLE 2: Team Information
CREATE TABLE team (
	team_id INT NOT NULL IDENTITY(1,1),
	conference_id INT NOT NULL,
	college varchar(30) NOT NULL,
	team_name varchar(30) NOT NULL,
	team_full_name varchar (50) NOT NULL,
	team_abbreviation varchar(5),
	CONSTRAINT team_PK1 PRIMARY KEY (team_id),
	CONSTRAINT team_FK1 FOREIGN KEY (conference_id) REFERENCES conference (conference_id)
);


BULK INSERT team FROM 'C:\Users\zcartle\Documents\Github\cfb_players\cfb_teams.csv'
		WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2);

-- TABLE 3: Player Information
CREATE TABLE player (
	player_id INT NOT NULL,
	jersey_number INT NOT NULL,
	player_fname varchar(50) NOT NULL,
	player_lname varchar(50) NOT NULL,
	position varchar(50) NOT NULL,
	height varchar(6) NOT NULL,
	player_weight INT NOT NULL,
	team_id INT NOT NULL,
	CONSTRAINT player_PK1 PRIMARY KEY (player_id),
	CONSTRAINT player_FK1 FOREIGN KEY (team_id) REFERENCES team (team_id)
);

-- TABLE 4: Staging Table for reading in players
CREATE TABLE player_staging (
	player_id INT NOT NULL,
	jersey_number INT NOT NULL,
	player_fname varchar(50) NOT NULL,
	player_lname varchar(50) NOT NULL,
	position varchar(50) NOT NULL,
	height varchar(6) NOT NULL,
	player_weight INT NOT NULL,
	team_id INT NOT NULL,
);

/*
-- DROP TABLES
DROP TABLE IF EXISTS conference;
DROP TABLE IF EXISTS team;
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS player_staging;
*/

/*
-- VIEW TABLES
SELECT * FROM conference;
SELECT * FROM team;
SELECT * FROM player;
SELECT * FROM player_staging;
*/
