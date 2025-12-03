import os
import pandas as pd

DATA_ROOT = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單'

def audit_files():
    total_files = 0
    excel_files = 0
    processed_candidates = 0
    skipped_reasons = {}
    
    print(f"Auditing directory: {DATA_ROOT}")
    
    for root, dirs, files in os.walk(DATA_ROOT):
        # Check if directory is skipped
        # Split path to check if any component is exactly '原始資料'
        path_parts = root.split(os.sep)
        if '原始資料' in path_parts:
            # We skip '原始資料' folder content
            continue
            
        for file in files:
            total_files += 1
            file_path = os.path.join(root, file)
            
            if file.startswith('~$'):
                skipped_reasons['Temp file'] = skipped_reasons.get('Temp file', 0) + 1
                continue
                
            if not file.endswith(('.xlsx', '.xls')):
                ext = os.path.splitext(file)[1]
                skipped_reasons[f'Extension {ext}'] = skipped_reasons.get(f'Extension {ext}', 0) + 1
                continue
                
            excel_files += 1
            
            # Check if it would be processed
            try:
                # Read first few rows to detect header
                df_temp = pd.read_excel(file_path, header=None, nrows=20)
                
                header_row_idx = 0
                found_header = False
                
                # Search for a row containing 'Item number' (or similar)
                for idx, row in df_temp.iterrows():
                    row_values = [str(x).strip() for x in row.values if pd.notna(x)]
                    # Check for key columns
                    if any('Item number' in val for val in row_values) and any('Name' in val for val in row_values):
                        header_row_idx = idx
                        found_header = True
                        break
                
                if found_header:
                    df = pd.read_excel(file_path, header=header_row_idx)
                else:
                    df = pd.read_excel(file_path, header=0)

                df.columns = df.columns.str.strip()
                required_cols = ['Item number', 'Name', 'Quantity']
                
                missing = [col for col in required_cols if col not in df.columns]
                
                if missing:
                    print(f"[SKIP] {file}: Missing columns {missing}")
                    # print(f"       Found columns: {df.columns.tolist()}")
                    skipped_reasons['Missing columns'] = skipped_reasons.get('Missing columns', 0) + 1
                else:
                    processed_candidates += 1
                    
            except Exception as e:
                print(f"[ERROR] {file}: {e}")
                skipped_reasons['Read Error'] = skipped_reasons.get('Read Error', 0) + 1

    print("\n--- Audit Summary ---")
    print(f"Total files found: {total_files}")
    print(f"Excel files (non-temp): {excel_files}")
    print(f"Valid candidates (pass column check): {processed_candidates}")
    print("\nSkipped Reasons:")
    for reason, count in skipped_reasons.items():
        print(f"  {reason}: {count}")

if __name__ == '__main__':
    audit_files()
