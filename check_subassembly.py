import pandas as pd

file_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\清潔塊單元C20、C21大修料件清單--60個月.xlsx'
sheet = '定檢件'

df = pd.read_excel(file_path, sheet_name=sheet)
header_idx = 0
for idx, row in df.iterrows():
    if 'Item number' in str(row.values):
        header_idx = idx
        break
df = pd.read_excel(file_path, sheet_name=sheet, header=header_idx)

print(f"Checking occurrences of 1150430/1 in {sheet}:")
for idx, row in df.iterrows():
    if str(row.get('Item number')) == '1150430/1':
        print(f"Row {idx}: Part={row.get('Part')}, Name={row.get('Name')}")
