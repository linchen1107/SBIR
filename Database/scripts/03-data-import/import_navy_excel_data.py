#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
從海軍 Excel 文件匯入資料到資料庫

從「廚房滅火系統ILS及APL_版4.1.xlsx」匯入資料到：
- item (品項主表)
- item_material_ext (物料延伸表)
- supplier (供應商表)
- part_number_xref (料號交叉參照表)
"""

import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
import uuid
import sys
import os

# 資料庫連線設定
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'client_encoding': 'UTF8'
}

# Excel 檔案路徑
EXCEL_PATH = r'c:/github/SBIR/Database/data/海軍/總表-範例/廚房滅火系統ILS及APL_版4.1.xlsx'

# 欄位映射（Excel 欄位名 -> 實際欄位名）
COLUMN_MAPPING = {
    '項次': 'item_no',
    '配件號碼(P/N)': 'part_number',
    '廠商英文品名': 'item_name_en',
    '中文品名': 'item_name_zh',
    '中文品名(9字內)': 'item_name_zh_short',
    '統一組類別': 'item_category',
    '品項識別碼': 'item_code',
    'NSN': 'nsn',
    '撥發單位': 'issue_unit',
    '美金單價': 'unit_price_usd',
    '品名代號': 'item_code_short',
    'FIIG': 'fiig',
    '代理商': 'agent_name',
    '廠家製造商': 'supplier_name_en',
    '廠商來源代號': 'source_code',
    '廠家登記代號': 'cage_code',
    'P/N獲得\\n程度': 'pn_obtain_level',
    'P/N獲得來源': 'pn_obtain_source',
    '會計編號': 'accounting_code',
    '重量(KG)': 'weight_kg',
    '單位包裝量': 'package_qty',
    '有無料號': 'has_stock',
    '專案代號': 'project_code',
    '武器系統代號': 'weapon_system_code',
    '存儲壽限代號': 'storage_life_code',
    '檔別代號': 'file_type_code',
    '檔別區分': 'file_type_category',
    '機密性代號': 'security_code',
    '消耗性代號': 'consumable_code',
    '規格指示': 'spec_indicator',
    '海軍軍品來源': 'navy_source',
    '儲存型式': 'storage_type',
    '壽限處理代號': 'life_process_code',
    '製造能量': 'manufacturing_capacity',
    '修理能量': 'repair_capacity',
}


def connect_db():
    """連接資料庫"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("[OK] 資料庫連線成功！")
        return conn
    except Exception as e:
        print(f"[ERROR] 資料庫連線失敗: {e}")
        sys.exit(1)


def read_excel_data(file_path, sheet_name='基本資料填寫'):
    """讀取 Excel 資料"""
    print(f"\n開始讀取 Excel 檔案: {file_path}")
    print(f"工作表: {sheet_name}")

    if not os.path.exists(file_path):
        print(f"[ERROR] 檔案不存在: {file_path}")
        return None

    try:
        # 讀取 Excel，第一行是標題
        df = pd.read_excel(file_path, sheet_name=sheet_name, header=0)

        # 移除完全空白的行
        df = df.dropna(how='all')

        print(f"[OK] 讀取到 {len(df)} 筆資料")
        print(f"欄位: {', '.join(df.columns[:10])}...")

        return df
    except Exception as e:
        print(f"[ERROR] 讀取 Excel 失敗: {e}")
        import traceback
        traceback.print_exc()
        return None


def clean_value(value):
    """清理資料值"""
    if pd.isna(value) or value == '' or str(value).strip() == '':
        return None

    # 轉換為字串並去除前後空白
    str_value = str(value).strip()

    # 處理特殊值
    if str_value.lower() in ['nan', 'none', 'null', '-']:
        return None

    return str_value


