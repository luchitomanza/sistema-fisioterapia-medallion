import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()
conn = psycopg2.connect(os.getenv("DATABASE_URL"))
cur = conn.cursor()
cur.execute("SELECT count(*) FROM bronze.pacientes_raw;")
print("Conectado. Filas en bronze:", cur.fetchone()[0])
conn.close()