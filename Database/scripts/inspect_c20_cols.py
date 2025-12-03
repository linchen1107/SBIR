import pandas as pd

file_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\清潔塊單元C20、C21大修料件清單--60個月.xlsx'

# Read with header detection logic from import script
df_temp = pd.read_excel(file_path, header=None, nrows=20)
header_row_idx = 0
for idx, row in df_temp.iterrows():
    row_values = [str(x).strip() for x in row.values if pd.notna(x)]
    if any('Item number' in val for val in row_values) and any('Name' in val for val in row_values):
        header_row_idx = idx
        break

df = pd.read_excel(file_path, header=header_row_idx)
print("Columns:", df.columns.tolist())
print("\nSample Data (first 5 rows):")
print(df.head(5))
