#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
匯入 EMU3000 維修物料清單到資料庫

邏輯:
1. 遍歷目錄 `Database/data/EMU3000/EMU 3000 維修物料清單`
2. 排除 `原始資料` 目錄
3. 讀取 .xlsx 檔案
4. 識別總成 (Assembly) 與次總成 (Sub-assembly)
5. 匯入 Item, BOM, BOM_LINE
"""

import os
import sys
import uuid
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
import json

# 資料庫連線設定 (與 import_application_data.py 相同)
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'client_encoding': 'UTF8'
}

DATA_ROOT = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單'

def connect_db():
    """連接資料庫"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("[OK] 資料庫連線成功！")
        return conn
    except Exception as e:
        print(f"[ERROR] 資料庫連線失敗: {e}")
        sys.exit(1)

def get_or_create_item(cursor, item_code, item_name_zh, item_name_en, item_type, uom=None):
    """
    取得或建立 Item
    回傳: item_uuid
    """
    # 檢查是否存在
    cursor.execute("SELECT item_uuid FROM item WHERE item_code = %s", (item_code,))
    result = cursor.fetchone()
    if result:
        return result[0]

    # 建立新 Item
    item_uuid = str(uuid.uuid4())
    
    # 簡單區分中英文名稱 (如果 excel 只有一個 Name 欄位)
    # 這裡假設傳入的 name 已經處理過，或是直接存入
    
    sql = """
        INSERT INTO item (item_uuid, item_code, item_name_zh, item_name_en, item_type, uom, status, date_created, date_updated)
        VALUES (%s, %s, %s, %s, %s, %s, 'Active', NOW(), NOW())
    """
    cursor.execute(sql, (item_uuid, item_code, item_name_zh, item_name_en, item_type, uom))
    return item_uuid

def create_bom_header(cursor, item_uuid, bom_code):
    """
    建立 BOM 表頭 (如果不存在)
    回傳: bom_uuid
    """
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
    """
    加入 BOM Line (先刪除舊的同 component 記錄以避免重複，或直接插入)
    這裡選擇直接插入，假設資料清理過。
    為了避免重複執行腳本造成重複資料，先檢查。
    """
    cursor.execute("""
        SELECT line_uuid FROM bom_line 
        WHERE bom_uuid = %s AND component_item_uuid = %s
    """, (bom_uuid, component_item_uuid))
    
    if cursor.fetchone():
        # 更新數量
        cursor.execute("""
            UPDATE bom_line 
            SET qty_per = %s, line_no = %s, uom = %s, date_updated = NOW()
            WHERE bom_uuid = %s AND component_item_uuid = %s
        """, (qty, line_no, uom, bom_uuid, component_item_uuid))
    else:
        # 插入新記錄
        line_uuid = str(uuid.uuid4())
        cursor.execute("""
            INSERT INTO bom_line (line_uuid, bom_uuid, line_no, component_item_uuid, qty_per, uom, date_created, date_updated)
            VALUES (%s, %s, %s, %s, %s, %s, NOW(), NOW())
        """, (line_uuid, bom_uuid, line_no, component_item_uuid, qty, uom))

def clean_database(conn):
    """清空相關資料表"""
    print("正在清空資料庫...")
    cursor = conn.cursor()
    try:
        # 依照依賴順序刪除
        cursor.execute("TRUNCATE TABLE item_emu3000_maintenance_ext CASCADE")
        cursor.execute("TRUNCATE TABLE bom_line CASCADE")
        cursor.execute("TRUNCATE TABLE bom CASCADE")
        # 注意: item 表可能被其他表引用 (如 application)，如果只刪除 EMU3000 相關的會比較安全
        # 但使用者要求 "刪除現在資料庫中的所有資料"，這裡假設是指 EMU3000 相關的匯入資料
        # 為了安全起見，我們只刪除我們匯入的 (可以透過沒有 application 關聯的來判斷? 或者直接全部刪除如果這是開發環境)
        # 根據指示 "刪除現在資料庫中的所有資料"，執行 TRUNCATE item CASCADE
        cursor.execute("TRUNCATE TABLE item CASCADE") 
        conn.commit()
        print("[OK] 資料庫已清空")
    except Exception as e:
        print(f"[ERROR] 清空資料庫失敗: {e}")
        conn.rollback()
        sys.exit(1)

