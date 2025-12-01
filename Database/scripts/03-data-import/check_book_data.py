#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import pandas as pd
import sys
import io

# Set UTF-8 encoding for stdout on Windows
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

EXCEL_FILE = r'c:/github/SBIR/Database/data/海軍/總表-範例/廚房滅火系統ILS及APL_版4.1.xlsx'

# 讀取書籍檔建置工作表
print("=" * 80)
print("書籍檔建置工作表資料")
print("=" * 80)

df_book = pd.read_excel(EXCEL_FILE, sheet_name='書籍檔建置', header=2)
df_book_valid = df_book[df_book['BLUEPRINT_BOOK_NAME'].notna() & (df_book['BLUEPRINT_BOOK_NAME'] != 0)]

print(f"\n共有 {len(df_book_valid)} 筆技術文件\n")

for idx, row in df_book_valid.iterrows():
    print(f"技術文件 {idx+1}:")
    print(f"  書名: {row['BLUEPRINT_BOOK_NAME']}")
    print(f"  會計編號: {row['UNIT_ID']}")
    print(f"  ESWBS: {row['ESWBS']}")
    print(f"  版次: {row['DOC_VSERION']}")
    print(f"  資料類型: {row['DATA_TYPE']}")
    print(f"  資料類別: {row['DATA_CLASS']}")
    print()

# 檢查有料號和無料號工作表中是否有相關裝備資訊
print("=" * 80)
print("檢查裝備結構")
print("=" * 80)

# 檢查 BOM 工作表
try:
    df_bom = pd.read_excel(EXCEL_FILE, sheet_name='BOM -確定版', header=None, nrows=20)
    print("\nBOM 工作表前 20 行:")
    print(df_bom.to_string())
except Exception as e:
    print(f"讀取 BOM 失敗: {e}")
