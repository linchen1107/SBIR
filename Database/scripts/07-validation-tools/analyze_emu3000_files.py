#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
分析 EMU3000 維修物料清單檔案
"""

import pandas as pd
import os
import glob
from collections import defaultdict

def analyze_emu3000_files():
    """分析所有 EMU3000 Excel 檔案"""

    base_path = r'c:/github/SBIR/Database/data/EMU3000/EMU 3000 維修物料清單'

    periods = {
        '60個月(5年)': '5年維護',
        '72個月(6年)': '6年維護',
        '96個月(8年)': '8年維護--(Bxx、B5x的都有缺、其他有缺的詳細寫在原始資料內)',
        '192個月(16年)': '16年維護',
        '240個月(20年)': '20年維護'
    }

    print('=' * 80)
    print('EMU3000 維修物料清單檔案分析報告')
    print('=' * 80)
    print()

    all_files = []
    wec_codes = defaultdict(int)
    total_parts = 0
    total_equipment = 0

    for period_label, period_name in periods.items():
        period_path = os.path.join(base_path, period_name)

        if not os.path.exists(period_path):
            print(f'【{period_label}】目錄不存在')
            print()
            continue

        # 找出所有 xlsx 檔案 (排除原始資料目錄)
        xlsx_files = []
        for root, dirs, files in os.walk(period_path):
            if '原始資料' in root:
                continue
            for file in files:
                if file.endswith('.xlsx') and not file.startswith('~$'):
                    xlsx_files.append(os.path.join(root, file))

        print(f'【{period_label}】')
        print(f'  檔案數量: {len(xlsx_files)}')

        if not xlsx_files:
            print(f'  狀態: 無檔案')
            print()
            continue

        # 分析檔案內容
        period_parts = 0
        period_equipment = 0
        period_sheets = set()

        for xlsx_file in xlsx_files:
            try:
                xls = pd.ExcelFile(xlsx_file)
                period_sheets.update(xls.sheet_names)

                # 統計零件數
                for sheet_name in xls.sheet_names:
                    df = pd.read_excel(xlsx_file, sheet_name=sheet_name, header=0)

                    # 有 Part 欄位的是實際零件
                    parts_count = df['Part'].notna().sum()
                    period_parts += parts_count

                    # 無 Part 欄位的是裝備資訊
                    equipment_count = df['Part'].isna().sum()
                    period_equipment += equipment_count

                    # 統計 WEC 代碼
                    if 'WEC' in df.columns:
                        wec_values = df['WEC'].dropna()
                        for wec in wec_values:
                            if wec and str(wec).strip():
                                wec_codes[str(wec).strip()] += 1

                all_files.append({
                    'period': period_label,
                    'file': os.path.basename(xlsx_file),
                    'sheets': len(xls.sheet_names),
                    'path': xlsx_file
                })

            except Exception as e:
                print(f'  警告: 無法讀取 {os.path.basename(xlsx_file)}: {e}')

        print(f'  工作表類型: {list(period_sheets)}')
        print(f'  零件總數: {period_parts}')
        print(f'  裝備位置數: {period_equipment}')

        total_parts += period_parts
        total_equipment += period_equipment

        # 顯示前3個檔案名稱
        if len(xlsx_files) <= 3:
            for f in xlsx_files:
                print(f'    - {os.path.basename(f)}')
        else:
            for f in xlsx_files[:3]:
                print(f'    - {os.path.basename(f)}')
            print(f'    ... 還有 {len(xlsx_files)-3} 個檔案')

        print()

    print('=' * 80)
    print('統計摘要')
    print('=' * 80)
    print(f'總檔案數: {len(all_files)}')
    print(f'總零件數: {total_parts}')
    print(f'總裝備位置數: {total_equipment}')
    print()

    if wec_codes:
        print('WEC 代碼統計:')
        for wec, count in sorted(wec_codes.items()):
            print(f'  {wec}: {count} 次')
        print()

    return all_files

if __name__ == '__main__':
    analyze_emu3000_files()
