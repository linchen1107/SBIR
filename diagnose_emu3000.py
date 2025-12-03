import pandas as pd
import os

# 1. Search in markdown file
md_path = r'c:\github\SBIR\Database\docs\20-EMU3000系統\02-EMU3000_資料預覽.md'
target_code = 'II73643/4WU'
print(f"Searching for {target_code} in {md_path}...")

try:
    with open(md_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            if target_code in line:
                print(f"Found at line {i+1}: {line.strip()}")
                # Print context (previous 5 lines) to see file path
                for j in range(max(0, i-5), i):
                    print(f"  {lines[j].strip()}")
                print("-" * 20)
except Exception as e:
    print(f"Error reading MD: {e}")

# 2. Inspect Excel file
excel_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\清潔塊單元C20、C21大修料件清單--60個月.xlsx'
print(f"\nInspecting Excel: {excel_path}")

try:
    xl = pd.ExcelFile(excel_path)
    print(f"Sheet names: {xl.sheet_names}")
    
    for sheet in xl.sheet_names:
        print(f"\n=== Sheet: {sheet} ===")
        df = pd.read_excel(excel_path, sheet_name=sheet, header=None)
        
        # Find header
        header_idx = -1
        for idx, row in df.iterrows():
            row_str = str(row.values)
            if 'Item number' in row_str and 'Part' in row_str:
                header_idx = idx
                break
        
        if header_idx != -1:
            print(f"Header found at row {header_idx}")
            df_data = pd.read_excel(excel_path, sheet_name=sheet, header=header_idx)
            
            # Filter for the target assembly or Part 1
            # We want to see rows where Part is 1 or Item number is II73643/4WU
            
            print("Rows with Part '1' or Item 'II73643/4WU':")
            for idx, row in df_data.iterrows():
                p = row.get('Part')
                i = row.get('Item number')
                
                match = False
                if str(p).strip() == '1' or str(p).strip() == '1.0': match = True
                if str(i).strip() == target_code: match = True
                
                if match:
                    print(f"Row {idx+header_idx+2}: Part={repr(p)}, Item={repr(i)}")
        else:
            print("Header not found")

except Exception as e:
    print(f"Error reading Excel: {e}")
