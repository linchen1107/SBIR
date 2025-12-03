import psycopg2
import sys

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'client_encoding': 'UTF8'
}

try:
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    print("Checking for Line Nos with filename suffixes...")
    cursor.execute("SELECT line_no FROM bom_line WHERE line_no LIKE '%_定更件_%' OR line_no LIKE '%_定檢件_%' LIMIT 10")
    rows = cursor.fetchall()
    
    if rows:
        print("Found examples:")
        for row in rows:
            print(f"  {row[0]}")
    else:
        print("No suffixes found! (This might be wrong if no collisions occurred)")
        
    conn.close()
except Exception as e:
    print(f"Error: {e}")
