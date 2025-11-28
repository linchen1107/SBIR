#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
從 Application 表的 mrc_data JSON 欄位提取 MRC 資料

從 application.mrc_data (JSON 陣列) 提取規格資料到 mrc 表
"""

import psycopg2
import json
import uuid
import sys

# 資料庫連線設定
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'client_encoding': 'UTF8'
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


def extract_mrc_from_applications(conn):
    """從 application 表提取 MRC 資料"""
    print("\n開始從 application 表提取 MRC 資料...")

    cursor = conn.cursor()

    # 查詢所有有 mrc_data 的 application 記錄
    cursor.execute("""
        SELECT a.id, a.item_uuid, a.mrc_data
        FROM application a
        WHERE a.mrc_data IS NOT NULL
          AND a.item_uuid IS NOT NULL
          AND a.deleted_at IS NULL
    """)

    applications = cursor.fetchall()
    print(f"[OK] 找到 {len(applications)} 筆包含 MRC 資料的申請單")

    total_mrc = 0
    imported = 0
    skipped = 0
    error_count = 0

    for app_id, item_uuid, mrc_data_json in applications:
        try:
            # 解析 JSON 資料
            if isinstance(mrc_data_json, str):
                mrc_data = json.loads(mrc_data_json)
            else:
                mrc_data = mrc_data_json

            # 如果不是陣列，跳過
            if not isinstance(mrc_data, list):
                print(f"[WARN] Application {app_id}: mrc_data 不是陣列格式，跳過")
                skipped += 1
                continue

            total_mrc += len(mrc_data)

            # 逐一插入 MRC 記錄
            for mrc_item in mrc_data:
                try:
                    # 提取欄位
                    mrc_code = mrc_item.get('mrc_code')
                    sort_order = mrc_item.get('sort_order')
                    mrc_name_en = mrc_item.get('mrc_name_en')
                    mrc_name_zh = mrc_item.get('mrc_name_zh')
                    mrc_value_en = mrc_item.get('mrc_value_en', '')
                    mrc_value_zh = mrc_item.get('mrc_value_zh', '')

                    # 插入 MRC 表
                    mrc_uuid = str(uuid.uuid4())

                    insert_sql = """
                        INSERT INTO mrc (
                            mrc_uuid, item_uuid, spec_no, spec_abbr,
                            spec_en, spec_zh, answer_en, answer_zh
                        )
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT DO NOTHING
                    """

                    cursor.execute(insert_sql, (
                        mrc_uuid,
                        item_uuid,
                        sort_order,
                        mrc_code,
                        mrc_name_en,
                        mrc_name_zh,
                        mrc_value_en,
                        mrc_value_zh
                    ))

                    imported += 1

                except Exception as e:
                    print(f"[ERROR] 插入 MRC 失敗: {e}")
                    print(f"  Application ID: {app_id}, MRC 項目: {mrc_item}")
                    error_count += 1
                    continue

            # 每處理 10 筆申請單就提交一次
            if (applications.index((app_id, item_uuid, mrc_data_json)) + 1) % 10 == 0:
                conn.commit()
                print(f"  已處理 {applications.index((app_id, item_uuid, mrc_data_json)) + 1}/{len(applications)} 筆申請單...")

        except Exception as e:
            print(f"[ERROR] 處理 Application {app_id} 失敗: {e}")
            error_count += 1
            conn.rollback()
            continue

    # 最後提交
    conn.commit()
    cursor.close()

    print(f"\n[OK] MRC 資料提取完成！")
    print(f"  總 MRC 項目: {total_mrc}")
    print(f"  成功匯入: {imported}")
    print(f"  跳過: {skipped}")
    print(f"  錯誤: {error_count}")

    return imported


def show_statistics(conn):
    """顯示統計資訊"""
    print("\n" + "=" * 60)
    print("MRC 資料統計")
    print("=" * 60)

    cursor = conn.cursor()

    # 總 MRC 數量
    cursor.execute("SELECT COUNT(*) FROM mrc")
    total_mrc = cursor.fetchone()[0]
    print(f"總 MRC 記錄: {total_mrc} 筆")

    # 按品項分組
    cursor.execute("""
        SELECT i.item_name_zh, COUNT(m.mrc_uuid) as mrc_count
        FROM item i
        LEFT JOIN mrc m ON i.item_uuid = m.item_uuid
        WHERE m.mrc_uuid IS NOT NULL
        GROUP BY i.item_name_zh
        ORDER BY mrc_count DESC
        LIMIT 10
    """)

    print("\n前 10 個品項的 MRC 數量:")
    for item_name, count in cursor.fetchall():
        print(f"  {item_name:30s}: {count:3d} 筆")

    # 按規格代碼分組
    cursor.execute("""
        SELECT spec_abbr, COUNT(*) as count
        FROM mrc
        WHERE spec_abbr IS NOT NULL
        GROUP BY spec_abbr
        ORDER BY count DESC
        LIMIT 10
    """)

    print("\n前 10 個常用規格代碼:")
    for abbr, count in cursor.fetchall():
        print(f"  {abbr:20s}: {count:3d} 次")

    cursor.close()


def main():
    """主程式"""
    print("=" * 60)
    print("MRC 資料匯入工具（從 Application）")
    print("=" * 60)

    # 連接資料庫
    conn = connect_db()

    try:
        # 提取並匯入 MRC 資料
        imported = extract_mrc_from_applications(conn)

        if imported > 0:
            # 顯示統計資訊
            show_statistics(conn)

        print("\n[OK] 所有資料處理完成！")

    except Exception as e:
        print(f"\n[ERROR] 處理過程發生錯誤: {e}")
        import traceback
        traceback.print_exc()

    finally:
        conn.close()
        print("\n資料庫連線已關閉")


if __name__ == '__main__':
    main()