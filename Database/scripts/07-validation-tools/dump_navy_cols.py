import os
import pandas as pd

DATA_ROOT = r'c:\github\SBIR\Database\data\海軍\電笛_各M表'

def dump_cols():
    with open('cols_dump.txt', 'w', encoding='utf-8') as f:
        for file in os.listdir(DATA_ROOT):
            if file.endswith('.xlsx') and not file.startswith('~$'):
                try:
                    df = pd.read_excel(os.path.join(DATA_ROOT, file), header=0, nrows=0)
                    f.write(f"File: {file}\n")
                    f.write(f"Columns: {df.columns.tolist()}\n\n")
                except Exception as e:
                    f.write(f"File: {file} Error: {e}\n\n")

if __name__ == "__main__":
    dump_cols()
