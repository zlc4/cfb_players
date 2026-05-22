# cfb_players
ETL script to upload college football player data to database

The script starts by asking for user input on which team to extract player data from. Once the user provides valid input, the ETL process is ran by extracting data from a college football API. That data is then transformed by adjusting the formatting of the height and weight of the player, along with selecting which columns will be needed. Finally, the data is loaded to a csv file that will be used to bulk insert into a database.
