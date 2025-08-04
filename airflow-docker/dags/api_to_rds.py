import pandas as pd
import requests
from airflow.models import Variable
from dotenv import load_dotenv
from datetime import datetime
import boto3
import json
from sqlalchemy import create_engine


load_dotenv()

def apicall_to_postgresQL():
# API endpoint to fetch football competitions
    url = Variable.get("url")
    # Send request to the API
    football = requests.get(url)
    # Parse API response as JSON
    compete = football.json()
    # Extract competitions list
    Result = compete['competitions']

    # Step 4: Select relevant columns and rename for clarity
    df = pd.json_normalize(Result)
    df = df[['id', 'name', 'code', 'type', 'emblem', 'plan',
             'numberOfAvailableSeasons', 'lastUpdated', 'area.name']]
    df.columns = ['id', 'name', 'code', 'type', 'emblem', 'plan',
                  'number_of_available_seasons', 'last_updated', 'area_name']
    # Step 5: Define PostgreSQL connection
    user = Variable.get("db_user")
    password = Variable.get("db_password")
    host = Variable.get("db_host")
    port = Variable.get("db_port")
    database = Variable.get("db_name")

    engine = create_engine(f'postgresql+psycopg2://{user}:{password}@{host}:{port}/{database}')

    df.to_sql('footballcompetition', engine, if_exists='replace', index=False)   