#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
驗證 NSN 資料匯入結果（快速版本）
"""

import psycopg2

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'options': '-c search_path=public'
}

def verify_nsn_import():
    """驗證 NSN 匯入結果"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("=" * 70)
        print("NSN 資料匯入驗證報告")
        print("=" * 70)
        print()
        
        # 檢查各表格的資料筆數
        tables = [
            ('fsg', 'FSG 聯邦補給群組'),
            ('fsc', 'FSC 聯邦補給分類'),
            ('nato_h6_item_name', 'NATO H6 物品名稱'),
            ('inc', 'INC 物品名稱代碼'),
            ('fiig', 'FIIG 識別指南'),
            ('mrc', 'MRC 物料需求代碼'),
            ('mrc_key_group', 'MRC 群組'),
            ('reply_table', '回應表'),
            ('mode_code_edit', '模式碼編輯指南'),
            ('inc_fsc_xref', 'INC-FSC 對應'),
            ('nato_h6_inc_xref', 'H6-INC 對應'),
            ('colloquial_inc_xref', '俗語 INC 對應'),
            ('fiig_inc_xref', 'FIIG-INC 對應'),
            ('mrc_reply_table_xref', 'MRC-回應表對應'),
            ('fiig_inc_mrc_xref', 'FIIG-INC-MRC 三元對應')
        ]
        
        total_records = 0
        
        for table_name, description in tables:
            cursor.execute(f"SELECT COUNT(*) FROM public.{table_name};")
            count = cursor.fetchone()[0]
            total_records += count
            status = "✓" if count > 0 else "✗"
            print(f"  {status} {description:30s}: {count:>10,} 筆")
        
        print()
        print("-" * 70)
        print(f"  總記錄數: {total_records:>10,} 筆")
        print("=" * 70)
        
        # 檢查視圖
        print()
        print("檢查視圖:")
        cursor.execute("""
            SELECT viewname 
            FROM pg_views 
            WHERE schemaname = 'public'
            ORDER BY viewname;
        """)
        views = cursor.fetchall()
        for view in views:
            print(f"  ✓ {view[0]}")
        
        cursor.close()
        conn.close()
        
        print()
        print("=" * 70)
        print("✅ NSN 資料匯入驗證完成！")
        print("=" * 70)
        
        return True
        
    except Exception as e:
        print(f"❌ 驗證失敗: {e}")
        return False

if __name__ == "__main__":
    verify_nsn_import()
