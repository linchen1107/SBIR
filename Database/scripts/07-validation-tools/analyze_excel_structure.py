import os
import pandas as pd
import json

DATA_ROOT = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單'

def analyze_files():
    report = {}
    
    for root, dirs, files in os.walk(DATA_ROOT):
        if '原始資料' in dirs:
            dirs.remove('原始資料')
            
        for file in files:
            if file.endswith('.xlsx') and not file.startswith('~$'):
                if '原始資料' in root:
                    continue
                    
                file_path = os.path.join(root, file)
                try:
                    # Read first few rows to detect header
                    df = pd.read_excel(file_path, header=None, nrows=10)
                    
                    # Find header row
                    header_row_idx = -1
                    for idx, row in df.iterrows():
                        row_values = [str(x).strip() for x in row.values if pd.notna(x)]
                        if 'Item number' in row_values and 'Name' in row_values:
                            header_row_idx = idx
                            break
                    
                    if header_row_idx != -1:
                        # Read again with correct header
                        df = pd.read_excel(file_path, header=header_row_idx)
                        df.columns = df.columns.str.strip()
                        
                        # Analyze columns
                        cols = df.columns.tolist()
                        
                        # Analyze "Part" column for nulls/nans
                        part_nulls = df['Part'].isna().sum()
                        total_rows = len(df)
                        
                        # Sample data
                        sample = df.head(3).to_dict(orient='records')
                        
                        report[file] = {
                            'header_row': header_row_idx,
                            'columns': cols,
                            'total_rows': total_rows,
                            'part_nulls': part_nulls,
                            'sample': str(sample)[:500] # Limit size
                        }
                    else:
                        report[file] = {'error': 'Header not found'}
                        
                except Exception as e:
                    report[file] = {'error': str(e)}
    
    # Summarize findings
    print(f"Analyzed {len(report)} files.")
    
    # Check for unique column sets
    unique_cols = set()
    for info in report.values():
        if 'columns' in info:
            unique_cols.add(tuple(sorted(info['columns'])))
            
    print(f"\nUnique Column Sets: {len(unique_cols)}")
    for cols in unique_cols:
        print(cols)
        
    # Check for files with high null Part count
    print("\nFiles with high null Part count:")
    for file, info in report.items():
        if 'part_nulls' in info and info['part_nulls'] > 0:
            print(f"{file}: {info['part_nulls']}/{info['total_rows']} nulls")

if __name__ == '__main__':
    analyze_files()
