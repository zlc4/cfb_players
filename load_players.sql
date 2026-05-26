use cfb_db;

-- SELECT * FROM team;

-- Load NBA Teams into database
BEGIN TRY
	BEGIN TRANSACTION;

	-- Reset team and team_staging table
	TRUNCATE TABLE player_staging; 
	-- TRUNCATE TABLE team;

	-- Insert data from CSV file into staging table
	BULK INSERT player_staging FROM '[Enter ETL Output File]'
		WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2);

	-- View the staging table to see the data
	SELECT * FROM player_staging;

	-- Merge the data into the teams table
	MERGE player as target USING player_staging as source ON target.player_id = source.player_id
		WHEN MATCHED THEN
			UPDATE SET
			target.jersey_number = source.jersey_number,
			target.player_fname = source.player_fname,
			target.player_lname = source.player_lname,
			target.team_id = source.team_id,
			target.position = source.position,
			target.height = source.height,
			target.player_weight = source.player_weight

		WHEN NOT MATCHED BY TARGET THEN
			INSERT (player_id, jersey_number, player_fname, player_lname, team_id, position, height, player_weight)
				VALUES(source.player_id, source.jersey_number, source.player_fname, source.player_lname, source.team_id, source.position,
						source.height, source.player_weight)

		--WHEN NOT MATCHED BY SOURCE THEN
			--DELETE

		OUTPUT $action as action_taken, inserted.*, deleted.*;
	
	COMMIT;
END TRY
BEGIN CATCH
	ROLLBACK;
	PRINT ERROR_MESSAGE();
END CATCH
