import pandas as pd

file_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\清潔塊單元C20、C21大修料件清單--60個月.xlsx'

sheet = '定檢件'
print(f"--- Sheet: {sheet} ---")
df = pd.read_excel(file_path, sheet_name=sheet)

# Find header
header_idx = 0
for idx, row in df.iterrows():
    if 'Item number' in str(row.values):
        header_idx = idx
        break
        
df = pd.read_excel(file_path, sheet_name=sheet, header=header_idx)

# List all rows where Part is NaN
for idx, row in df.iterrows():
    part = row.get('Part')
    item = row.get('Item number')
    if pd.isna(part) or str(part).strip() == '':
        if pd.notna(item):
            print(f"Row {idx}: Item={item}, Name={row.get('Name')}")

# Check if C96271/1 is in this sheet
print("\nChecking for C96271/1 in this sheet:")
for idx, row in df.iterrows():
    if str(row.get('Item number')) == 'C96271/1':
        print(f"Row {idx}: Found C96271/1. Part={row.get('Part')}")
