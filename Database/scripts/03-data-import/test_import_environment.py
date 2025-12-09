#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
快速測試 NSN 匯入環境
檢查資料庫連接和檔案是否就緒
"""

import sys
from pathlib import Path

# 加入匯入腳本的路徑
sys.path.insert(0, str(Path(__file__).parent))

from import_nsn_data import NSNDataImporter

def test_environment():
    """測試環境是否就緒"""
    print("=" * 60)
    print("NSN 匯入環境測試")
    print("=" * 60)
    print()
    
    # 建立匯入器
    importer = NSNDataImporter()
    
    # 1. 測試資料庫連接
    print("【1. 測試資料庫連接】")
    if not importer.test_connection():
        print("\n❌ 資料庫連接失敗")
        return False
    print()
    
    # 2. 檢查 SQL 檔案
    print("【2. 檢查 SQL 檔案】")
    missing_files = []
    total_size = 0
    
    for filename in importer.sql_files:
        filepath = importer.data_source_dir / filename
        if filepath.exists():
            size_mb = filepath.stat().st_size / (1024 * 1024)
            total_size += size_mb
            print(f"  ✓ {filename:40s} ({size_mb:>7.1f} MB)")
        else:
            missing_files.append(filename)
            print(f"  ✗ {filename:40s} (缺少)")
    
    print(f"\n  總大小: {total_size:.1f} MB")
    print()
    
    if missing_files:
        print("❌ 缺少以下檔案:")
        for f in missing_files:
            print(f"  - {f}")
        return False
    
    # 3. 檢查資料來源目錄
    print("【3. 資料來源目錄】")
    print(f"  路徑: {importer.data_source_dir}")
    print(f"  存在: {'✓' if importer.data_source_dir.exists() else '✗'}")
    print()
    
    # 4. 摘要
    print("【摘要】")
    print(f"  資料庫: {importer.db_config['dbname']}")
    print(f"  Schema: public")
    print(f"  SQL 檔案: {len(importer.sql_files)} 個")
    print(f"  總大小: {total_size:.1f} MB")
    print(f"  預估時間: 10-30 分鐘")
    print()
    
    print("=" * 60)
    print("✅ 環境檢查通過，可以開始匯入！")
    print("=" * 60)
    print()
    print("執行匯入:")
    print("  python import_nsn_data.py")
    print()
    print("或使用批次檔:")
    print("  run_import_nsn_data.bat")
    print()
    
    return True

if __name__ == "__main__":
    success = test_environment()
    sys.exit(0 if success else 1)
