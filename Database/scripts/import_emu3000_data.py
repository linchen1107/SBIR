#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EMU3000 維修物料清單匯入工具
- 自動遍歷資料夾，尋找所有 .xlsx 檔案
- 將資料夾視為父項 (組件)，Excel 內容視為子項 (零件)
- 建立 Item, BOM, และ BOM_LINE 記錄
"""
import pandas as pd
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
import uuid
import sys
import os

# --- 資料庫連線參數 (請根據您的環境修改) ---
DB_PARAMS = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v2',
    'user': 'postgres',
    'password': 'willlin07'
}

# --- EMU3000 資料根目錄 ---
ROOT_DIR = 'c:/github/SBIR/Database/data/EMU 3000 維修物料清單'

#
# ==============================================================================
#  ❗❗❗ 重要：請在此處定義 Excel 欄位對應 ❗❗❗
# ==============================================================================
#
# 請根據您 Excel 檔案的實際情況，填寫欄位名稱或索引。
# 如果使用欄位名稱，請確保所有 Excel 檔案的欄位名都一致。
# 如果使用索引 (從 0 開始)，則不需要擔心欄位名。
#
# --- 範例 ---
# COLUMN_MAPPING = {
#     "part_number": "件號",  # 用於 BOM_LINE 的 quantity
#     "description_zh": "中文品名",
#     "quantity": "數量",
#     "manufacturer": "製造商",
# }
#
COLUMN_MAPPING = {
    # --- 請填寫 ---
    "part_number": "料號",         # 子項目的料號 (Child Item Code)
    "description_zh": "中文品名",  # 子項目的中文描述 (Child Item Name)
    "description_en": "英文品名",  # 子項目的英文描述 (Child Item Name)
    "quantity": "數量",             # 該子項在父項中的數量 (Quantity per Assembly)
    "unit": "單位",               # 單位 (e.g., EA, PC)
    "manufacturer": "製造商",     # 供應商/製造商名稱
    "cage_code": "廠商代號",      # CAGE Code
    # --- 可選欄位 ---
    # "remark": "備註",
}


def get_db_connection():
    """建立資料庫連線"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        conn.set_client_encoding('UTF8')
        print("✅ 資料庫連線成功")
        return conn
    except psycopg2.OperationalError as e:
        print(f"❌ 資料庫連線失敗: {e}")
        sys.exit(1)

def clean_value(value):
    """清理值，處理 NaN 和空字串"""
    if pd.isna(value) or value is None:
        return None
    if isinstance(value, str):
        value = value.strip()
        return value if value else None
    return value

def get_or_create_supplier(cursor, cage_code, supplier_name=None):
    """取得或建立供應商"""
    cage_code = clean_value(cage_code)
    supplier_name = clean_value(supplier_name)

    if not cage_code and not supplier_name:
        return None

    # 優先使用 CAGE Code 查詢
    if cage_code:
        cursor.execute("SELECT supplier_id FROM Supplier WHERE cage_code = %s", (cage_code,))
        result = cursor.fetchone()
        if result:
            return result['supplier_id']
    
    # 若無 CAGE Code，使用名稱查詢
    if supplier_name:
        cursor.execute("SELECT supplier_id FROM Supplier WHERE supplier_name_zh = %s OR supplier_name_en = %s", (supplier_name, supplier_name))
        result = cursor.fetchone()
        if result:
            return result['supplier_id']

    # 建立新供應商
    new_cage_code = cage_code or f"SUP-{str(uuid.uuid4())[:8].upper()}"
    new_name = supplier_name or new_cage_code
    
    print(f"   🏭 建立新供應商: {new_name} (Code: {new_cage_code})")
    cursor.execute("""
        INSERT INTO Supplier (cage_code, supplier_name_zh, supplier_name_en, supplier_code)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (cage_code) DO NOTHING
        RETURNING supplier_id
    """, (new_cage_code, new_name, new_name, new_cage_code))
    
    result = cursor.fetchone()
    if result:
        return result['supplier_id']
    
    # 如果因為 ON CONFLICT 而沒有返回，再次查詢
    cursor.execute("SELECT supplier_id FROM Supplier WHERE cage_code = %s", (new_cage_code,))
    return cursor.fetchone()['supplier_id']


