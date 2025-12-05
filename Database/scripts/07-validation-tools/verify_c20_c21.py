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

# Check for II73643/4WU (The example item)
item_code = 'II73643/4WU'
print(f"Checking for Item: {item_code}")

cursor.execute("SELECT item_uuid FROM item WHERE item_code = %s", (item_code,))
item_uuid = cursor.fetchone()

if item_uuid:
    item_uuid = item_uuid[0]
    print(f"Found Item UUID: {item_uuid}")
    
    # Check extension table
    cursor.execute("""
        SELECT part, kit_no, name, notes
        FROM item_emu3000_maintenance_ext 
        WHERE item_uuid = %s
    """, (item_uuid,))
    
    rows = cursor.fetchall()
    print(f"Found {len(rows)} extension records:")
    for row in rows:
        print(row)
else:
    print("Item not found!")

# General count check
cursor.execute("SELECT COUNT(*) FROM item_emu3000_maintenance_ext")
ext_count = cursor.fetchone()[0]
print(f"\nTotal Extension Records: {ext_count}")

conn.close()
