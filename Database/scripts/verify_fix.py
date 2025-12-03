import psycopg2
import pandas as pd

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'client_encoding': 'UTF8'
}

def verify():
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # Check a specific item mentioned in the issue: C147356/WU
    # It should be line_no '1' (string)
    
    print("Checking C147356/WU...")
    cursor.execute("""
        SELECT bl.line_no, i.item_code 
        FROM bom_line bl
        JOIN item i ON bl.component_item_uuid = i.item_uuid
        WHERE i.item_code = 'C147356/WU'
    """)
    rows = cursor.fetchall()
    for row in rows:
        print(f"  Item: {row[1]}, Line No: {row[0]} (Type: {type(row[0])})")
        
    # Check C103769/5 (was 10, should be 5)
    print("\nChecking C103769/5...")
    cursor.execute("""
        SELECT bl.line_no, i.item_code 
        FROM bom_line bl
        JOIN item i ON bl.component_item_uuid = i.item_uuid
        WHERE i.item_code = 'C103769/5'
    """)
    rows = cursor.fetchall()
    for row in rows:
        print(f"  Item: {row[1]}, Line No: {row[0]}")

    conn.close()

if __name__ == "__main__":
    verify()