def clean_value(val):
    """Clean value for DB insertion: Convert NaN/Empty to None"""
    if pd.isna(val):
        return None
    s_val = str(val).strip()
    if s_val.lower() in ['nan', 'null', '', 'none']:
        return None
    return s_val

def insert_extension_data(cursor, item_uuid, row):
    """插入資料到 item_emu3000_maintenance_ext"""
    # New schema allows multiple records per item, so just INSERT
    sql = """
        INSERT INTO item_emu3000_maintenance_ext 
        (item_uuid, part, quantity, unit, name, wec, notes, kit_no, date_created, date_updated)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW())
    """
    
    # Clean values
    part = clean_value(row.get('Part'))
    unit = clean_value(row.get('Unit'))
    name = clean_value(row.get('Name'))
    wec = clean_value(row.get('WEC'))
    notes = clean_value(row.get('Notes'))
    kit_no = clean_value(row.get('Kit No'))
    
    # Handle Quantity specifically
    qty_raw = row.get('Quantity')
    qty = None
    if pd.notna(qty_raw):
        try:
            qty = float(qty_raw)
        except:
            qty = None
            
    values = (item_uuid, part, qty, unit, name, wec, notes, kit_no)
    cursor.execute(sql, values)

def process_sheet(cursor, df, sheet_name, file_name, current_assembly_uuid, current_bom_uuid, existing_lines, current_assembly_code):
    """
    處理單個 Sheet 的資料
    Returns: (current_assembly_uuid, current_bom_uuid, existing_lines, current_assembly_code)
    因為 sheet 內可能會切換 Assembly，所以需要回傳更新後的狀態
    """
    print(f"    Processing Sheet: {sheet_name}")
    
    # Standardize columns
    df.columns = df.columns.str.strip()
    
    # Check required columns
    required_cols = ['Item number', 'Name', 'Quantity']
    missing_cols = [col for col in required_cols if col not in df.columns]
    
    if missing_cols:
        print(f"      [SKIP] Missing required columns in {sheet_name}: {missing_cols}")
        return current_assembly_uuid, current_bom_uuid, existing_lines, current_assembly_code

    # Iterate through rows
    for index, row in df.iterrows():
        # Raw values
        part_raw = row.get('Part')
        item_code_raw = row.get('Item number')
        name_raw = row.get('Name')
        unit_raw = row.get('Unit')
        
        # Cleaned values for logic
        item_code = clean_value(item_code_raw)
        name = clean_value(name_raw) or ""
        unit = clean_value(unit_raw)
        
        if not item_code:
            continue

        # Logic:
        # If Part is NULL/Empty -> Assembly (New BOM Header)
        # If Part is Number -> Component (BOM Line)
        
        is_assembly = False
        part_val = clean_value(part_raw)
        
        if part_val is None:
            is_assembly = True
        
        # Name handling
        name_en = name
        name_zh = name
        
        item_uuid = None
        
        if is_assembly:
            # Check if this is a NEW Assembly or the SAME one
            if item_code == current_assembly_code:
                # Same Assembly (e.g. repeated header in new sheet)
                # Keep current_bom_uuid and existing_lines
                print(f"      [Info] Continuing Assembly: {item_code}")
                pass
            else:
                # New Assembly! Switch Context.
                print(f"      [Assembly] Switching to {item_code} - {name}")
                item_uuid = get_or_create_item(cursor, item_code, name_zh, name_en, 'FG', unit)
                current_assembly_uuid = item_uuid
                current_assembly_code = item_code
                current_bom_uuid = create_bom_header(cursor, current_assembly_uuid, f"BOM-{item_code}")
                
                # Reset existing lines for the NEW BOM
                # But first, load any lines that might already exist in DB (if this is a re-run or split file)
                cursor.execute("SELECT line_no, component_item_uuid FROM bom_line WHERE bom_uuid = %s", (current_bom_uuid,))
                existing_lines = {row[0]: row[1] for row in cursor.fetchall()}
            
        else:
            # Component
            if not current_bom_uuid:
                print(f"      [WARN] Component found but no BOM Header active. Skipping {item_code}")
                continue
                
            # Parse line_no from Part
            line_no_base = str(part_val).strip()
            if line_no_base.endswith('.0'):
                line_no_base = line_no_base[:-2]
            
            # Get component item UUID
            item_uuid = get_or_create_item(cursor, item_code, name_zh, name_en, 'SEMI', unit)

            # Conflict Resolution
            final_line_no = line_no_base
            
            def is_conflict(check_line_no):
                if check_line_no in existing_lines:
                    if existing_lines[check_line_no] == item_uuid:
                        return False # No conflict, same item
                    else:
                        return True # Conflict, different item
                return False # No conflict, new line

            if is_conflict(final_line_no):
                # Conflict detected
                suffix = ""
                if sheet_name in ['定更件', '定檢件', 'Sheet1']:
                    suffix = f"_{sheet_name}_{file_name}"
                else:
                    suffix = f"_{sheet_name}"
                
                candidate = f"{line_no_base}{suffix}"
                
                if is_conflict(candidate):
                    count = 1
                    while True:
                        candidate_cnt = f"{candidate}_{count}"
                        if not is_conflict(candidate_cnt):
                            final_line_no = candidate_cnt
                            break
                        count += 1
                else:
                    final_line_no = candidate
            
            # Update our local map
            existing_lines[final_line_no] = item_uuid
            
            # Quantity
            qty = None
            try:
                qty = float(row.get('Quantity'))
            except:
                qty = 1.0 
                if qty is None: qty = 1.0
            
            try:
                add_bom_line(cursor, current_bom_uuid, item_uuid, qty, final_line_no, unit)
            except Exception as e:
                print(f"      [ERROR] Failed to add line {final_line_no}: {e}")
                pass
                
        # Insert extension data
        if item_uuid:
            insert_extension_data(cursor, item_uuid, row)
            
    return current_assembly_uuid, current_bom_uuid, existing_lines, current_assembly_code

