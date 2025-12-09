#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
驗證 Schema 重構結果
檢查 web_app 和 public schema 的表格
"""

import psycopg2
import os

# 資料庫連接資訊
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07'
}

def verify_schema_restructure():
    """驗證 schema 重構結果"""
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("=" * 60)
        print("Schema 重構驗證報告")
        print("=" * 60)
        print()
        
        # 1. 檢查 schema 列表
        print("【1. Schema 列表】")
        cursor.execute("""
            SELECT schema_name 
            FROM information_schema.schemata 
            WHERE schema_name IN ('web_app', 'public')
            ORDER BY schema_name;
        """)
        schemas = cursor.fetchall()
        for schema in schemas:
            print(f"  ✓ {schema[0]}")
        print()
        
        # 2. 檢查 web_app schema 的表格數量
        print("【2. web_app schema 表格】")
        cursor.execute("""
            SELECT tablename 
            FROM pg_tables 
            WHERE schemaname = 'web_app'
            ORDER BY tablename;
        """)
        web_app_tables = cursor.fetchall()
        print(f"  總計: {len(web_app_tables)} 個表格")
        for table in web_app_tables[:10]:  # 顯示前10個
            print(f"  - {table[0]}")
        if len(web_app_tables) > 10:
            print(f"  ... 等 {len(web_app_tables) - 10} 個表格")
        print()
        
        # 3. 檢查 public schema 的表格（NSN 系統）
        print("【3. public schema 表格（NSN 系統）】")
        cursor.execute("""
            SELECT tablename 
            FROM pg_tables 
            WHERE schemaname = 'public'
            ORDER BY tablename;
        """)
        public_tables = cursor.fetchall()
        print(f"  總計: {len(public_tables)} 個表格")
        for table in public_tables:
            print(f"  ✓ {table[0]}")
        print()
        
        # 4. 檢查 public schema 的視圖
        print("【4. public schema 視圖】")
        cursor.execute("""
            SELECT viewname 
            FROM pg_views 
            WHERE schemaname = 'public'
            ORDER BY viewname;
        """)
        views = cursor.fetchall()
        print(f"  總計: {len(views)} 個視圖")
        for view in views:
            print(f"  ✓ {view[0]}")
        print()
        
        # 5. 驗證預期表格
        print("【5. 關鍵表格驗證】")
        expected_public_tables = [
            'fsg', 'fsc', 'inc', 'fiig', 'mrc', 
            'nato_h6_item_name', 'mode_code_edit'
        ]
        
        actual_public_tables = [t[0] for t in public_tables]
        
        for table in expected_public_tables:
            if table in actual_public_tables:
                print(f"  ✓ {table}")
            else:
                print(f"  ✗ {table} (缺少)")
        print()
        
        # 6. 檢查重要的 web_app 表格
        print("【6. web_app 關鍵表格】")
        expected_web_app_tables = ['item', 'supplier', 'user', 'application']
        actual_web_app_tables = [t[0].lower() for t in web_app_tables]
        
        for table in expected_web_app_tables:
            if table in actual_web_app_tables:
                print(f"  ✓ {table}")
            else:
                print(f"  ✗ {table} (缺少)")
        
        cursor.close()
        conn.close()
        
        print()
        print("=" * 60)
        print("✅ Schema 重構驗證完成！")
        print("=" * 60)
        
        return True
        
    except Exception as e:
        print(f"❌ 驗證失敗: {e}")
        return False

if __name__ == '__main__':
    verify_schema_restructure()
