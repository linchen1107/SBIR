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

# Check for 'nan' strings
print("Checking for 'nan' strings in item_emu3000_maintenance_ext...")
cursor.execute("""
    SELECT COUNT(*) FROM item_emu3000_maintenance_ext 
    WHERE part = 'nan' OR unit = 'nan' OR name = 'nan' OR wec = 'nan' OR notes = 'nan' OR kit_no = 'nan'
""")
nan_count = cursor.fetchone()[0]

if nan_count > 0:
    print(f"[FAIL] Found {nan_count} rows with 'nan' string!")
else:
    print("[PASS] No 'nan' strings found.")

# Check counts
cursor.execute("SELECT COUNT(*) FROM item")
item_count = cursor.fetchone()[0]
cursor.execute("SELECT COUNT(*) FROM item_emu3000_maintenance_ext")
ext_count = cursor.fetchone()[0]
cursor.execute("SELECT COUNT(*) FROM bom")
bom_count = cursor.fetchone()[0]

print(f"Items: {item_count}")
print(f"Extension Records: {ext_count}")
print(f"BOMs: {bom_count}")

conn.close()
