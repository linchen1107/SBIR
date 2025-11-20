#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Import application form data from export.jsonl to V3.0 database
"""
import json
import psycopg2
from psycopg2.extras import Json, RealDictCursor
from datetime import datetime
import uuid

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
    return psycopg2.connect(**DB_PARAMS)

def get_or_create_supplier(cursor, cage_code, name_zh, agent_name=None):
    """取得或建立供應商"""
    if not cage_code:
        return None

    # 查詢是否已存在
    cursor.execute(
        "SELECT supplier_id FROM Supplier WHERE cage_code = %s",
        (cage_code,)
    )
    result = cursor.fetchone()

    if result:
        return result[0]

    # 建立新供應商 (supplier_id 是 serial，不需要提供)
    cursor.execute("""
        INSERT INTO Supplier (cage_code, supplier_name_zh, supplier_name_en, supplier_code)
        VALUES (%s, %s, %s, %s)
        RETURNING supplier_id
    """, (cage_code, name_zh or '', name_zh or '', cage_code))

    return cursor.fetchone()[0]

def determine_item_type(data):
    """判斷物料類型 (FG/SEMI/RM)"""
    # 如果有艦型、CID、裝備名稱等，視為 FG (成品)
    if data.get('ship_type') or data.get('cid_no') or data.get('equipment_name'):
        return 'FG'

    # 如果有 INC/FIIG 碼，可能是 SEMI 或 RM
    if data.get('inc_code') or data.get('fiig_code'):
        # 根據 FSC (前4碼) 判斷
        part_number = data.get('part_number', '')
        if part_number and len(part_number) >= 4:
            fsc = part_number[:4]
            # 4xxx 系列通常是成品裝備
            if fsc.startswith('4') or fsc.startswith('5') or fsc.startswith('6'):
                return 'FG'
        return 'RM'

    return 'RM'

def get_or_create_item(cursor, data, supplier_id):
    """取得或建立 Item"""
    part_number = data.get('part_number', '').strip()

    if not part_number:
        return None

    # 查詢是否已存在（根據料號）
    cursor.execute(
        "SELECT item_uuid FROM Item WHERE item_code = %s",
        (part_number,)
    )
    result = cursor.fetchone()

    if result:
        return result[0]

    # 建立新 Item
    item_uuid = str(uuid.uuid4())
    item_type = determine_item_type(data)

    cursor.execute("""
        INSERT INTO Item (
            item_uuid, item_code, item_name_en, item_name_zh,
            item_type, status, created_at, updated_at
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING item_uuid
    """, (
        item_uuid,
        part_number,
        data.get('english_name', ''),
        data.get('chinese_name', ''),
        item_type,
        'Active',
        datetime.now(),
        datetime.now()
    ))

    item_uuid = cursor.fetchone()[0]

    # 根據類型建立延伸表
    if item_type == 'FG':
        create_equipment_ext(cursor, item_uuid, data)
    else:
        create_material_ext(cursor, item_uuid, data, supplier_id)

    return item_uuid

def create_equipment_ext(cursor, item_uuid, data):
    """建立裝備延伸表資料"""
    ship_type = data.get('ship_type', '')
    cid_no = data.get('cid_no', '')

    if not ship_type and not cid_no:
        return

    cursor.execute("""
        INSERT INTO Item_Equipment_Ext (
            item_uuid, ship_type, parent_cid, position,
            parent_equipment_zh, parent_equipment_en, installation_qty
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (item_uuid) DO NOTHING
    """, (
        item_uuid,
        ship_type or None,
        cid_no or None,
        data.get('usage_location', '') or None,
        data.get('equipment_name', '') or None,
        data.get('english_name', '') or None,
        data.get('quantity_per_unit') or None
    ))

def create_material_ext(cursor, item_uuid, data, supplier_id):
    """建立物料延伸表資料"""
    # 提取 NSN（如果有的話）
    nsn = None
    official_nsn = data.get('official_nsn_final', '')
    if official_nsn and len(official_nsn) >= 13:
        nsn = official_nsn

    unit_price = data.get('unit_price')
    if unit_price:
        try:
            unit_price = float(unit_price)
        except (ValueError, TypeError):
            unit_price = None

    cursor.execute("""
        INSERT INTO Item_Material_Ext (
            item_uuid, nsn, accounting_code, fiig, unit_price_usd,
            issue_unit, spec_indicator
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (item_uuid) DO NOTHING
    """, (
        item_uuid,
        nsn or None,
        data.get('inc_code', '') or data.get('accounting_unit_code', '') or None,
        data.get('fiig_code', '') or None,
        unit_price,
        data.get('issue_unit', '') or None,
        data.get('spec_indicator', '') or None
    ))

def create_mrc_data(cursor, item_uuid, mrc_data):
    """建立 MRC 規格資料"""
    if not mrc_data or not isinstance(mrc_data, list):
        return

    # 先刪除舊的 MRC 資料（如果存在）
    cursor.execute("DELETE FROM MRC WHERE item_uuid = %s", (item_uuid,))

    for mrc in mrc_data:
        mrc_code = mrc.get('mrc_code', '')
        if not mrc_code:
            continue

        sort_order = mrc.get('sort_order', 0)

        # mrc_id 是 serial，不需要提供
        # spec_no 是 integer，spec_abbr 才是存放 MRC code 的欄位
        cursor.execute("""
            INSERT INTO MRC (
                item_uuid, spec_no, spec_abbr,
                spec_en, spec_zh,
                answer_en, answer_zh
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            item_uuid,
            sort_order if sort_order else None,
            mrc_code,
            mrc.get('mrc_name_en', ''),
            mrc.get('mrc_name_zh', ''),
            mrc.get('mrc_value_en', ''),
            mrc.get('mrc_value_zh', '')
        ))

def create_part_number_xref(cursor, item_uuid, supplier_id, part_number_ref):
    """建立料號交叉參照"""
    if not supplier_id or not part_number_ref:
        return

    # 檢查是否已存在
    cursor.execute("""
        SELECT 1 FROM Part_Number_xref
        WHERE item_uuid = %s AND supplier_id = %s AND part_number = %s
    """, (item_uuid, supplier_id, part_number_ref))

    if cursor.fetchone():
        return

    # part_number_id 是 serial，不需要提供
    cursor.execute("""
        INSERT INTO Part_Number_xref (
            item_uuid, supplier_id, part_number,
            is_primary, created_at
        )
        VALUES (%s, %s, %s, %s, %s)
    """, (
        item_uuid,
        supplier_id,
        part_number_ref,
        True,
        datetime.now()
    ))

def create_application_form(cursor, data, item_uuid):
    """建立申編單"""
    form_no = data.get('form_serial_number', '')

    if not form_no:
        return None

    # 檢查是否已存在
    cursor.execute(
        "SELECT form_id FROM ApplicationForm WHERE form_no = %s",
        (form_no,)
    )
    result = cursor.fetchone()

    if result:
        return result[0]

    # 建立新申編單
    cursor.execute("""
        INSERT INTO ApplicationForm (
            form_no, submit_status, yetl,
            applicant_accounting_code, item_id,
            created_date, updated_date
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        RETURNING form_id
    """, (
        form_no,
        data.get('status', 'pending'),
        data.get('part_number', ''),
        data.get('accounting_unit_code', ''),
        item_uuid,
        datetime.now().date(),
        datetime.now().date()
    ))

    return cursor.fetchone()[0]

def import_record(cursor, record_data):
    """匯入單筆記錄"""
    data = record_data.get('data', {})

    # 1. 建立或取得供應商
    supplier_id = get_or_create_supplier(
        cursor,
        data.get('manufacturer'),
        data.get('manufacturer_name'),
        data.get('agent_name')
    )

    # 2. 建立或取得 Item
    item_uuid = get_or_create_item(cursor, data, supplier_id)

    if not item_uuid:
        print(f"[SKIP] {data.get('form_serial_number')} (no part number)")
        return

    # 3. 建立 MRC 資料
    mrc_data = data.get('mrc_data')
    if mrc_data:
        create_mrc_data(cursor, item_uuid, mrc_data)

    # 4. 建立料號交叉參照
    part_number_ref = data.get('part_number_reference')
    if supplier_id and part_number_ref:
        create_part_number_xref(cursor, item_uuid, supplier_id, part_number_ref)

    # 5. 建立申編單
    form_id = create_application_form(cursor, data, item_uuid)

    print(f"[OK] {data.get('form_serial_number')} - {data.get('part_number')} - {data.get('chinese_name')}")

def main():
    """主程式"""
    import_file = 'c:/github/SBIR/Database/export/export.jsonl'

    print(f"開始匯入料號申編單資料...")
    print(f"來源檔案: {import_file}")
    print("-" * 80)

    conn = get_db_connection()
    conn.set_client_encoding('UTF8')
    cursor = conn.cursor()

    imported_count = 0
    error_count = 0

    try:
        with open(import_file, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                try:
                    record = json.loads(line.strip())
                    import_record(cursor, record)
                    imported_count += 1
                except Exception as e:
                    error_count += 1
                    print(f"[ERROR] Line {line_num}: {e}")
                    conn.rollback()
                    cursor = conn.cursor()  # 重新建立 cursor

        # 提交變更
        conn.commit()
        print("-" * 80)
        print(f"[SUCCESS] Import completed!")
        print(f"  Success: {imported_count} records")
        print(f"  Failed: {error_count} records")

    except Exception as e:
        conn.rollback()
        print(f"[ERROR] Import failed: {e}")
        raise
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    main()