def import_suppliers(df, conn):
    """匯入供應商資料"""
    print("\n[1/4] 開始匯入供應商資料...")
    cursor = conn.cursor()
    imported = 0
    skipped = 0
    updated = 0

    # 提取唯一的供應商資料
    suppliers = df[['廠家製造商', '廠家登記代號', '廠商來源代號']].drop_duplicates().to_dict('records')

    for row in suppliers:
        supplier_name = clean_value(row.get('廠家製造商'))
        cage_code = clean_value(row.get('廠家登記代號'))
        supplier_code = clean_value(row.get('廠商來源代號'))

        if not supplier_name and not cage_code and not supplier_code:
            skipped += 1
            continue

        try:
            # 優先使用 CAGE code 處理
            if cage_code:
                # 檢查 CAGE code 是否存在
                cursor.execute("SELECT supplier_id FROM supplier WHERE cage_code = %s", (cage_code,))
                result = cursor.fetchone()
                if result:
                    # 更新現有供應商
                    cursor.execute("""
                        UPDATE supplier SET supplier_name_en = %s, supplier_code = %s 
                        WHERE cage_code = %s
                    """, (supplier_name, supplier_code, cage_code))
                    updated += 1
                else:
                    # 插入新供應商
                    cursor.execute("""
                        INSERT INTO supplier (cage_code, supplier_code, supplier_name_en, supplier_type)
                        VALUES (%s, %s, %s, 'Manufacturer')
                    """, (cage_code, supplier_code, supplier_name))
                    imported += 1
            # 其次使用 supplier_code
            elif supplier_code:
                cursor.execute("SELECT supplier_id FROM supplier WHERE supplier_code = %s", (supplier_code,))
                if not cursor.fetchone():
                    cursor.execute("""
                        INSERT INTO supplier (supplier_code, supplier_name_en, supplier_type)
                        VALUES (%s, %s, 'Manufacturer')
                    """, (supplier_code, supplier_name))
                    imported += 1
                else:
                    # 如果 supplier_code 已存在但無 cage_code，我們選擇跳過以避免衝突
                    skipped += 1
                    print(f"  [INFO] Supplier code '{supplier_code}' already exists, skipping row for '{supplier_name}'.")
                    continue
            else:
                skipped += 1
                continue
            
            conn.commit()

        except psycopg2.Error as e:
            conn.rollback()
            print(f"[WARN] 匯入供應商失敗: {e}")
            print(f"  供應商: {supplier_name}, CAGE: {cage_code}, Code: {supplier_code}")
            skipped += 1
            continue
    
    cursor.close()
    print(f"[OK] 供應商匯入完成！新增: {imported} 筆, 更新: {updated} 筆, 跳過: {skipped} 筆")

    # 返回最新的供應商映射表
    cursor = conn.cursor()
    cursor.execute("SELECT supplier_id, cage_code, supplier_code FROM supplier")
    supplier_map = {}
    for sid, cage, code in cursor.fetchall():
        if cage:
            supplier_map[cage] = sid
        if code:
            supplier_map[code] = sid
    cursor.close()
    return supplier_map


def import_items(df, conn):
    """匯入品項資料"""
    print("\n[2/4] 開始匯入品項資料...")

    cursor = conn.cursor()
    imported = 0
    skipped = 0

    item_map = {}  # item_code -> item_uuid

    for idx, row in df.iterrows():
        item_code = clean_value(row.get('品項識別碼'))
        item_name_zh = clean_value(row.get('中文品名'))
        item_name_en = clean_value(row.get('廠商英文品名'))
        uom = clean_value(row.get('撥發單位'))
        has_stock = clean_value(row.get('有無料號'))

        # 品項識別碼是必填的
        if not item_code:
            skipped += 1
            continue

        # 根據是否有料號判斷類型（簡化版，實際可能更複雜）
        if has_stock and '有' in str(has_stock):
            item_type = 'RM'  # 原物料
        else:
            item_type = 'RM'  # 預設為原物料

        try:
            # 生成 UUID
            item_uuid = str(uuid.uuid4())

            sql = """
                INSERT INTO item (item_uuid, item_code, item_name_zh, item_name_en, item_type, uom, status)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (item_code) DO UPDATE SET
                    item_name_zh = EXCLUDED.item_name_zh,
                    item_name_en = EXCLUDED.item_name_en,
                    uom = EXCLUDED.uom
                RETURNING item_uuid
            """

            cursor.execute(sql, (item_uuid, item_code, item_name_zh, item_name_en, item_type, uom, 'Active'))
            result = cursor.fetchone()
            item_uuid = str(result[0])

            item_map[item_code] = item_uuid
            imported += 1

            if imported % 10 == 0:
                print(f"  已處理 {imported} 筆品項...")
                conn.commit()

        except Exception as e:
            print(f"[ERROR] 匯入品項失敗: {e}")
            print(f"  品項: {item_code} - {item_name_zh}")
            skipped += 1
            conn.rollback()
            continue

    conn.commit()
    cursor.close()

    print(f"[OK] 品項匯入完成！成功: {imported} 筆，跳過: {skipped} 筆")

    return item_map


