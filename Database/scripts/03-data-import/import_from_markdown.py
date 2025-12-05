import os
import sys
import uuid
import re
import psycopg2
import pandas as pd

# Database Config
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'client_encoding': 'UTF8'
}

MARKDOWN_FILE = r'c:\github\SBIR\Database\docs\20-EMU3000系統\02-EMU3000_資料預覽.md'

def connect_db():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("[OK] Database connected.")
        return conn
    except Exception as e:
        print(f"[ERROR] Database connection failed: {e}")
        sys.exit(1)

def clean_database(conn):
    print("Cleaning database...")
    cursor = conn.cursor()
    try:
        cursor.execute("TRUNCATE TABLE item_emu3000_maintenance_ext CASCADE")
        cursor.execute("TRUNCATE TABLE bom_line CASCADE")
        cursor.execute("TRUNCATE TABLE bom CASCADE")
        cursor.execute("TRUNCATE TABLE item CASCADE")
        conn.commit()
        print("[OK] Database cleaned.")
    except Exception as e:
        print(f"[ERROR] Failed to clean database: {e}")
        conn.rollback()
        sys.exit(1)

def get_or_create_item(cursor, item_code, item_name, item_type, uom=None):
    cursor.execute("SELECT item_uuid FROM item WHERE item_code = %s", (item_code,))
    result = cursor.fetchone()
    if result:
        return result[0]

    item_uuid = str(uuid.uuid4())
    # Assuming Name is English/Chinese mixed or just English. 
    # We'll put it in both for now or just EN.
    # The PDF extraction put everything in 'Name'.
    
    sql = """
        INSERT INTO item (item_uuid, item_code, item_name_zh, item_name_en, item_type, uom, status, date_created, date_updated)
        VALUES (%s, %s, %s, %s, %s, %s, 'Active', NOW(), NOW())
    """
    cursor.execute(sql, (item_uuid, item_code, item_name, item_name, item_type, uom))
    return item_uuid

def create_bom_header(cursor, item_uuid, bom_code):
    cursor.execute("SELECT bom_uuid FROM bom WHERE item_uuid = %s", (item_uuid,))
    result = cursor.fetchone()
    if result:
        return result[0]

    bom_uuid = str(uuid.uuid4())
    sql = """
        INSERT INTO bom (bom_uuid, item_uuid, bom_code, revision, status, date_created, date_updated)
        VALUES (%s, %s, %s, '1.0', 'Released', NOW(), NOW())
    """
    cursor.execute(sql, (bom_uuid, item_uuid, bom_code))
    return bom_uuid

def add_bom_line(cursor, bom_uuid, component_item_uuid, qty, line_no, uom):
    # Check for duplicate line_no in same BOM
    cursor.execute("""
        SELECT line_uuid, component_item_uuid FROM bom_line 
        WHERE bom_uuid = %s AND line_no = %s
    """, (bom_uuid, line_no))
    
    existing = cursor.fetchone()
    if existing:
        existing_line_uuid, existing_comp_uuid = existing
        
        # If same component, it's a duplicate entry (e.g. from another PDF covering same assembly)
        # Just skip it.
        if existing_comp_uuid == component_item_uuid:
            # print(f"  [INFO] Skipping duplicate line {line_no} for BOM {bom_uuid}")
            return

        # Conflict! Different component with same line_no. Append suffix
        count = 1
        new_line_no = f"{line_no}_{count}"
        while True:
            cursor.execute("""
                SELECT line_uuid FROM bom_line 
                WHERE bom_uuid = %s AND line_no = %s
            """, (bom_uuid, new_line_no))
            if not cursor.fetchone():
                line_no = new_line_no
                break
            count += 1
            new_line_no = f"{line_no}_{count}"
    
    # Truncate uom to 10 chars to fit DB
    if uom and len(str(uom)) > 10:
        # print(f"  [WARN] Truncating uom '{uom}' to 10 chars")
        uom = str(uom)[:10]

    line_uuid = str(uuid.uuid4())
    cursor.execute("""
        INSERT INTO bom_line (line_uuid, bom_uuid, line_no, component_item_uuid, qty_per, uom, date_created, date_updated)
        VALUES (%s, %s, %s, %s, %s, %s, NOW(), NOW())
    """, (line_uuid, bom_uuid, line_no, component_item_uuid, qty, uom))

def insert_extension_data(cursor, item_uuid, part, qty, unit, name, wec):
    sql = """
        INSERT INTO item_emu3000_maintenance_ext 
        (item_uuid, part, quantity, unit, name, wec, date_created, date_updated)
        VALUES (%s, %s, %s, %s, %s, %s, NOW(), NOW())
    """
    cursor.execute(sql, (item_uuid, part, qty, unit, name, wec))

def parse_markdown_table(file_path):
    print(f"Reading {file_path}...")
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    data = []
    in_table = False
    headers = []
    
    for line in lines:
        line = line.strip()
        if line.startswith('|') and 'Part' in line and 'Item number' in line:
            in_table = True
            headers = [h.strip() for h in line.split('|') if h.strip()]
            continue
        
        if in_table:
            if not line.startswith('|'):
                in_table = False
                continue
            
            if '---' in line: continue
            
            # Parse row
            # | Part | Item number | Quantity | Unit | Name | WEC | Assembly |
            cols = [c.strip() for c in line.split('|')]
            # Remove empty first/last if pipe starts/ends line
            if line.startswith('|'): cols.pop(0)
            if line.endswith('|'): cols.pop(-1)
            
            if len(cols) >= 7:
                row = {
                    'Part': cols[0],
                    'Item number': cols[1],
                    'Quantity': cols[2],
                    'Unit': cols[3],
                    'Name': cols[4],
                    'WEC': cols[5],
                    'Assembly': cols[6]
                }
                data.append(row)
            
    return data

def main():
    conn = connect_db()
    clean_database(conn)
    cursor = conn.cursor()
    
    rows = parse_markdown_table(MARKDOWN_FILE)
    print(f"Parsed {len(rows)} rows from Markdown.")
    
    # Cache created items to avoid DB hits? 
    # Actually get_or_create_item does a SELECT.
    
    for i, row in enumerate(rows):
        if i % 100 == 0:
            print(f"Processing row {i}/{len(rows)}...")
            
        part = row['Part']
        item_code = row['Item number']
        qty_str = row['Quantity']
        unit = row['Unit']
        name = row['Name']
        wec = row['WEC']
        assembly_str = row['Assembly']
        
        try:
            qty = float(qty_str)
        except:
            qty = 1.0
            
        # 1. Handle Assembly
        # Format: "CODE NAME"
        # Split by first space
        parts = assembly_str.split(' ', 1)
        assembly_code = parts[0]
        assembly_name = parts[1] if len(parts) > 1 else "Unknown Assembly"
        
        assembly_uuid = get_or_create_item(cursor, assembly_code, assembly_name, 'FG', 'Set')
        bom_uuid = create_bom_header(cursor, assembly_uuid, f"BOM-{assembly_code}")
        
        # 2. Handle Component
        component_uuid = get_or_create_item(cursor, item_code, name, 'SEMI', unit)
        
        # 3. Add to BOM
        add_bom_line(cursor, bom_uuid, component_uuid, qty, part, unit)
        
        # 4. Add Extension Data
        insert_extension_data(cursor, component_uuid, part, qty, unit, name, wec)
        
    conn.commit()
    print("[OK] Import completed successfully.")
    conn.close()

if __name__ == "__main__":
    main()
