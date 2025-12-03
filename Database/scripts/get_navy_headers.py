import os
import pandas as pd

DATA_ROOT = r'c:\github\SBIR\Database\data\海軍\電笛_各M表'

def get_headers(filename):
    file_path = os.path.join(DATA_ROOT, filename)
    if not os.path.exists(file_path):
        return
    
    print(f"\n--- {filename} ---")
    try:
        # Read header row (Row 0)
        df = pd.read_excel(file_path, header=0, nrows=0)
        print(list(df.columns))
    except Exception as e:
        print(e)

def main():
    files = [
        "19M_料號基本資料檔(B010106)電笛.xlsx",
        "20M_料號主要件號檔(B010107)電笛.xlsx",
        "18M_單機零附件檔(B010105)電笛.xlsx",
        "3M_單機資料檔(3M)(B010103)電笛.xlsx"
    ]
    for f in files:
        get_headers(f)

if __name__ == "__main__":
    main()
