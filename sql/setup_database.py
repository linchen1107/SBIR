#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
NSN料號申編系統 - 資料庫結構建立腳本
(適用於 Docker 環境)
"""

import sys
import os
import psycopg2

# --- 新的、更可靠的路徑設定 ---
# 取得目前腳本的絕對路徑
script_dir = os.path.dirname(os.path.abspath(__file__))
# 取得專案根目錄 (假設此腳本在 sql/ 資料夾下)
project_root = os.path.dirname(script_dir)
# 將專案根目錄加入到 Python 的模組搜尋路徑中
sys.path.insert(0, project_root)
# --- 結束路徑設定 ---

from sql.database_config.database_config import get_db_config_instance

def main():
    conn = None
    cur = None

    try:
        print("準備從環境變數讀取資料庫設定...")

        # --- FINAL FIX: Hardcode connection params to bypass all environment issues ---
        db_config = {
            "host": "postgres",
            "port": 5432,
            "dbname": "nsn_database",
            "user": "postgres",
            "password": "postgres",
        }
        # --- END FIX ---

        print(f"目標資料庫: {db_config.get('host')}:{db_config.get('port')}/{db_config.get('dbname')}")

        # 直接連線到目標資料庫
        conn = psycopg2.connect(**db_config)
        cur = conn.cursor()
        print("✅ 資料庫連線成功")

        # 執行 database_schema.sql 來建立所有表格結構和 schemas
        schema_file_path = os.path.join(script_dir, 'database_schema.sql')
        if not os.path.exists(schema_file_path):
            print(f"❌ 錯誤: 'database_schema.sql' 檔案不存在於 '{script_dir}'")
            return False

        print("準備執行 database_schema.sql...")
        with open(schema_file_path, 'r', encoding='utf-8') as f:
            schema_sql = f.read()

        cur.execute(schema_sql)
        conn.commit()
        print("✅ 已成功執行 database_schema.sql")

        # 驗證結果
        # 檢查 public schema 中是否有表格
        cur.execute("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public'")
        public_table_count = cur.fetchone()[0]
        print(f"✅ 在 'public' schema 中找到 {public_table_count} 張表格")

        # 檢查 web_app schema 中是否有表格
        cur.execute("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'web_app'")
        webapp_table_count = cur.fetchone()[0]
        print(f"✅ 在 'web_app' schema 中找到 {webapp_table_count} 張表格")

        if public_table_count == 0:
            print("⚠️ 警告: public schema 中沒有任何表格，請檢查 database_schema.sql 的內容。")

        print("\n🎉 資料庫結構建立完成！")

        return True

    except psycopg2.OperationalError as e:
        print(f"❌ 資料庫連線錯誤: {e}")
        print("   請確認:")
        print("   1. PostgreSQL 容器 (smartcodex-postgres) 正在運行。")
        print("   2. docker-compose.yml 中的環境變數 (DATABASE_HOST, etc.) 設定正確。")
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
