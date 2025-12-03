import pandas as pd

file_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\6年維護\01 剎車鉗單元--C06、C07--OK\煞車卡鉗單元C07.xlsx'

xl = pd.ExcelFile(file_path)
for sheet in xl.sheet_names:
    print(f"--- Sheet: {sheet} ---")
    df = pd.read_excel(file_path, sheet_name=sheet)
    # Find header
    header_idx = 0
    for idx, row in df.iterrows():
        if 'Item number' in str(row.values):
            header_idx = idx
            break
    
    df = pd.read_excel(file_path, sheet_name=sheet, header=header_idx)
    
    # List all Assembly Headers
    print("Assembly Headers found:")
    for idx, row in df.iterrows():
        if pd.isna(row.get('Part')):
            print(f"  Row {idx}: Item={row.get('Item number')}, Name={row.get('Name')}")
