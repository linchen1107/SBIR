import os
import sys
import uuid
import pandas as pd
import psycopg2
from datetime import datetime

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'client_encoding': 'UTF8'
}

DATA_ROOT = r'c:\github\SBIR\Database\data\海軍\電笛_各M表'

def connect_db():
    return psycopg2.connect(**DB_CONFIG)

def clean_col_name(col):
    return str(col).replace('\n', '').replace('*', '').strip()

def find_col(df, keywords):
    # Debug: print cleaned columns
    print(f"Searching for {keywords} in {[clean_col_name(c) for c in df.columns]}")
    for col in df.columns:
        cleaned = clean_col_name(col)
        for kw in keywords:
            if kw in cleaned:
                return col
    return None

def get_or_create_item(cursor, item_code, name_zh=None, name_en=None, uom=None):
    if not item_code:
        return None
        
    cursor.execute("SELECT item_uuid FROM item WHERE item_code = %s", (item_code,))
    res = cursor.fetchone()
    if res:
        # Update info if provided
        if name_zh or name_en or uom:
            sql = "UPDATE item SET date_updated = NOW()"
            params = []
            if name_zh:
                sql += ", item_name_zh = %s"
                params.append(name_zh)
            if name_en:
                sql += ", item_name_en = %s"
                params.append(name_en)
            if uom:
                sql += ", uom = %s"
                params.append(uom)
            sql += " WHERE item_uuid = %s"
            params.append(res[0])
            cursor.execute(sql, tuple(params))
        return res[0]
    
    item_uuid = str(uuid.uuid4())
    cursor.execute("""
        INSERT INTO item (item_uuid, item_code, item_name_zh, item_name_en, item_type, uom, status, date_created, date_updated)
        VALUES (%s, %s, %s, %s, 'RM', %s, 'Active', NOW(), NOW())
    """, (item_uuid, item_code, name_zh or '', name_en or '', uom))
    return item_uuid

def get_or_create_supplier(cursor, cage_code):
    if not cage_code:
        return None
    
    cursor.execute("SELECT supplier_id FROM supplier WHERE cage_code = %s", (cage_code,))
    res = cursor.fetchone()
    if res:
        return res[0]
        
    cursor.execute("""
        INSERT INTO supplier (cage_code, supplier_name_en, date_created, date_updated)
        VALUES (%s, %s, NOW(), NOW())
        RETURNING supplier_id
    """, (cage_code, f"Supplier {cage_code}"))
    return cursor.fetchone()[0]

def import_19m(conn, file_path):
    print(f"Importing 19M: {os.path.basename(file_path)}")
    df = pd.read_excel(file_path, header=0)
    
    col_code = find_col(df, ['品項識別號', '品項識別碼'])
    col_zh = find_col(df, ['中文品名'])
    col_en = find_col(df, ['英文品名'])
    col_uom = find_col(df, ['撥發單位'])
    col_price = find_col(df, ['美金單價'])
    
    if not col_code:
        print("  [SKIP] No Item Code column found")
        print(f"  Available columns: {df.columns.tolist()}")
        return

    cursor = conn.cursor()
    count = 0
    for _, row in df.iterrows():
        code = str(row[col_code]).strip()
        if not code or code.lower() == 'nan': continue
        
        zh = str(row[col_zh]).strip() if col_zh and pd.notna(row[col_zh]) else None
        en = str(row[col_en]).strip() if col_en and pd.notna(row[col_en]) else None
        uom = str(row[col_uom]).strip() if col_uom and pd.notna(row[col_uom]) else None
        
        item_uuid = get_or_create_item(cursor, code, zh, en, uom)
        
        if col_price and pd.notna(row[col_price]):
            try:
                price = float(row[col_price])
                cursor.execute("""
                    INSERT INTO item_material_ext (item_uuid, unit_price_usd, date_created, date_updated)
                    VALUES (%s, %s, NOW(), NOW())
                    ON CONFLICT (item_uuid) DO UPDATE SET unit_price_usd = EXCLUDED.unit_price_usd, date_updated = NOW()
                """, (item_uuid, price))
            except: pass
        count += 1
    conn.commit()
    print(f"  Imported {count} items")

def import_3m(conn, file_path):
    print(f"Importing 3M: {os.path.basename(file_path)}")
    df = pd.read_excel(file_path, header=0)
    
    col_code = find_col(df, ['單機識別碼'])
    col_zh = find_col(df, ['裝備中文名稱'])
    col_en = find_col(df, ['裝備英文名稱'])
    
    if not col_code:
        print("  [SKIP] No Equipment Code column found")
        return

    cursor = conn.cursor()
    count = 0
    for _, row in df.iterrows():
        code = str(row[col_code]).strip()
        if not code or code.lower() == 'nan': continue
        
        zh = str(row[col_zh]).strip() if col_zh and pd.notna(row[col_zh]) else None
        en = str(row[col_en]).strip() if col_en and pd.notna(row[col_en]) else None
        
        # Treat Equipment as Item for now
        get_or_create_item(cursor, code, zh, en, 'EA')
        count += 1
    conn.commit()
    print(f"  Imported {count} equipment items")

