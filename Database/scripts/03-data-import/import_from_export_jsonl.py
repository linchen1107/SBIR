#!/usr/bin/env python3
"""
從 export.jsonl 匯入技術文件和 MRC 數據到 V3.0 資料庫

功能：
1. 匯入技術文件 (TechnicalDocument)
2. 匯入 MRC 規格數據
3. 如果 Item 不存在，則建立新的 Item
"""

import json
import psycopg2
from psycopg2.extras import DictCursor
import uuid
from datetime import datetime
import sys

# 資料庫連線設定
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v2',
    'user': 'postgres',
    'password': 'willlin07'
}

def connect_db():
    """連線到資料庫"""
    return psycopg2.connect(**DB_CONFIG)

def find_or_create_item(cursor, application_data):
    """
    根據申請表資料尋找或建立 Item

    Args:
        cursor: 資料庫游標
        application_data: 申請表資料

    Returns:
        item_uuid: Item 的 UUID
    """
    part_number = application_data.get('part_number')

    # 先嘗試根據 part_number 在 item_code 中尋找
    cursor.execute("""
        SELECT item_uuid FROM "ITEM"
        WHERE item_code = %s
        LIMIT 1
    """, (part_number,))

    result = cursor.fetchone()
    if result:
        print(f"  找到現有 Item: {result[0]} (part_number: {part_number})")
        return result[0]

    # 如果找不到，建立新的 Item
    item_uuid = uuid.uuid4()
    item_name_en = application_data.get('english_name', '')
    item_name_zh = application_data.get('chinese_name', '')

    cursor.execute("""
        INSERT INTO "ITEM" (
            item_uuid, item_code, item_name_zh, item_name_en,
            item_type, uom, state
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (
        item_uuid,
        part_number,
        item_name_zh,
        item_name_en,
        'RM',  # 預設為原物料
        application_data.get('issue_unit', 'EA'),
        'active'
    ))

    print(f"  建立新 Item: {item_uuid} (part_number: {part_number})")
    return item_uuid

def import_mrc_data(cursor, item_uuid, mrc_data_list):
    """
    匯入 MRC 規格數據

    Args:
        cursor: 資料庫游標
        item_uuid: Item UUID
        mrc_data_list: MRC 數據列表（從 JSON 解析）
    """
    if not mrc_data_list:
        return

    imported_count = 0
    for mrc_item in mrc_data_list:
        mrc_uuid = uuid.uuid4()

        # 檢查是否已存在相同的 MRC 記錄（根據 item_uuid 和 spec_abbr）
        cursor.execute("""
            SELECT mrc_uuid FROM "MRC"
            WHERE item_uuid = %s AND spec_abbr = %s
        """, (item_uuid, mrc_item.get('mrc_code')))

        if cursor.fetchone():
            # 更新現有記錄
            cursor.execute("""
                UPDATE "MRC" SET
                    spec_en = %s,
                    spec_zh = %s,
                    answer_en = %s,
                    answer_zh = %s,
                    spec_no = %s,
                    date_updated = CURRENT_TIMESTAMP
                WHERE item_uuid = %s AND spec_abbr = %s
            """, (
                mrc_item.get('mrc_name_en', ''),
                mrc_item.get('mrc_name_zh', ''),
                mrc_item.get('mrc_value_en', ''),
                mrc_item.get('mrc_value_zh', ''),
                mrc_item.get('sort_order', 0),
                item_uuid,
                mrc_item.get('mrc_code')
            ))
            print(f"    更新 MRC: {mrc_item.get('mrc_code')} - {mrc_item.get('mrc_name_zh')}")
        else:
            # 插入新記錄
            cursor.execute("""
                INSERT INTO "MRC" (
                    mrc_uuid, item_uuid, spec_no, spec_abbr,
                    spec_en, spec_zh, answer_en, answer_zh
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                mrc_uuid,
                item_uuid,
                mrc_item.get('sort_order', 0),
                mrc_item.get('mrc_code'),
                mrc_item.get('mrc_name_en', ''),
                mrc_item.get('mrc_name_zh', ''),
                mrc_item.get('mrc_value_en', ''),
                mrc_item.get('mrc_value_zh', '')
            ))
            print(f"    新增 MRC: {mrc_item.get('mrc_code')} - {mrc_item.get('mrc_name_zh')}")

        imported_count += 1

    print(f"  匯入 {imported_count} 筆 MRC 資料")