def import_item_material_ext(df, conn, item_map):
    """匯入品項物料延伸資料"""
    print("\n[3/4] 開始匯入品項延伸資料...")

    cursor = conn.cursor()
    imported = 0
    skipped = 0

    for idx, row in df.iterrows():
        item_code = clean_value(row.get('品項識別碼'))

        if not item_code or item_code not in item_map:
            skipped += 1
            continue

        item_uuid = item_map[item_code]

        # 提取延伸資料
        nsn = clean_value(row.get('NSN'))
        item_category = clean_value(row.get('統一組類別'))
        fiig = clean_value(row.get('FIIG'))
        item_code_short = clean_value(row.get('品名代號'))
        item_name_zh_short = clean_value(row.get('中文品名(9字內)'))
        accounting_code = clean_value(row.get('會計編號'))
        issue_unit = clean_value(row.get('撥發單位'))
        weapon_system_code = clean_value(row.get('武器系統代號'))
        project_code = clean_value(row.get('專案代號'))

        # 數值欄位
        unit_price_usd = row.get('美金單價')
        if pd.notna(unit_price_usd):
            try:
                unit_price_usd = float(unit_price_usd)
            except:
                unit_price_usd = None
        else:
            unit_price_usd = None

        weight_kg = row.get('重量(KG)')
        if pd.notna(weight_kg):
            try:
                weight_kg = float(weight_kg)
            except:
                weight_kg = None
        else:
            weight_kg = None

        package_qty = row.get('單位包裝量')
        if pd.notna(package_qty):
            try:
                package_qty = int(package_qty)
            except:
                package_qty = None
        else:
            package_qty = None

        # 布林值
        has_stock_str = clean_value(row.get('有無料號'))
        has_stock = True if has_stock_str and '有' in has_stock_str else False

        # 其他代碼
        storage_life_code = clean_value(row.get('存儲壽限代號'))
        file_type_code = clean_value(row.get('檔別代號'))
        file_type_category = clean_value(row.get('檔別區分'))
        security_code = clean_value(row.get('機密性代號'))
        consumable_code = clean_value(row.get('消耗性代號'))
        spec_indicator = clean_value(row.get('規格指示'))
        navy_source = clean_value(row.get('海軍軍品來源'))
        storage_type = clean_value(row.get('儲存型式'))
        life_process_code = clean_value(row.get('壽限處理代號'))
        manufacturing_capacity = clean_value(row.get('製造能量'))
        repair_capacity = clean_value(row.get('修理能量'))
        source_code = clean_value(row.get('廠商來源代號'))

        try:
            sql = """
                INSERT INTO item_material_ext (
                    item_uuid, item_id_last5, item_name_zh_short, nsn, item_category, item_code, fiig,
                    weapon_system_code, accounting_code, issue_unit, unit_price_usd, package_qty, weight_kg,
                    has_stock, storage_life_code, file_type_code, file_type_category, security_code,
                    consumable_code, spec_indicator, navy_source, storage_type, life_process_code,
                    manufacturing_capacity, repair_capacity, source_code, project_code
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (item_uuid) DO UPDATE SET
                    item_id_last5 = EXCLUDED.item_id_last5,
                    item_name_zh_short = EXCLUDED.item_name_zh_short,
                    nsn = EXCLUDED.nsn,
                    item_category = EXCLUDED.item_category,
                    item_code = EXCLUDED.item_code,
                    fiig = EXCLUDED.fiig,
                    unit_price_usd = EXCLUDED.unit_price_usd,
                    package_qty = EXCLUDED.package_qty,
                    weight_kg = EXCLUDED.weight_kg
            """

            # 提取後五碼
            item_id_last5 = item_code[-5:] if item_code and len(item_code) >= 5 else None

            cursor.execute(sql, (
                item_uuid, item_id_last5, item_name_zh_short, nsn, item_category, item_code_short, fiig,
                weapon_system_code, accounting_code, issue_unit, unit_price_usd, package_qty, weight_kg,
                has_stock, storage_life_code, file_type_code, file_type_category, security_code,
                consumable_code, spec_indicator, navy_source, storage_type, life_process_code,
                manufacturing_capacity, repair_capacity, source_code, project_code
            ))

            imported += 1

            if imported % 10 == 0:
                print(f"  已處理 {imported} 筆延伸資料...")
                conn.commit()

        except Exception as e:
            print(f"[ERROR] 匯入延伸資料失敗: {e}")
            print(f"  品項: {item_code}")
            skipped += 1
            conn.rollback()
            continue

    conn.commit()
    cursor.close()

    print(f"[OK] 品項延伸資料匯入完成！成功: {imported} 筆，跳過: {skipped} 筆")


