import psycopg2

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
    
    print("=== Verification ===")
    
    # 1. Check Items (19M)
    print("\nChecking Items (19M)...")
    cursor.execute("SELECT item_code, item_name_zh FROM item WHERE item_code LIKE '75214%' LIMIT 5")
    rows = cursor.fetchall()
    for row in rows:
        print(f"  Item: {row}")
        
    # 2. Check Equipment (3M)
    print("\nChecking Equipment (3M)...")
    cursor.execute("SELECT item_code, item_name_zh FROM item WHERE item_code LIKE 'CN%' LIMIT 5")
    rows = cursor.fetchall()
    for row in rows:
        print(f"  Equipment: {row}")
        
    # 3. Check BOM (18M)
    print("\nChecking BOM (18M)...")
    cursor.execute("""
        SELECT parent.item_code, child.item_code, bl.qty_per
        FROM bom_line bl
        JOIN bom b ON bl.bom_uuid = b.bom_uuid
        JOIN item parent ON b.item_uuid = parent.item_uuid
        JOIN item child ON bl.component_item_uuid = child.item_uuid
        LIMIT 5
    """)
    rows = cursor.fetchall()
    for row in rows:
        print(f"  BOM: {row[0]} -> {row[1]} (Qty: {row[2]})")
        
    # 4. Check Part Numbers (20M)
    print("\nChecking Part Numbers (20M)...")
    cursor.execute("""
        SELECT i.item_code, x.part_number, s.cage_code
        FROM item_number_xref x
        JOIN item i ON x.item_uuid = i.item_uuid
        LEFT JOIN supplier s ON x.supplier_id = s.supplier_id
        LIMIT 5
    """)
    rows = cursor.fetchall()
    for row in rows:
        print(f"  Xref: {row[0]} -> {row[1]} (Cage: {row[2]})")

    conn.close()

if __name__ == "__main__":
    verify()
