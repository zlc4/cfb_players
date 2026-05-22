# NAME: Zach Cartledge
# DATE: 4/20/2026
# PROJECT: College Football Player Database
# DESCRIPTION: ETL Process for College Football Player Database: https://docs.balldontlie.io/?python#get-all-teams

import sys, pandas, datetime, os, requests
os.environ["PYSPARK_PYTHON"] = sys.executable;
os.environ["PYSPARK_DRIVER_PYTHON"] = sys.executable;
os.environ["SPARK_CONF_DIR"] = os.path.dirname(os.path.abspath(__file__));

from pyspark.sql import SparkSession
import pyspark.sql.functions as f
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
from dotenv import load_dotenv

spark = SparkSession.builder.appName('cfb_etl').getOrCreate(); # CREATE SPARK SESSION
spark.sparkContext.setLogLevel('Error');  #  Options: ERROR, WARN, INFO, DEBUG

def extract(team_id):
    load_dotenv()
    api_key = os.getenv('API_KEY');
    headers = {'Authorization': api_key};
    
    player_url = 'https://api.balldontlie.io/ncaaf/v1/players/active'; 
    player_params = {'team_ids[]' : team_id, 'per_page': 100};

    try:
        response = requests.get(url=player_url, headers=headers, params=player_params);
        response.raise_for_status();  
        data = response.json();
        df = pandas.json_normalize(data['data']);
      
    except Exception as e:
        print(f'Extraction failed due to error: {e}');
        sys.exit(-1);

    return df, team_id;

def convert_height_cm(feet, inches):
    height = (int(feet) * 12) + int(inches);
    height = int(height *  2.54);
    return height;

def transform (df, team_id):
    try:
        # Create PySpark DataFrame
        players = spark.createDataFrame(data=df);

        # Add Team ID
        players = players.withColumn('team_id', f.lit(team_id));
       
        # Transform weight from string to int
        players = players.withColumn('weight', f.col('weight').substr(0,3));

        # Transform height to cm
        players = players.withColumn('height', \
                f.lit(f'{convert_height_cm(f.col('height').substr(1,1), f.col('height').substr(4,1))} cm'));

        # Select Fields to Include and Type Cast
        players = players.select(
            f.col('jersey_number').cast('int'),
            f.col('first_name'),
            f.col('last_name'),
            f.col('position'),
            f.col('height'),
            f.col('weight').cast('int'),
            f.col('team_id').cast('int')
        );
    
        # Sort by Jersey Number (Ascending order)
        players = players.orderBy(f.col('jersey_number').asc());
        
    except Exception as e:
        print(f'Transformation failed due to error: {e}');
        sys.exit(-1);
   
    return players;

def load(df):
    etl_file = 'cfb_players.csv'; # DEFINE ETL FILE

    try:
        #df.printSchema(); # PRINT THE DATA SCHEMA
        df.show(100); #PRINT THE DATA FRAME
        
        # WRITE TO ETL FILE
        df.coalesce(1) \
        .write.format('csv') \
        .mode('overwrite') \
        .option('header', 'true') \
        .save(etl_file); 
     
    except Exception as e:
        print(f'Transformation failed due to error: {e}');
        sys.exit(-1);

def run_etl(team_id):
    begin_etl_time = datetime.datetime.now();
    print(f'ETL Process Began at {begin_etl_time}\n');

    try:
        # --EXTRACT--
        print('Extracting...');
        raw_data, team_id = extract(team_id);

        # --TRANSFORM--
        print('Transforming...');
        cfb_data = transform(raw_data, team_id);

        # --LOAD--
        print('Loading...');
        load(cfb_data);
    
        end_etl_time = datetime.datetime.now();
        print(f'ETL Process Ended at {end_etl_time}');
        
    except Exception as e:
        print(f'ETL failed due to error: {e}');
        sys.exit(-1);

def main():
    print(f'Welcome to the College Football Player Lookup\n');
    cfb_teams = pandas.read_csv(filepath_or_buffer='cfb_teams.csv', index_col=False); # Load in College Football Teams

    #print(cfb_teams);
    
    cfb_team_id = int(input(f'Enter the ID of the team you want to view\n'));
    if (cfb_team_id < 0 or cfb_team_id > 136):
        print('Invalid Input! Please enter a valid ID between 1-30.')
    else:
        team_name = cfb_teams.at[cfb_team_id - 1, 'full_name'];
        print(f'Looking up players from the {team_name}...');
        run_etl(cfb_team_id);            

if __name__ == "__main__":
    main();