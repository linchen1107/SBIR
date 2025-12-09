#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
NSN轉換腳本調試工具
用於檢查和修正TXT到SQL轉換過程中的問題
"""

import os
import sys
import subprocess
import json
from datetime import datetime

def check_raw_data_files():
    """檢查原始資料檔案是否存在"""
    print("🔍 檢查原始資料檔案...")
    
    required_files = [
        "../raw_data/fsg/fsg.txt",
        "../raw_data/mrc_key_group/mrc_key_group.txt", 
        "../raw_data/reply_table/reply_table.txt",
        "../raw_data/fsc/fsc.txt",
        "../raw_data/nato_h6_item_name/nato_h6_item_name.txt",
        "../raw_data/inc/inc.txt",
        "../raw_data/mrc/mrc.txt",
        "../raw_data/mode_code_edit/mode_code_edit.txt",
        "../raw_data/inc_fsc_xref/inc_fsc_xref.txt",
        "../raw_data/nato_h6_inc_xref/nato_h6_inc_xref.txt",
        "../raw_data/colloquial_inc_xref/colloquial_inc_xref.txt",
        "../raw_data/fiig/fiig.txt",
        "../raw_data/mrc_reply_table_xref/mrc_reply_table_xref.txt",
        "../raw_data/fiig_inc_xref/fiig_inc_xref.txt",
        "../raw_data/fiig_inc_mrc_xref/fiig_inc_mrc_xref.txt"
    ]
    
    missing_files = []
    for file_path in required_files:
        if not os.path.exists(file_path):
            missing_files.append(file_path)
        else:
            size = os.path.getsize(file_path)
            print(f"  ✅ {file_path} ({size:,} bytes)")
    
    if missing_files:
        print(f"\n❌ 缺少 {len(missing_files)} 個原始檔案:")
        for file_path in missing_files:
            print(f"  • {file_path}")
        return False
    
    return True

def test_single_converter(converter_name):
    """測試單一轉換器"""
    print(f"\n🧪 測試轉換器: {converter_name}")
    
    converter_map = {
        "fsg": "00_convert_fsg.py",
        "mrc_key_group": "01_convert_mrc_key_group.py", 
        "reply_table": "02_convert_reply_table.py",
        "fsc": "03_convert_fsc.py",
        "nato_h6_item_name": "04_convert_nato_h6_item_name.py",
        "inc": "05_convert_inc.py",
        "mrc": "06_convert_mrc.py",
        "mode_code_edit": "07_convert_mode_code_edit.py",
        "inc_fsc_xref": "08_convert_inc_fsc_xref.py",
        "nato_h6_inc_xref": "09_convert_nato_h6_inc_xref.py",
        "colloquial_inc_xref": "10_convert_colloquial_inc_xref.py",
        "fiig": "11_convert_fiig.py",
        "mrc_reply_table_xref": "12_convert_mrc_reply_table_xref.py",
        "fiig_inc_xref": "13_convert_fiig_inc_xref.py",
        "fiig_inc_mrc_xref": "14_convert_fiig_inc_mrc_xref.py"
    }
    
    if converter_name not in converter_map:
        print(f"❌ 未知的轉換器: {converter_name}")
        print("可用的轉換器:")
        for key in converter_map.keys():
            print(f"  • {key}")
        return False
    
    script_file = converter_map[converter_name]
    
    if not os.path.exists(script_file):
        print(f"❌ 轉換腳本不存在: {script_file}")
        return False
    
    print(f"執行: python {script_file}")
    
    try:
        result = subprocess.run(
            [sys.executable, script_file],
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        
        if result.returncode == 0:
            print("✅ 轉換成功")
            print("輸出:")
            print(result.stdout)
            return True
        else:
            print("❌ 轉換失敗")
            print("錯誤輸出:")
            print(result.stderr)
            return False
            
    except Exception as e:
        print(f"❌ 執行錯誤: {e}")
        return False

def check_output_sql_files():
    """檢查輸出的SQL檔案"""
    print("\n📂 檢查輸出SQL檔案...")
    
    sql_files = []
    output_dir = "../data_import"
    
    if not os.path.exists(output_dir):
        print(f"❌ 輸出目錄不存在: {output_dir}")
        return []
    
    for i in range(15):
        filename = f"{i:02d}_import_*.sql"
        found = False
        for file in os.listdir(output_dir):
            if file.startswith(f"{i:02d}_import_") and file.endswith(".sql"):
                size = os.path.getsize(os.path.join(output_dir, file))
                print(f"  ✅ {file} ({size:,} bytes)")
                sql_files.append(file)
                found = True
                break
        
        if not found:
            print(f"  ❌ 缺少 {i:02d}_import_*.sql")
    
    return sql_files

def main():
    print("=" * 60)
    print("🔧 NSN轉換腳本調試工具")
    print("=" * 60)
    
    if len(sys.argv) < 2:
        print("使用方法:")
        print("  python debug_converter.py check          # 檢查所有檔案")
        print("  python debug_converter.py test <name>    # 測試特定轉換器")
        print("  python debug_converter.py list           # 列出所有轉換器")
        return
    
    command = sys.argv[1]
    
    if command == "check":
        # 全面檢查
        print("🔍 執行全面檢查...")
        
        # 1. 檢查原始檔案
        if not check_raw_data_files():
            print("\n❌ 原始檔案檢查失敗")
            return
        
        # 2. 檢查輸出檔案
        sql_files = check_output_sql_files()
        
        print(f"\n📊 摘要:")
        print(f"  • 原始檔案: 15個檔案檢查完成")
        print(f"  • 輸出檔案: {len(sql_files)}/15 個SQL檔案")
        
        if len(sql_files) == 15:
            print("✅ 所有檔案檢查通過")
        else:
            print("⚠️ 某些檔案缺失或有問題")
    
    elif command == "test":
        if len(sys.argv) < 3:
            print("❌ 請指定要測試的轉換器名稱")
            return
        
        converter_name = sys.argv[2]
        test_single_converter(converter_name)
        
    elif command == "list":
        print("📋 可用的轉換器:")
        converters = [
            ("fsg", "FSG聯邦供應組別"),
            ("mrc_key_group", "MRC關鍵群組"),
            ("reply_table", "回應選項表"),
            ("fsc", "FSC聯邦供應分類"),
            ("nato_h6_item_name", "NATO H6物品名稱"),
            ("inc", "INC物品名稱代碼"),
            ("mrc", "MRC主需求代碼"),
            ("mode_code_edit", "模式代碼編輯"),
            ("inc_fsc_xref", "INC-FSC交叉參照"),
            ("nato_h6_inc_xref", "NATO H6-INC對應"),
            ("colloquial_inc_xref", "俗稱INC對應"),
            ("fiig", "FIIG物品識別指南"),
            ("mrc_reply_table_xref", "MRC回應表對應"),
            ("fiig_inc_xref", "FIIG-INC對應"),
            ("fiig_inc_mrc_xref", "FIIG-INC-MRC三元關聯")
        ]
        
        for name, desc in converters:
            print(f"  • {name:<20} - {desc}")
        
        print("\n使用範例:")
        print("  python debug_converter.py test fsg")
        print("  python debug_converter.py test mrc_key_group")
    
    else:
        print(f"❌ 未知命令: {command}")

if __name__ == "__main__":
    main() 