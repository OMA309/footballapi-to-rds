from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from api_to_rds import apicall_to_postgresQL

default_args = {
    'owner': 'Botafli2',
    'retries': 2,
}

dag = DAG(
    dag_id="footballapi_to_rds",
    description="This is the dag to pull football api to postgreQL",
    start_date=datetime(2025, 8, 2),
    schedule_interval="@daily",
    catchup=False,
    default_args=default_args
)


footballapi_to_rds= PythonOperator(
    task_id="footballapi_to_rds",
    python_callable=apicall_to_postgresQL,
    dag=dag
    )