def import_technical_documents(cursor, item_uuid, document_reference):
    """
    匯入技術文件

    Args:
        cursor: 資料庫游標
        item_uuid: Item UUID
        document_reference: 技術文件參考字串（例如："工作圖、操作手冊"）
    """
    if not document_reference or document_reference.strip() == '':
        return

    # 將文件參考字串拆分成多個文件名稱（用逗號或頓號分隔）
    doc_names = [name.strip() for name in document_reference.replace('、', ',').split(',') if name.strip()]

    imported_count = 0
    for doc_name in doc_names:
        # 檢查文件是否已存在
        cursor.execute("""
            SELECT document_id FROM technicaldocument
            WHERE document_name = %s
        """, (doc_name,))

        result = cursor.fetchone()
        if result:
            document_id = result[0]
            print(f"    找到現有技術文件: {doc_name} (ID: {document_id})")
        else:
            # 插入新文件
            cursor.execute("""
                INSERT INTO technicaldocument (
                    document_name, document_type, document_category
                )
                VALUES (%s, %s, %s)
                RETURNING document_id
            """, (doc_name, 'Manual', 'Technical'))

            document_id = cursor.fetchone()[0]
            print(f"    建立新技術文件: {doc_name} (ID: {document_id})")

        # 建立 Item-Document 關聯（檢查是否已存在）
        cursor.execute("""
            SELECT 1 FROM item_document_xref
            WHERE item_uuid = %s AND document_id = %s
        """, (item_uuid, document_id))

        if not cursor.fetchone():
            cursor.execute("""
                INSERT INTO item_document_xref (item_uuid, document_id)
                VALUES (%s, %s)
            """, (item_uuid, document_id))
            print(f"    建立 Item-Document 關聯")

        imported_count += 1

    if imported_count > 0:
        print(f"  匯入 {imported_count} 筆技術文件")

def process_jsonl_file(file_path):
    """
    處理 JSONL 檔案並匯入資料

    Args:
        file_path: JSONL 檔案路徑
    """
    conn = connect_db()

    try:
        with conn.cursor() as cursor:
            with open(file_path, 'r', encoding='utf-8') as f:
                line_no = 0
                for line in f:
                    line_no += 1

                    # 解析 JSON 行
                    try:
                        record = json.loads(line)
                    except json.JSONDecodeError as e:
                        print(f"第 {line_no} 行 JSON 解析錯誤: {e}")
                        continue

                    # 檢查是否為 applications 表的資料
                    if record.get('table') != 'web_app.applications':
                        continue

                    data = record.get('data', {})
                    part_number = data.get('part_number')
                    form_serial = data.get('form_serial_number')

                    print(f"\n處理申請表 #{line_no}: {form_serial} - {part_number}")

                    # 1. 尋找或建立 Item
                    try:
                        item_uuid = find_or_create_item(cursor, data)
                    except Exception as e:
                        print(f"  錯誤：建立 Item 失敗 - {e}")
                        continue

                    # 2. 匯入 MRC 資料
                    mrc_data = data.get('mrc_data', [])
                    if mrc_data:
                        try:
                            import_mrc_data(cursor, item_uuid, mrc_data)
                        except Exception as e:
                            print(f"  錯誤：匯入 MRC 失敗 - {e}")
                            conn.rollback()
                            continue

                    # 3. 匯入技術文件
                    doc_ref = data.get('document_reference', '')
                    if doc_ref:
                        try:
                            import_technical_documents(cursor, item_uuid, doc_ref)
                        except Exception as e:
                            print(f"  錯誤：匯入技術文件失敗 - {e}")
                            conn.rollback()
                            continue

                    # 提交這筆資料
                    conn.commit()
                    print(f"  [OK] 完成")

        print("\n匯入完成！")

    except Exception as e:
        print(f"錯誤: {e}")
        conn.rollback()
        raise
    finally:
        conn.close()

def main():
    """主函數"""
    jsonl_file = 'c:/github/SBIR/Database/export/export.jsonl'

    print(f"開始從 {jsonl_file} 匯入資料...")
    print(f"目標資料庫: {DB_CONFIG['database']}")
    print("=" * 60)

    try:
        process_jsonl_file(jsonl_file)
    except Exception as e:
        print(f"\n匯入失敗: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()