def get_or_create_item(cursor, item_code, item_name_zh, item_name_en, item_type='RM', uom='EA'):
    """取得或建立 Item"""
    item_code = clean_value(item_code)
    if not item_code:
        return None

    cursor.execute("SELECT item_uuid FROM Item WHERE item_code = %s", (item_code,))
    result = cursor.fetchone()

    if result:
        return result['item_uuid']

    item_uuid = str(uuid.uuid4())
    item_name_zh = clean_value(item_name_zh) or item_code
    item_name_en = clean_value(item_name_en) or item_code
    uom = clean_value(uom) or 'EA'

    print(f"   🔩 建立新品項: {item_code} ({item_name_zh})")
    cursor.execute("""
        INSERT INTO Item (item_uuid, item_code, item_name_zh, item_name_en, item_type, uom, status)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        RETURNING item_uuid
    """, (item_uuid, item_code, item_name_zh, item_name_en, item_type, uom, 'Active'))
    
    return cursor.fetchone()['item_uuid']

def get_or_create_bom(cursor, parent_item_uuid, revision='1.0'):
    """取得或建立 BOM 表頭"""
    cursor.execute("SELECT bom_uuid FROM BOM WHERE item_uuid = %s AND revision = %s", (parent_item_uuid, revision))
    result = cursor.fetchone()

    if result:
        return result['bom_uuid']

    bom_uuid = str(uuid.uuid4())
    print(f"   📄 建立新 BOM 版本: {revision} for item {parent_item_uuid}")
    cursor.execute("""
        INSERT INTO BOM (bom_uuid, item_uuid, revision, state, effective_from)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING bom_uuid
    """, (bom_uuid, parent_item_uuid, revision, 'Released', datetime.now()))
    
    return cursor.fetchone()['bom_uuid']

def create_bom_line(cursor, bom_uuid, child_item_uuid, qty_per, line_no):
    """建立 BOM 明細行"""
    qty_per = clean_value(qty_per)
    if not qty_per or not child_item_uuid:
        return

    try:
        qty_per = float(qty_per)
    except (ValueError, TypeError):
        print(f"   ⚠️ 數量 '{qty_per}' 不是有效數字，跳過此行。")
        return

    print(f"      🔗 連結 BOM Line: 行 {line_no}, 數量 {qty_per}")
    cursor.execute("""
        INSERT INTO BOM_LINE (line_uuid, bom_uuid, line_no, component_item_uuid, qty_per)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (bom_uuid, line_no) DO UPDATE SET
            component_item_uuid = EXCLUDED.component_item_uuid,
            qty_per = EXCLUDED.qty_per;
    """, (str(uuid.uuid4()), bom_uuid, line_no, child_item_uuid, qty_per))


