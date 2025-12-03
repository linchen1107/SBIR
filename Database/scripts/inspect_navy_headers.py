import os
import pandas as pd

DATA_ROOT = r'c:\github\SBIR\Database\data\海軍\電笛_各M表'

def inspect_headers():
    if not os.path.exists(DATA_ROOT):
        print(f"Directory not found: {DATA_ROOT}")
        return

    for file in os.listdir(DATA_ROOT):
        if file.endswith('.xlsx') and not file.startswith('~$'):
            file_path = os.path.join(DATA_ROOT, file)
            print(f"\nFile: {file}")
            try:
                # Read first few rows to find header
                df = pd.read_excel(file_path, nrows=5)
                print("Columns:", df.columns.tolist())
                # Print first row to see data sample
                if not df.empty:
                    print("First row:", df.iloc[0].tolist())
            except Exception as e:
                print(f"Error reading {file}: {e}")

if __name__ == "__main__":
    inspect_headers()
