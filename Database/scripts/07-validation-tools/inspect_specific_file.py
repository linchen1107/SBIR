import pandas as pd

file_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\16年維護\01 浮球閥--A02、A05、A10、B13、B22、B23、B24、B25、B31、B40、B41、B42、Bxx.10.01、Bxx.10.02、Bxx.10.03、Bxx.20.03.01、Bxx.20.03.02、D04、D19、D20、L03、N04、P01、T01、U05、U11\浮球閥--L03.L.xlsx'

df = pd.read_excel(file_path)
print(df.head(20))
print("\nColumns:", df.columns.tolist())