def process_excel_file(cursor, file_path):
    """處理單一 Excel 檔案並建立 BOM 結構"""
    print(f"\n▶️  處理檔案: {os.path.basename(file_path)}")
    
    try:
        df = pd.read_excel(file_path)
    except Exception as e:
        print(f"  ❌ 讀取 Excel 失敗: {e}")
        return

    # --- 1. 建立父項 (組件) ---
    # 從檔案路徑中提取組件名稱和代號
    # e.g., '.../01 浮球閥--A02.../浮球閥--A02-OK.xlsx' -> parent_name = '浮球閥', parent_code = 'A02'
    
    dir_name = os.path.basename(os.path.dirname(file_path)) # e.g., 01 浮球閥--...
    
    # 簡單的解析邏輯，您可能需要根據實際情況調整
    parts = dir_name.split('--')
    parent_name = parts[0][3:] if len(parts) > 0 else dir_name # e.g., 浮球閥
    parent_code = os.path.basename(file_path).split('--')[1].split('-')[0] if len(os.path.basename(file_path).split('--')) > 1 else dir_name

    parent_item_code = f"EMU3000-{parent_code}"
    parent_item_uuid = get_or_create_item(cursor, parent_item_code, parent_name, parent_code, item_type='SEMI')
    
    if not parent_item_uuid:
        print(f"  ❌ 無法建立父項 {parent_item_code}，跳過此檔案。")
        return
        
    # --- 2. 建立 BOM 表頭 ---
    bom_uuid = get_or_create_bom(cursor, parent_item_uuid)

    # --- 3. 遍歷 Excel 行，建立子項 (零件) 和 BOM Line ---
    for index, row in df.iterrows():
        line_no = index + 1
        
        # 根據 COLUMN_MAPPING 讀取資料
        child_part_number = clean_value(row.get(COLUMN_MAPPING["part_number"]))
        if not child_part_number:
            print(f"   行 {line_no}: 料號為空，跳過。")
            continue
            
        child_name_zh = clean_value(row.get(COLUMN_MAPPING["description_zh"]))
        child_name_en = clean_value(row.get(COLUMN_MAPPING["description_en"]))
        quantity = row.get(COLUMN_MAPPING["quantity"])
        unit = clean_value(row.get(COLUMN_MAPPING["unit"]))
        
        # 建立子項 Item
        child_item_uuid = get_or_create_item(cursor, child_part_number, child_name_zh, child_name_en, item_type='RM', uom=unit)
        
        if not child_item_uuid:
            print(f"   行 {line_no}: 無法建立子項 {child_part_number}，跳過。")
            continue
            
        # 建立 BOM Line
        create_bom_line(cursor, bom_uuid, child_item_uuid, quantity, line_no)
        
        # 處理供應商資訊 (可選)
        manufacturer_name = clean_value(row.get(COLUMN_MAPPING["manufacturer"]))
        cage_code = clean_value(row.get(COLUMN_MAPPING["cage_code"]))
        if manufacturer_name or cage_code:
            supplier_id = get_or_create_supplier(cursor, cage_code, manufacturer_name)
            if supplier_id:
                # 建立 Item-Supplier 關聯
                cursor.execute("""
                    INSERT INTO Item_Supplier_xref (item_uuid, supplier_id, part_number, is_primary)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (part_number, item_uuid, supplier_id) DO NOTHING
                """, (child_item_uuid, supplier_id, child_part_number, True))


def main():
    """主程式，遍歷所有檔案並匯入"""
    
    # 檢查 COLUMN_MAPPING 是否已填寫
    if COLUMN_MAPPING.get("part_number") == "料號":
        print("🤚 請先打開 `import_emu3000_data.py` 檔案，")
        print("   並在 `COLUMN_MAPPING` 區域填寫您 Excel 檔案的實際欄位名稱或索引。")
        return

    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    try:
        # 遍歷根目錄下所有 .xlsx 檔案
        for subdir, _, files in os.walk(ROOT_DIR):
            for file in files:
                if file.endswith('.xlsx'):
                    file_path = os.path.join(subdir, file)
                    process_excel_file(cursor, file_path)
                    # 處理完一個檔案後提交一次事務
                    print(f"  💾 提交檔案 {os.path.basename(file_path)} 的變更...")
                    conn.commit()

        print("\n🎉🎉🎉 所有 EMU3000 檔案處理完成！ 🎉🎉🎉")

    except Exception as e:
        print(f"\n💥 處理過程中發生嚴重錯誤: {e}")
        print("   正在回滾所有未提交的變更...")
        conn.rollback()
        import traceback
        traceback.print_exc()
    finally:
        cursor.close()
        conn.close()
        print("\n🚪 資料庫連線已關閉。")


if __name__ == '__main__':
    main()
