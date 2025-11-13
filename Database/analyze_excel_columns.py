#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
分析電笛 Excel M 表的欄位結構
"""
import pandas as pd
import os

excel_dir = r"c:\github\SBIR\Database\電笛_各M表"

# 定義要分析的檔案
files = {
    "2M": "2M_B010102單位構型檔_電笛.xlsx",
    "3M": "3M_單機資料檔(3M)(B010103)電笛.xlsx",
    "16M": "16M_單機特性檔(B010104)電笛.xlsx",
    "18M": "18M_單機零附件檔(B010105)電笛.xlsx",
    "19M": "19M_料號基本資料檔(B010106)電笛.xlsx",
    "20M": "20M_料號主要件號檔(B010107)電笛.xlsx",
    "書籍檔": "書籍檔_建置範本 電笛.xlsx"
}

print("=" * 100)
print("電笛系統 Excel M 表欄位分析")
print("=" * 100)

for key, filename in files.items():
    filepath = os.path.join(excel_dir, filename)

    if not os.path.exists(filepath):
        print(f"\n❌ {key}: 檔案不存在 - {filename}")
        continue

    try:
        # 讀取 Excel，嘗試第一個 sheet
        df = pd.read_excel(filepath, sheet_name=0, nrows=0)  # 只讀取欄位名

        print(f"\n{'='*80}")
        print(f"📋 {key} - {filename}")
        print(f"{'='*80}")
        print(f"欄位數量: {len(df.columns)}")
        print(f"\n欄位列表:")

        for idx, col in enumerate(df.columns, 1):
            print(f"  {idx:2d}. {col}")

    except Exception as e:
        print(f"\n❌ {key}: 讀取失敗 - {str(e)}")

print("\n" + "=" * 100)
print("分析完成！")
print("=" * 100)