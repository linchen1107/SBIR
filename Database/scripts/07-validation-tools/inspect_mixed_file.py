import pandas as pd

file_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\6年維護\01 剎車鉗單元--C06、C07--OK\煞車鉗單元C06.xlsx'

df = pd.read_excel(file_path)
print("--- Header ---")
print(df.columns.tolist())
print("\n--- First 10 Rows ---")
print(df.head(10))
print("\n--- Rows with Null Part (Sample) ---")
print(df[df['Part'].isna()].head(10))
