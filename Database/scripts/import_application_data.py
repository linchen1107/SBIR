#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
匯入 Application 資料到資料庫

從 export.jsonl 檔案匯入資料到 sbir_equipment_db_v3.application 表
處理欄位名稱映射與資料類型轉換
"""

import json
import psycopg2
from psycopg2.extras import execute_values
from datetime import datetime
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

# 欄位名稱映射（匯出資料 -> 目標表）
FIELD_MAPPING = {
    'created_at': 'date_created',
    'updated_at': 'date_updated',
    # 其他欄位名稱相同，不需要映射
}

# 需要排除的欄位（目標表中沒有，或自動生成）
EXCLUDED_FIELDS = set()

# 目標表的所有欄位（按順序）
TARGET_FIELDS = [
    'id', 'user_id', 'item_uuid', 'form_serial_number', 'part_number',
    'english_name', 'chinese_name', 'inc_code', 'fiig_code',
    'accounting_unit_code', 'issue_unit', 'unit_price', 'spec_indicator',
    'unit_pack_quantity', 'storage_life_months', 'storage_life_action_code',
    'storage_type_code', 'secrecy_code', 'expendability_code',
    'repairability_code', 'manufacturability_code', 'source_code',
    'category_code', 'system_code', 'pn_acquisition_level',
    'pn_acquisition_source', 'manufacturer', 'part_number_reference',
    'manufacturer_name', 'agent_name', 'ship_type', 'cid_no',
    'model_type', 'equipment_name', 'usage_location', 'quantity_per_unit',
    'mrc_data', 'document_reference', 'applicant_unit', 'contact_info',
    'apply_date', 'official_nsn_stamp', 'official_nsn_final',
    'nsn_filled_at', 'nsn_filled_by', 'status', 'sub_status',
    'closed_at', 'closed_by', 'date_created', 'date_updated', 'deleted_at'
]


def connect_db():
    """連接資料庫"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("[OK] 資料庫連線成功！")
        return conn
    except Exception as e:
        print(f"[ERROR] 資料庫連線失敗: {e}")
        sys.exit(1)


def map_field_name(field_name):
    """映射欄位名稱"""
    return FIELD_MAPPING.get(field_name, field_name)


def convert_value(field_name, value):
    """轉換資料類型"""
    # 處理 NULL 值
    if value is None or value == '' or value == 'null':
        return None

    # 轉換 usage_location 為整數
    if field_name == 'usage_location':
        try:
            return int(value) if value else None
        except (ValueError, TypeError):
            return None

    # 處理 quantity_per_unit（JSON 類型）
    if field_name == 'quantity_per_unit':
        if value is None or value == '':
            return None
        # 如果是數字，轉成 JSON 格式
        if isinstance(value, (int, float)):
            return json.dumps(value)
        # 如果已經是 JSON 字串，直接返回
        if isinstance(value, str):
            try:
                json.loads(value)
                return value
            except:
                # 嘗試轉換為數字再轉 JSON
                try:
                    return json.dumps(int(value))
                except:
                    return None
        return None

    # 處理 JSON 欄位（mrc_data）
    if field_name == 'mrc_data':
        if isinstance(value, (list, dict)):
            return json.dumps(value, ensure_ascii=False)
        elif isinstance(value, str):
            try:
                # 驗證是否為有效 JSON
                json.loads(value)
                return value
            except:
                return None
        return None

    # 處理時間戳記
    if field_name in ['date_created', 'date_updated', 'nsn_filled_at', 'closed_at', 'deleted_at']:
        if isinstance(value, str):
            try:
                # 移除時區資訊（PostgreSQL timestamp without time zone）
                if 'T' in value:
                    value = value.replace('T', ' ')
                if '+' in value:
                    value = value.split('+')[0]
                return value
            except:
                return None
        return value

    # 處理 UUID
    if field_name in ['id', 'user_id', 'item_uuid', 'nsn_filled_by', 'closed_by']:
        if value and value != '':
            return str(value)
        return None

    # 處理數值
    if field_name == 'unit_price':
        try:
            return float(value) if value else None
        except (ValueError, TypeError):
            return None

    # 處理日期
    if field_name == 'apply_date':
        if isinstance(value, str) and value:
            try:
                # 轉換為日期格式
                return value.split('T')[0] if 'T' in value else value
            except:
                return None
        return None

    # 其他欄位保持原樣
    return value


def process_record(record):
    """處理單一記錄"""
    processed = {}

    for src_field, value in record.items():
        # 映射欄位名稱
        target_field = map_field_name(src_field)

        # 跳過排除的欄位
        if target_field in EXCLUDED_FIELDS:
            continue

        # 跳過不在目標表中的欄位
        if target_field not in TARGET_FIELDS:
            continue

        # 轉換資料類型
        processed[target_field] = convert_value(target_field, value)

    # 確保 item_uuid 欄位存在（可能為 NULL）
    if 'item_uuid' not in processed:
        processed['item_uuid'] = None

    return processed