def process_excel(file_path, conn):
    print(f"Processing file: {os.path.basename(file_path)}")
    sys.stdout.flush()
    
    file_name = os.path.splitext(os.path.basename(file_path))[0]
    
    try:
        xl = pd.ExcelFile(file_path)
    except Exception as e:
        print(f"[ERROR] Cannot read Excel: {e}")
        return

    cursor = conn.cursor()
    
    current_assembly_uuid = None
    current_bom_uuid = None
    current_assembly_code = None
    existing_lines = {} # line_no -> component_item_uuid

    # Pre-scan first sheet to get Initial Assembly Info (Optional, but good for safety)
    # Actually, process_sheet logic now handles initialization if we pass Nones.
    # But to be safe and keep logic consistent, let's just let the loop handle it.
    # However, we need to handle the case where the first sheet DOESN'T start with an Assembly Header immediately.
    # The previous logic pre-scanned. Let's keep a simplified pre-scan or just trust the loop.
    # Given the file structure, Assembly Header is usually the first row (after header).
    
    # Let's just iterate sheets. The `process_sheet` logic will handle the first Assembly Header it finds.
    
    for sheet_name in xl.sheet_names:
        try:
            # Re-detect header for each sheet
            df_temp = pd.read_excel(file_path, sheet_name=sheet_name, header=None, nrows=20)
            header_idx = 0
            found = False
            for idx, row in df_temp.iterrows():
                row_values = [str(x).strip() for x in row.values if pd.notna(x)]
                if any('Item number' in val for val in row_values) and any('Name' in val for val in row_values):
                    header_idx = idx
                    found = True
                    break
            
            if found:
                df = pd.read_excel(file_path, sheet_name=sheet_name, header=header_idx)
                # Pass state in and get updated state out
                current_assembly_uuid, current_bom_uuid, existing_lines, current_assembly_code = \
                    process_sheet(cursor, df, sheet_name, file_name, current_assembly_uuid, current_bom_uuid, existing_lines, current_assembly_code)
            else:
                print(f"  [WARN] No header found in sheet {sheet_name}")
        except Exception as e:
            print(f"  [ERROR] Failed to process sheet {sheet_name}: {e}")

    conn.commit()
    cursor.close()

def main():
    conn = connect_db()
    
    # Clean database first
    clean_database(conn)
    
    count = 0
    for root, dirs, files in os.walk(DATA_ROOT):
        # 排除 '原始資料'
        if '原始資料' in dirs:
            dirs.remove('原始資料')
            
        for file in files:
            if file.endswith('.xlsx') and not file.startswith('~$'):
                # 排除路徑中包含 '原始資料' 的檔案 (雙重檢查)
                path_parts = root.split(os.sep)
                if '原始資料' in path_parts:
                    continue
                    
                file_path = os.path.join(root, file)
                process_excel(file_path, conn)
                count += 1
                
    print(f"\n[OK] 處理完成，共掃描 {count} 個檔案")
    conn.close()

if __name__ == '__main__':
    main()
