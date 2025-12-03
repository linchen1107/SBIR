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

def inspect():
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    print("Inspecting BOM for II73643/4WU...")
    cursor.execute("""
        SELECT bl.line_no, i.item_code, bl.qty_per
        FROM bom_line bl
        JOIN item i ON bl.component_item_uuid = i.item_uuid
        JOIN bom b ON bl.bom_uuid = b.bom_uuid
        JOIN item parent ON b.item_uuid = parent.item_uuid
        WHERE parent.item_code = 'II73643/4WU'
        ORDER BY bl.line_no
    """)
    rows = cursor.fetchall()
    for row in rows:
        print(f"  Line: {row[0]}, Item: {row[1]}, Qty: {row[2]}")

    conn.close()

if __name__ == "__main__":
    inspect()
