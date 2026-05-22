use cfb_db;

-- SELECT * FROM team;

-- Load NBA Teams into database
BEGIN TRY
	BEGIN TRANSACTION;

	-- Reset team and team_staging table
	TRUNCATE TABLE player_staging; 
	-- TRUNCATE TABLE team;

	-- Insert data from CSV file into staging table
	BULK INSERT player_staging FROM 'C:\Users\zcartle\Documents\GitHub\cfb_players\cfb_players.csv\part-00000-6fc015d2-6720-40c8-b063-9c5c66b15afa-c000.csv'
		WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2);

	-- View the staging table to see the data
	SELECT * FROM player_staging;

	-- Merge the data into the teams table
	MERGE players as target USING player_staging as source ON target.player_id = source.player_id
		WHEN MATCHED THEN
			UPDATE SET
			target.jersey_number = source.jersey_number,
			target.player_name = source.player_name,
			target.team_id = source.team_id,
			target.position = source.position,
			target.height = source.height,
			target.player_weight = source.player_weight

		WHEN NOT MATCHED BY TARGET THEN
			INSERT (jersey_number, player_name, team_id, position, height, player_weight)
				VALUES(source.jersey_number, source.player_name, source.team_id, source.position,
						source.height, source.player_weight)

		WHEN NOT MATCHED BY SOURCE THEN
			DELETE

		OUTPUT $action as action_taken, inserted.*, deleted.*;
	
	COMMIT;
END TRY
BEGIN CATCH
	ROLLBACK;
	PRINT ERROR_MESSAGE();
END CATCH