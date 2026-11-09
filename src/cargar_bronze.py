import os
from pathlib import Path
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from dotenv import load_dotenv

load_dotenv()
ARCHIVO = Path("data/raw/dataset_fisioterapia_2023_2026.xlsx")

# 1. Leer Excel: todo como texto (regla de Bronze)
df = pd.read_excel(ARCHIVO, sheet_name="Datos_Pacientes", dtype=str)
df["_fuente"] = ARCHIVO.name
print("Filas leídas del Excel:", len(df))

# 2. Convertir a lista de filas (vacíos -> NULL)
columnas = list(df.columns)
filas = [tuple(None if pd.isna(v) else v for v in fila)
         for fila in df.itertuples(index=False)]

# 3. Cargar a Supabase
conn = psycopg2.connect(os.getenv("DATABASE_URL"))
with conn, conn.cursor() as cur:
    cur.execute("TRUNCATE bronze.pacientes_raw;")
    execute_values(
        cur,
        f"INSERT INTO bronze.pacientes_raw ({', '.join(columnas)}) VALUES %s",
        filas,
    )
    cur.execute("SELECT count(*) FROM bronze.pacientes_raw;")
    print("Filas en bronze:", cur.fetchone()[0])
conn.close()