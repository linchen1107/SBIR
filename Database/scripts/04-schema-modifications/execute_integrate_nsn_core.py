#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
執行 Schema 重構腳本
將 public schema 更名為 web_app，並建立新的 NSN 系統
"""

import sys
import os
import psycopg2
from pathlib import Path

# 設定正確的路徑
project_root = Path(__file__).parent.parent.parent.parent
sys.path.insert(0, str(project_root / 'sql' / 'database_config'))

from database_config import get_db_config_instance


def execute_sql_file(sql_file_path: str):
    """執行 SQL 腳本文件"""
    
    # 讀取 SQL 文件
    with open(sql_file_path, 'r', encoding='utf-8') as f:
        sql_content = f.read()
    
    # 取得資料庫連接
    db_config = get_db_config_instance()
    
    try:
        # 建立連接（不使用 search_path 選項，因為我們要操作 schema）
        conn_params = db_config.get_db_params()
        # 移除 search_path 選項
        if 'options' in conn_params:
            del conn_params['options']
        
        conn = psycopg2.connect(**conn_params)
        conn.autocommit = True  # 使用 autocommit 模式
        
        print("=" * 60)
        print("開始執行 Schema 重構腳本")
        print("=" * 60)
        print(f"資料庫: {conn_params['dbname']}")
        print(f"主機: {conn_params['host']}")
        print(f"腳本: {sql_file_path}")
        print("=" * 60)
        
        # 執行 SQL
        cursor = conn.cursor()
        cursor.execute(sql_content)
        
        # 顯示所有 NOTICE 訊息
        for notice in conn.notices:
            print(notice.strip())
        
        cursor.close()
        conn.close()
        
        print("=" * 60)
        print("✅ Schema 重構完成！")
        print("=" * 60)
        
        return True
        
    except psycopg2.Error as e:
        print(f"❌ 資料庫錯誤: {e}")
        return False
    except Exception as e:
        print(f"❌ 執行失敗: {e}")
        return False

if __name__ == '__main__':
    import argparse
    import getpass
    
    # 命令列參數解析
    parser = argparse.ArgumentParser(description='執行 Schema 重構腳本')
    parser.add_argument('--host', default='localhost', help='資料庫主機 (預設: localhost)')
    parser.add_argument('--port', default=5432, type=int, help='資料庫埠號 (預設: 5432)')
    parser.add_argument('--database', default='nsn_database', help='資料庫名稱 (預設: nsn_database)')
    parser.add_argument('--user', default='postgres', help='使用者名稱 (預設: postgres)')
    parser.add_argument('--password', help='密碼 (若不提供則會提示輸入)')
    
    args = parser.parse_args()
    
    # 腳本路徑
    script_path = Path(__file__).parent / 'integrate_nsn_core.sql'
    
    if not script_path.exists():
        print(f"❌ 找不到腳本文件: {script_path}")
        sys.exit(1)
    
    # 獲取密碼
    if args.password:
        password = args.password
    else:
        password = getpass.getpass(f'請輸入 PostgreSQL 使用者 {args.user} 的密碼: ')
    
    # 設定環境變數
    os.environ['DATABASE_HOST'] = args.host
    os.environ['DATABASE_PORT'] = str(args.port)
    os.environ['DATABASE_NAME'] = args.database
    os.environ['DATABASE_USER'] = args.user
    os.environ['DATABASE_PASSWORD'] = password
    
    # 執行腳本
    success = execute_sql_file(str(script_path))
    
    if success:
        print("\n下一步:")
        print("1. 驗證 schema 結構: SELECT schema_name FROM information_schema.schemata;")
        print("2. 檢查 web_app schema 表格: SELECT tablename FROM pg_tables WHERE schemaname = 'web_app';")
        print("3. 檢查 public schema 表格: SELECT tablename FROM pg_tables WHERE schemaname = 'public';")
        sys.exit(0)
    else:
        sys.exit(1)