def import_part_numbers(df, conn, item_map, supplier_map):
    """匯入料號交叉參照資料"""
    print("\n[4/4] 開始匯入料號交叉參照資料...")

    cursor = conn.cursor()
    imported = 0
    skipped = 0

    for idx, row in df.iterrows():
        item_code = clean_value(row.get('品項識別碼'))
        part_number = clean_value(row.get('配件號碼(P/N)'))
        cage_code = clean_value(row.get('廠家登記代號'))
        supplier_code = clean_value(row.get('廠商來源代號'))
        obtain_level = clean_value(row.get('P/N獲得\\n程度'))
        obtain_source = clean_value(row.get('P/N獲得來源'))

        # 必要欄位檢查
        if not item_code or item_code not in item_map:
            skipped += 1
            continue

        if not part_number:
            skipped += 1
            continue

        item_uuid = item_map[item_code]

        # 查找供應商ID
        supplier_id = None
        if cage_code and cage_code in supplier_map:
            supplier_id = supplier_map[cage_code]
        elif supplier_code and supplier_code in supplier_map:
            supplier_id = supplier_map[supplier_code]

        try:
            sql = """
                INSERT INTO part_number_xref (part_number, item_uuid, supplier_id, obtain_level, obtain_source, is_primary)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (part_number, item_uuid, supplier_id) DO UPDATE SET
                    obtain_level = EXCLUDED.obtain_level,
                    obtain_source = EXCLUDED.obtain_source
            """

            cursor.execute(sql, (part_number, item_uuid, supplier_id, obtain_level, obtain_source, True))

            imported += 1

            if imported % 10 == 0:
                print(f"  已處理 {imported} 筆料號...")
                conn.commit()

        except Exception as e:
            print(f"[ERROR] 匯入料號失敗: {e}")
            print(f"  P/N: {part_number}, 品項: {item_code}")
            skipped += 1
            conn.rollback()
            continue

    conn.commit()
    cursor.close()

    print(f"[OK] 料號交叉參照匯入完成！成功: {imported} 筆，跳過: {skipped} 筆")


def show_statistics(conn):
    """顯示統計資訊"""
    print("\n" + "=" * 60)
    print("資料庫統計資訊")
    print("=" * 60)

    cursor = conn.cursor()

    tables = [
        ('item', '品項'),
        ('item_material_ext', '品項延伸資料'),
        ('supplier', '供應商'),
        ('part_number_xref', '料號交叉參照')
    ]

    for table_name, table_desc in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        print(f"{table_desc:20s}: {count:5d} 筆")

    cursor.close()


def main():
    """主程式"""
    print("=" * 60)
    print("海軍 Excel 資料匯入工具")
    print("=" * 60)

    # 讀取 Excel 資料
    df = read_excel_data(EXCEL_PATH, sheet_name='基本資料填寫')

    if df is None or len(df) == 0:
        print("[ERROR] 無法讀取 Excel 資料或資料為空")
        return

    # 連接資料庫
    conn = connect_db()

    try:
        # 依序匯入資料
        supplier_map = import_suppliers(df, conn)
        item_map = import_items(df, conn)
        import_item_material_ext(df, conn, item_map)
        import_part_numbers(df, conn, item_map, supplier_map)

        # 顯示統計資訊
        show_statistics(conn)

        print("\n[OK] 所有資料匯入完成！")

    except Exception as e:
        print(f"\n[ERROR] 匯入過程發生錯誤: {e}")
        import traceback
        traceback.print_exc()

    finally:
        conn.close()
        print("\n資料庫連線已關閉")


if __name__ == '__main__':
    main()