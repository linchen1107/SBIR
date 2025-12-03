import pandas as pd
import os

files = [
    r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\6年維護\01 剎車鉗單元--C06、C07--OK\煞車卡鉗單元C07.xlsx',
    r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\6年維護\01 剎車鉗單元--C06、C07--OK\煞車鉗單元C07、C07大修料件清單--72個月.xlsx'
]

def get_assembly_code(file_path):
    try:
        xl = pd.ExcelFile(file_path)
        sheet = xl.sheet_names[0]
        df = pd.read_excel(file_path, sheet_name=sheet, header=None, nrows=20)
        
        header_idx = 0
        for idx, row in df.iterrows():
            row_str = str(row.values)
            if 'Item number' in row_str:
                header_idx = idx
                break
        
        df_data = pd.read_excel(file_path, sheet_name=sheet, header=header_idx)
        # Find Assembly (Part is NaN)
        for idx, row in df_data.iterrows():
            if pd.isna(row.get('Part')):
                return row.get('Item number')
    except Exception as e:
        return str(e)
    return None

for f in files:
    print(f"File: {os.path.basename(f)}")
    code = get_assembly_code(f)
    print(f"  Assembly Code: {code}")
