#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
NSN料號申編系統 - Web App 資料庫結構建立腳本
(適用於 Docker 環境)
"""

import sys
import os
import psycopg2

# --- 專案路徑設定 ---
script_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(script_dir)
sys.path.insert(0, project_root)
# --- 結束路徑設定 ---

def main():
    """主執行函數"""
    conn = None
    cur = None

    try:
        print("準備建立 Web App 資料庫結構 (web_app schema)...")

        # --- 直接寫死連線參數，避免任何環境變數或快取問題 ---
        db_config = {
            "host": "postgres",
            "port": 5432,
            "dbname": "nsn_database",
            "user": "postgres",
            "password": "postgres",
        }

        print(f"目標資料庫: {db_config.get('host')}:{db_config.get('port')}/{db_config.get('dbname')}")

        conn = psycopg2.connect(**db_config)
        cur = conn.cursor()
        print("✅ 資料庫連線成功")

        # --- 新增：確保 web_app schema 存在 ---
        print("正在檢查並建立 web_app schema...")
        cur.execute("CREATE SCHEMA IF NOT EXISTS web_app;")
        print("✅ web_app schema 已就緒")
        # --- 結束 ---

        # 執行 web_app_schema.sql 來建立所有 web_app 的表格結構
        schema_file_path = os.path.join(script_dir, 'web_app_schema.sql')
        if not os.path.exists(schema_file_path):
            print(f"❌ 錯誤: 'web_app_schema.sql' 檔案不存在於 '{script_dir}'")
            return False

        print("準備執行 web_app_schema.sql...")
        with open(schema_file_path, 'r', encoding='utf-8') as f:
            schema_sql = f.read()

        cur.execute(schema_sql)
        conn.commit()
        print("✅ 已成功執行 web_app_schema.sql")

        # 驗證結果
        cur.execute("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'web_app'")
        webapp_table_count = cur.fetchone()[0]
        print(f"✅ 在 'web_app' schema 中找到 {webapp_table_count} 張表格")

        if webapp_table_count == 0:
            print("⚠️ 警告: web_app schema 中沒有任何表格，請檢查 web_app_schema.sql 的內容。")

        print("\n🎉 Web App 資料庫結構建立完成！")

        return True

    except psycopg2.OperationalError as e:
        print(f"❌ 資料庫連線錯誤: {e}")
        return False
    except Exception as e:
        print(f'❌ 發生未預期的錯誤: {e}')
        return False
    finally:
        # 確保連線和游標在任何情況下都被正確關閉，防止連線洩漏
        if cur is not None:
            try:
                cur.close()
            except Exception:
                pass
        if conn is not None:
            try:
                conn.close()
            except Exception:
                pass

if __name__ == '__main__':
    if main():
        sys.exit(0)
    else:
        sys.exit(1)
