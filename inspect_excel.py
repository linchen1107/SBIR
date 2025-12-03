import pandas as pd
import os

file_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\清潔塊單元C20、C21大修料件清單--60個月.xlsx'

print(f"Inspecting file: {file_path}")

try:
    xl = pd.ExcelFile(file_path)
    print(f"Sheet names: {xl.sheet_names}")
    
    for sheet in xl.sheet_names:
        print(f"\n--- Sheet: {sheet} ---")
        df = pd.read_excel(file_path, sheet_name=sheet, nrows=10)
        print(df.to_string())
        
        # Also check for 'Part' column duplicates in the full sheet
        print(f"\nChecking for duplicate Parts in {sheet}...")
        df_full = pd.read_excel(file_path, sheet_name=sheet)
        # Find header
        header_idx = 0
        for idx, row in df_full.iterrows():
            row_str = str(row.values)
            if 'Item number' in row_str and 'Part' in row_str:
                header_idx = idx
                break
        
        df_data = pd.read_excel(file_path, sheet_name=sheet, header=header_idx)
        print(f"Columns: {df_data.columns.tolist()}")
        if 'Part' in df_data.columns:
            parts = df_data['Part'].dropna().tolist()
            print(f"First 10 Parts: {parts[:10]}")
            
except Exception as e:
    print(f"Error: {e}")