def import_20m(conn, file_path):
    print(f"Importing 20M: {os.path.basename(file_path)}")
    df = pd.read_excel(file_path, header=0)
    
    col_item = find_col(df, ['品項識別碼', '品項識別號'])
    col_part = find_col(df, ['配件號碼', '參考號碼'])
    col_cage = find_col(df, ['廠商來源代號', '廠家登記代號'])
    
    if not col_item or not col_part:
        print("  [SKIP] Missing key columns")
        print(f"  Available columns: {df.columns.tolist()}")
        return

    cursor = conn.cursor()
    count = 0
    for _, row in df.iterrows():
        item_code = str(row[col_item]).strip()
        part_no = str(row[col_part]).strip()
        cage = str(row[col_cage]).strip() if col_cage and pd.notna(row[col_cage]) else None
        
        if not item_code or not part_no: continue
        
        item_uuid = get_or_create_item(cursor, item_code)
        supplier_id = get_or_create_supplier(cursor, cage) if cage else None
        
        cursor.execute("""
            INSERT INTO item_number_xref (item_uuid, part_number, supplier_id, date_created, date_updated)
            VALUES (%s, %s, %s, NOW(), NOW())
            ON CONFLICT DO NOTHING
        """, (item_uuid, part_no, supplier_id))
        count += 1
    conn.commit()
    print(f"  Imported {count} part numbers")

def import_18m(conn, file_path):
    print(f"Importing 18M: {os.path.basename(file_path)}")
    df = pd.read_excel(file_path, header=0)
    
    col_parent = find_col(df, ['單機識別碼'])
    col_child = find_col(df, ['品項識別號'])
    col_qty = find_col(df, ['單機零附件裝置數', '數量'])
    
    if not col_parent or not col_child:
        print("  [SKIP] Missing BOM columns")
        print(f"  Available columns: {df.columns.tolist()}")
        return

    cursor = conn.cursor()
    count = 0
    for _, row in df.iterrows():
        parent_code = str(row[col_parent]).strip()
        child_code = str(row[col_child]).strip()
        
        if not parent_code or not child_code: continue
        
        parent_uuid = get_or_create_item(cursor, parent_code)
        child_uuid = get_or_create_item(cursor, child_code)
        
        qty = 1.0
        if col_qty and pd.notna(row[col_qty]):
            try:
                qty = float(row[col_qty])
            except: pass
            
        # Get or Create BOM
        cursor.execute("SELECT bom_uuid FROM bom WHERE item_uuid = %s", (parent_uuid,))
        res = cursor.fetchone()
        if res:
            bom_uuid = res[0]
        else:
            bom_uuid = str(uuid.uuid4())
            cursor.execute("""
                INSERT INTO bom (bom_uuid, item_uuid, bom_code, status, date_created, date_updated)
                VALUES (%s, %s, %s, 'Released', NOW(), NOW())
            """, (bom_uuid, parent_uuid, f"BOM-{parent_code}"))
            
        # Add BOM Line
        cursor.execute("SELECT COUNT(*) FROM bom_line WHERE bom_uuid = %s", (bom_uuid,))
        line_no = str(cursor.fetchone()[0] + 1)
        
        cursor.execute("""
            INSERT INTO bom_line (line_uuid, bom_uuid, line_no, component_item_uuid, qty_per, date_created, date_updated)
            VALUES (%s, %s, %s, %s, %s, NOW(), NOW())
        """, (str(uuid.uuid4()), bom_uuid, line_no, child_uuid, qty))
        count += 1
        
    conn.commit()
    print(f"  Imported {count} BOM lines")

def main():
    conn = connect_db()
    files = os.listdir(DATA_ROOT)
    
    # 1. Import 19M (Items)
    for f in files:
        if '19M' in f and f.endswith('.xlsx'):
            import_19m(conn, os.path.join(DATA_ROOT, f))
            
    # 2. Import 3M (Equipment)
    for f in files:
        if '3M' in f and f.endswith('.xlsx'):
            import_3m(conn, os.path.join(DATA_ROOT, f))

    # 3. Import 20M (Parts)
    for f in files:
        if '20M' in f and f.endswith('.xlsx'):
            import_20m(conn, os.path.join(DATA_ROOT, f))
            
    # 4. Import 18M (BOM)
    for f in files:
        if '18M' in f and f.endswith('.xlsx'):
            import_18m(conn, os.path.join(DATA_ROOT, f))
            
    conn.close()
    print("Done.")

if __name__ == "__main__":
    main()
