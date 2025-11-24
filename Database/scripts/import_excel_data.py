#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Import kitchen fire system data from Excel to V3.0 database
"""
import pandas as pd
import psycopg2
from psycopg2.extras import Json, RealDictCursor
from datetime import datetime
import uuid
import sys

# Database connection parameters
DB_PARAMS = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v2',
    'user': 'postgres',
    'password': 'willlin07'
}

def get_db_connection():
    """建立資料庫連線"""
    conn = psycopg2.connect(**DB_PARAMS)
    conn.set_client_encoding('UTF8')
    return conn

def get_or_create_supplier(cursor, cage_code, name_zh=None):
    """取得或建立供應商"""
    if not cage_code or pd.isna(cage_code):
        return None

    cage_code = str(cage_code).strip()

    # 查詢是否已存在
    cursor.execute(
        "SELECT supplier_id FROM Supplier WHERE cage_code = %s",
        (cage_code,)
    )
    result = cursor.fetchone()

    if result:
        return result[0]

    # 建立新供應商
    cursor.execute("""
        INSERT INTO Supplier (cage_code, supplier_name_zh, supplier_name_en, supplier_code)
        VALUES (%s, %s, %s, %s)
        RETURNING supplier_id
    """, (cage_code, name_zh or cage_code, cage_code, cage_code))

    return cursor.fetchone()[0]

def clean_value(value):
    """清理值，處理 NaN 和空字串"""
    if pd.isna(value):
        return None
    if isinstance(value, str):
        value = value.strip()
        return value if value else None
    return value

def get_or_create_item(cursor, row_data):
    """取得或建立 Item - 使用欄位索引"""
    # 使用欄位索引來讀取資料 (避免編碼問題)
    # 索引 3: NSN (料號分類號碼)
    # 索引 1: 序號
    nsn = clean_value(row_data.get(3))  # NSN
    seq = clean_value(row_data.get(1))  # 序號

    # 生成料號
    if nsn:
        part_number = str(int(nsn)) if isinstance(nsn, float) else str(nsn)
        # 格式化為標準 YETL 格式或 NSN
        if len(part_number) >= 4:
            part_number = f"{part_number[:4]}YETL"
        else:
            part_number = f"NSN{part_number}"
    elif seq:
        part_number = f"ITEM{int(seq):04d}" if isinstance(seq, (int, float)) else f"ITEM{seq}"
    else:
        return None

    # 查詢是否已存在
    cursor.execute(
        "SELECT item_uuid FROM Item WHERE item_code = %s",
        (part_number,)
    )
    result = cursor.fetchone()

    if result:
        return result[0]

    # 建立新 Item
    item_uuid = str(uuid.uuid4())

    # 索引 5: 英文品名, 索引 6: 中文品名
    english_name = clean_value(row_data.get(5))
    chinese_name = clean_value(row_data.get(6))

    # 判斷物料類型 (預設為 RM)
    item_type = 'RM'

    cursor.execute("""
        INSERT INTO Item (
            item_uuid, item_code, item_name_en, item_name_zh,
            item_type, status, date_created, date_updated
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING item_uuid
    """, (
        item_uuid,
        part_number,
        english_name or '',
        chinese_name or '',
        item_type,
        'Active',
        datetime.now(),
        datetime.now()
    ))

    return cursor.fetchone()[0]

def create_material_ext(cursor, item_uuid, row_data):
    """建立物料延伸表資料 - 使用欄位索引"""
    # 提取相關資料
    # 索引 3: NSN (料號分類號碼)
    nsn_raw = clean_value(row_data.get(3))
    nsn = None
    if nsn_raw:
        # 嘗試格式化 NSN (13碼格式)
        nsn_str = str(int(nsn_raw)) if isinstance(nsn_raw, float) else str(nsn_raw)
        nsn_str = nsn_str.replace('-', '').replace(' ', '')
        if len(nsn_str) >= 9:
            # 標準 NSN 格式: NNNN-NN-NNN-NNNN
            if len(nsn_str) >= 13:
                nsn = f"{nsn_str[0:4]}-{nsn_str[4:6]}-{nsn_str[6:9]}-{nsn_str[9:13]}"
            else:
                nsn = nsn_str

    # 索引 2: INC 碼 (儲備會計號碼)
    # 索引 13: 類別號碼
    # 索引 7: 會計編號
    # 索引 8: 發放單位
    # 索引 9: 單位價格
    # 索引 12: 規格號碼
    inc_code = clean_value(row_data.get(2))
    fiig_code = clean_value(row_data.get(13))
    accounting_code = clean_value(row_data.get(7))

    unit_price = clean_value(row_data.get(9))
    if unit_price:
        try:
            unit_price = float(unit_price)
        except (ValueError, TypeError):
            unit_price = None

    issue_unit = clean_value(row_data.get(8))
    spec_indicator = clean_value(row_data.get(12))

    cursor.execute("""
        INSERT INTO Item_Material_Ext (
            item_uuid, nsn, accounting_code, fiig, unit_price_usd,
            issue_unit, spec_indicator
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (item_uuid) DO UPDATE SET
            nsn = EXCLUDED.nsn,
            accounting_code = EXCLUDED.accounting_code,
            fiig = EXCLUDED.fiig,
            unit_price_usd = EXCLUDED.unit_price_usd,
            issue_unit = EXCLUDED.issue_unit,
            spec_indicator = EXCLUDED.spec_indicator
    """, (
        item_uuid,
        nsn,
        inc_code or accounting_code,
        fiig_code,
        unit_price,
        issue_unit,
        spec_indicator
    ))

def import_row(cursor, row_data, row_num):
    """匯入單筆記錄"""
    try:
        # 1. 建立或取得供應商 (如果有 CAGE 碼)
        # 索引 24: CAGE 碼
        cage_code = clean_value(row_data.get(24))
        supplier_id = get_or_create_supplier(cursor, cage_code) if cage_code else None

        # 2. 建立或取得 Item
        item_uuid = get_or_create_item(cursor, row_data)

        if not item_uuid:
            print(f"[SKIP] Row {row_num}: No valid part number")
            return False

        # 3. 建立物料延伸資料
        create_material_ext(cursor, item_uuid, row_data)

        # 取得料號用於顯示 (索引 3: NSN, 索引 1: 序號)
        nsn = clean_value(row_data.get(3))
        seq = clean_value(row_data.get(1))

        if nsn:
            part_number = str(int(nsn)) if isinstance(nsn, float) else str(nsn)
            if len(part_number) >= 4:
                part_number = f"{part_number[:4]}YETL"
        elif seq:
            part_number = f"ITEM{int(seq):04d}" if isinstance(seq, (int, float)) else f"ITEM{seq}"
        else:
            part_number = "UNKNOWN"

        # 索引 6: 中文品名
        chinese_name = clean_value(row_data.get(6)) or ''
        print(f"[OK] Row {row_num}: {part_number} - {chinese_name}")
        return True

    except Exception as e:
        print(f"[ERROR] Row {row_num}: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """主程式"""
    import_file = 'c:/github/SBIR/1017-SBIR內部會議/總表-範例/廚房滅火系統ILS及APL_版4.1.xlsx'

    # 讀取第三個工作表 (索引2，項碼資料)
    sheet_index = 2

    print(f"開始匯入廚房滅火系統資料...")
    print(f"來源檔案: {import_file}")
    print(f"工作表索引: {sheet_index}")
    print("-" * 80)

    try:
        # 讀取 Excel
        df = pd.read_excel(import_file, sheet_name=sheet_index)
        print(f"Total rows in Excel: {len(df)}")
        print(f"Columns: {list(df.columns)}")
        print("-" * 80)

        conn = get_db_connection()
        cursor = conn.cursor()

        imported_count = 0
        skipped_count = 0
        error_count = 0

        for idx, row in df.iterrows():
            row_num = idx + 2  # Excel row number (1-indexed + header)

            # 將 row 轉換為 dict，使用索引作為 key
            row_data = {}
            for i, value in enumerate(row):
                row_data[i] = value

            # 跳過空行 (索引 1: 序號, 索引 5: 英文品名)
            if pd.isna(row_data.get(1)) and pd.isna(row_data.get(5)):
                continue

            try:
                if import_row(cursor, row_data, row_num):
                    imported_count += 1
                    # 每10筆提交一次
                    if imported_count % 10 == 0:
                        conn.commit()
                else:
                    skipped_count += 1
            except Exception as e:
                error_count += 1
                print(f"[ERROR] Row {row_num}: {e}")
                conn.rollback()
                cursor = conn.cursor()

        # 最終提交
        conn.commit()
        print("-" * 80)
        print(f"[SUCCESS] Import completed!")
        print(f"  Imported: {imported_count} records")
        print(f"  Skipped: {skipped_count} records")
        print(f"  Errors: {error_count} records")

    except Exception as e:
        print(f"[ERROR] Import failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

if __name__ == '__main__':
    main()
