import os
import pandas as pd

DATA_ROOT = r'c:\github\SBIR\Database\data\海軍\電笛_各M表'

def inspect_file(filename):
    file_path = os.path.join(DATA_ROOT, filename)
    if not os.path.exists(file_path):
        print(f"File not found: {filename}")
        return

    print(f"\n=== Inspecting {filename} ===")
    try:
        # Read header=1 (row 2) because row 1 usually contains Chinese descriptions
        # and row 2 contains English codes or vice versa.
        # Let's read without header first to see the structure.
        df = pd.read_excel(file_path, header=None, nrows=5)
        print(df.to_string())
    except Exception as e:
        print(f"Error: {e}")

def main():
    files_to_inspect = [
        "19M_料號基本資料檔(B010106)電笛.xlsx",
        "20M_料號主要件號檔(B010107)電笛.xlsx",
        "18M_單機零附件檔(B010105)電笛.xlsx",
        "3M_單機資料檔(3M)(B010103)電笛.xlsx"
    ]
    for f in files_to_inspect:
        inspect_file(f)

if __name__ == "__main__":
    main()