def get_existing_user_ids(conn):
    """取得資料庫中存在的 user_id"""
    cursor = conn.cursor()
    cursor.execute('SELECT id FROM "User"')
    user_ids = {str(row[0]) for row in cursor.fetchall()}
    cursor.close()
    return user_ids


def import_from_jsonl(file_path, conn):
    """從 JSONL 檔案匯入資料"""
    print(f"\n開始讀取檔案: {file_path}")

    if not os.path.exists(file_path):
        print(f"[ERROR] 檔案不存在: {file_path}")
        return

    # 取得現有的 user_id
    existing_user_ids = get_existing_user_ids(conn)
    print(f"[OK] 找到 {len(existing_user_ids)} 個現有使用者")

    records = []
    skipped = 0

    # 讀取 JSONL 檔案
    with open(file_path, 'r', encoding='utf-8') as f:
        for line_no, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue

            try:
                data = json.loads(line)

                # 檢查是否為正確格式
                if 'table' not in data or 'data' not in data:
                    print(f"[WARN] 第 {line_no} 行：格式錯誤，跳過")
                    skipped += 1
                    continue

                # 只處理 applications 表的資料
                if 'applications' not in data['table'].lower():
                    continue

                # 處理記錄
                record = process_record(data['data'])
                records.append(record)

            except json.JSONDecodeError as e:
                print(f"[WARN] 第 {line_no} 行：JSON 解析錯誤，跳過 - {e}")
                skipped += 1
                continue
            except Exception as e:
                print(f"[WARN] 第 {line_no} 行：處理錯誤，跳過 - {e}")
                skipped += 1
                continue

    print(f"[OK] 讀取完成：共 {len(records)} 筆記錄，跳過 {skipped} 筆")

    if not records:
        print("沒有資料需要匯入")
        return

    # 匯入資料
    print(f"\n開始匯入資料...")
    imported = 0
    failed = 0
    cursor = conn.cursor()

    for i, record in enumerate(records, 1):
        try:
            # 檢查並處理所有 User 外鍵約束
            user_fk_fields = ['user_id', 'nsn_filled_by', 'closed_by']
            for fk_field in user_fk_fields:
                if fk_field in record and record[fk_field]:
                    if record[fk_field] not in existing_user_ids:
                        print(f"[WARN] 第 {i} 筆：{fk_field} {record[fk_field]} 不存在，設為 NULL")
                        record[fk_field] = None

            # 建立 INSERT 語句
            fields = list(record.keys())
            placeholders = ', '.join(['%s'] * len(fields))
            field_names = ', '.join([f'"{f}"' for f in fields])

            sql = f"""
                INSERT INTO application ({field_names})
                VALUES ({placeholders})
                ON CONFLICT (id) DO UPDATE SET
                    {', '.join([f'"{f}" = EXCLUDED."{f}"' for f in fields if f != 'id'])}
            """

            values = [record[f] for f in fields]
            cursor.execute(sql, values)

            imported += 1

            if i % 10 == 0:
                print(f"  已處理 {i}/{len(records)} 筆...")
                conn.commit()

        except Exception as e:
            print(f"[ERROR] 第 {i} 筆匯入失敗: {e}")
            print(f"  ID: {record.get('id', 'N/A')}")

            # 檢查字串長度超過限制的欄位
            varchar_255_fields = ['english_name', 'chinese_name', 'manufacturer',
                                 'part_number_reference', 'manufacturer_name',
                                 'model_type', 'equipment_name', 'mrc_data', 'document_reference']

            for field in varchar_255_fields:
                if field in record and record[field]:
                    val = str(record[field])
                    if len(val) > 255:
                        print(f"  [!] {field}: 長度={len(val)} (超過255)")
                        print(f"      內容預覽: {val[:100]}...")

            failed += 1
            conn.rollback()

    # 最後提交
    conn.commit()
    cursor.close()

    print(f"\n[OK] 匯入完成！")
    print(f"  成功: {imported} 筆")
    print(f"  失敗: {failed} 筆")


def main():
    """主程式"""
    print("=" * 60)
    print("Application 資料匯入工具")
    print("=" * 60)

    # 連接資料庫
    conn = connect_db()

    try:
        # 匯入 JSONL 資料
        jsonl_path = r'c:/github/SBIR/Database/export/export.jsonl'
        import_from_jsonl(jsonl_path, conn)

        # 顯示統計資訊
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM application")
        total = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM application WHERE deleted_at IS NULL")
        active = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM application WHERE deleted_at IS NOT NULL")
        deleted = cursor.fetchone()[0]

        cursor.close()

        print(f"\n資料庫統計：")
        print(f"  總記錄數: {total}")
        print(f"  有效記錄: {active}")
        print(f"  已刪除: {deleted}")

    except Exception as e:
        print(f"\n[ERROR] 匯入過程發生錯誤: {e}")
        import traceback
        traceback.print_exc()

    finally:
        conn.close()
        print("\n資料庫連線已關閉")


if __name__ == '__main__':
    main()