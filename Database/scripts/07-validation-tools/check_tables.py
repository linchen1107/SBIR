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

def connect_db():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

conn = connect_db()
cursor = conn.cursor()

cursor.execute("""
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public'
""")

tables = cursor.fetchall()
print("Tables in database:")
for t in tables:
    print(f"- {t[0]}")

# Check columns for item_emu3000_maintenance_ext if it exists
if any(t[0] == 'item_emu3000_maintenance_ext' for t in tables):
    print("\nColumns in item_emu3000_maintenance_ext:")
    cursor.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'item_emu3000_maintenance_ext'
    """)
    for col in cursor.fetchall():
        print(f"  - {col[0]} ({col[1]})")

conn.close()
