#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
建立 Application 與 Item 的關聯

根據 part_number 或其他欄位，將 application 表的 item_uuid 更新為對應的 item.item_uuid
"""

import psycopg2
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


def link_by_part_number(conn):
    """根據 part_number 建立關聯"""
    print("\n[1/3] 根據 part_number 建立關聯...")

    cursor = conn.cursor()

    # 方法1: 直接比對 part_number 與 item_code
    sql = """
        UPDATE application a
        SET item_uuid = i.item_uuid
        FROM item i
        WHERE a.item_uuid IS NULL
          AND a.part_number IS NOT NULL
          AND i.item_code = a.part_number
    """

    cursor.execute(sql)
    count1 = cursor.rowcount
    conn.commit()

    print(f"  透過 part_number = item_code 關聯: {count1} 筆")

    cursor.close()
    return count1


def link_by_nsn(conn):
    """根據 NSN 建立關聯"""
    print("\n[2/3] 根據 NSN 建立關聯...")

    cursor = conn.cursor()

    # 方法2: 比對 official_nsn_final 與 item_material_ext.nsn
    sql = """
        UPDATE application a
        SET item_uuid = ext.item_uuid
        FROM item_material_ext ext
        WHERE a.item_uuid IS NULL
          AND a.official_nsn_final IS NOT NULL
          AND ext.nsn = a.official_nsn_final
    """

    cursor.execute(sql)
    count2 = cursor.rowcount
    conn.commit()

    print(f"  透過 NSN 關聯: {count2} 筆")

    cursor.close()
    return count2


def create_missing_items(conn):
    """為未關聯的 application 創建新的 item 記錄"""
    print("\n[3/3] 為未關聯的 application 創建新品項...")

    cursor = conn.cursor()

    # 查找未關聯的 application
    cursor.execute("""
        SELECT id, part_number, chinese_name, english_name
        FROM application
        WHERE item_uuid IS NULL
          AND part_number IS NOT NULL
    """)

    unlinked = cursor.fetchall()
    print(f"  找到 {len(unlinked)} 筆未關聯的申請單")

    created = 0

    for app_id, part_number, chinese_name, english_name in unlinked:
        try:
            # 檢查是否已存在該 item_code
            cursor.execute("SELECT item_uuid FROM item WHERE item_code = %s", (part_number,))
            existing = cursor.fetchone()

            if existing:
                # 已存在，直接更新關聯
                cursor.execute("""
                    UPDATE application
                    SET item_uuid = %s
                    WHERE id = %s
                """, (existing[0], app_id))
            else:
                # 不存在，創建新 item
                cursor.execute("""
                    INSERT INTO item (item_code, item_name_zh, item_name_en, item_type, status)
                    VALUES (%s, %s, %s, 'RM', 'Active')
                    RETURNING item_uuid
                """, (part_number, chinese_name, english_name))

                new_item_uuid = cursor.fetchone()[0]

                # 更新 application 的 item_uuid
                cursor.execute("""
                    UPDATE application
                    SET item_uuid = %s
                    WHERE id = %s
                """, (new_item_uuid, app_id))

                created += 1

            # 每 10 筆提交一次
            if created % 10 == 0 and created > 0:
                conn.commit()
                print(f"    已處理 {created} 筆...")

        except Exception as e:
            print(f"[ERROR] 處理 Application {app_id} 失敗: {e}")
            conn.rollback()
            continue

    conn.commit()
    cursor.close()

    print(f"  創建新品項: {created} 筆")

    return created


def show_statistics(conn):
    """顯示統計資訊"""
    print("\n" + "=" * 60)
    print("關聯結果統計")
    print("=" * 60)

    cursor = conn.cursor()

    # 總 application 數量
    cursor.execute("SELECT COUNT(*) FROM application WHERE deleted_at IS NULL")
    total = cursor.fetchone()[0]

    # 已關聯數量
    cursor.execute("SELECT COUNT(*) FROM application WHERE item_uuid IS NOT NULL AND deleted_at IS NULL")
    linked = cursor.fetchone()[0]

    # 未關聯數量
    unlinked = total - linked

    print(f"總申請單: {total} 筆")
    print(f"已關聯: {linked} 筆 ({linked*100//total if total > 0 else 0}%)")
    print(f"未關聯: {unlinked} 筆 ({unlinked*100//total if total > 0 else 0}%)")

    # Item 總數
    cursor.execute("SELECT COUNT(*) FROM item")
    item_count = cursor.fetchone()[0]
    print(f"\n品項總數: {item_count} 筆")

    cursor.close()


def main():
    """主程式"""
    print("=" * 60)
    print("Application 與 Item 關聯工具")
    print("=" * 60)

    # 連接資料庫
    conn = connect_db()

    try:
        # 建立關聯
        count1 = link_by_part_number(conn)
        count2 = link_by_nsn(conn)
        count3 = create_missing_items(conn)

        total_linked = count1 + count2 + count3

        print(f"\n[OK] 總共關聯了 {total_linked} 筆申請單")

        # 顯示統計資訊
        show_statistics(conn)

        print("\n[OK] 所有關聯處理完成！")

    except Exception as e:
        print(f"\n[ERROR] 處理過程發生錯誤: {e}")
        import traceback
        traceback.print_exc()

    finally:
        conn.close()
        print("\n資料庫連線已關閉")


if __name__ == '__main__':
    main()