import os
import pandas as pd
import sys

DATA_ROOT = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單'
OUTPUT_FILE = r'c:\github\SBIR\Database\docs\20-EMU3000系統\02-EMU3000_資料預覽.md'

def clean_value(val):
    if pd.isna(val):
        return ""
    s_val = str(val).strip()
    if s_val.lower() in ['nan', 'null', '', 'none']:
        return ""
    return s_val

def generate_preview():
    print(f"Generating preview to {OUTPUT_FILE}...")
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write("# EMU3000 資料匯入預覽\n\n")
        f.write("本文件由腳本自動產生，列出所有將被匯入的 Excel 檔案內容。\n\n")
        
        # Generate Summary
        f.write("## 📁 檔案統計摘要\n\n")
        f.write("| 維護週期 | 資料夾名稱 | Excel 檔案數 |\n")
        f.write("|---|---|---|\n")
        
        intervals = ['5年維護', '6年維護', '8年維護', '16年維護', '20年維護']
        total_files = 0
        
        for item in os.listdir(DATA_ROOT):
            matched_interval = None
            for interval in intervals:
                if item.startswith(interval):
                    matched_interval = interval
                    break
            
            if matched_interval:
                dir_path = os.path.join(DATA_ROOT, item)
                if os.path.isdir(dir_path):
                    count = 0
                    for root, dirs, files in os.walk(dir_path):
                        path_parts = root.split(os.sep)
                        if '原始資料' in path_parts:
                            continue
                        for file in files:
                            if file.endswith('.xlsx') and not file.startswith('~$'):
                                count += 1
                    
                    f.write(f"| {matched_interval} | {item} | {count} |\n")
                    total_files += count
        
        f.write(f"| **總計** | - | **{total_files}** |\n\n")
        f.write("---\n\n")
        
        file_count = 0
        
        for root, dirs, files in os.walk(DATA_ROOT):
            # Directory exclusion logic
            path_parts = root.split(os.sep)
            if '原始資料' in path_parts:
                continue
                
            for file in files:
                if file.endswith('.xlsx') and not file.startswith('~$'):
                    file_path = os.path.join(root, file)
                    rel_path = os.path.relpath(file_path, DATA_ROOT)
                    
                    print(f"Processing: {rel_path}")
                    
                    try:
                        # Header detection logic
                        df_temp = pd.read_excel(file_path, header=None, nrows=20)
                        header_row_idx = 0
                        found_header = False
                        
                        for idx, row in df_temp.iterrows():
                            row_values = [str(x).strip() for x in row.values if pd.notna(x)]
                            if any('Item number' in val for val in row_values) and any('Name' in val for val in row_values):
                                header_row_idx = idx
                                found_header = True
                                break
                        
                        if found_header:
                            df = pd.read_excel(file_path, header=header_row_idx)
                        else:
                            df = pd.read_excel(file_path, header=0)
                            
                        df.columns = df.columns.str.strip()
                        
                        # Filter columns to show
                        cols_to_show = ['Part', 'Item number', 'Quantity', 'Unit', 'Name', 'WEC', 'Notes', 'Kit No']
                        # Add missing columns as empty
                        for col in cols_to_show:
                            if col not in df.columns:
                                df[col] = ""
                                
                        df_display = df[cols_to_show].fillna("")
                        
                        f.write(f"## File: {rel_path}\n\n")
                        f.write(f"- **Path**: `{file_path}`\n")
                        f.write(f"- **Rows**: {len(df)}\n\n")
                        
                        # Convert to markdown table manually to avoid tabulate dependency
                        # table_md = df_display.to_markdown(index=False)
                        
                        # Custom markdown generator
                        columns = df_display.columns.tolist()
                        header = "| " + " | ".join(columns) + " |"
                        separator = "| " + " | ".join(["---"] * len(columns)) + " |"
                        
                        rows = []
                        for _, row in df_display.iterrows():
                            # Format Part column (index 0)
                            vals = list(row.values)
                            part_val = str(vals[0])
                            if part_val.endswith('.0'):
                                vals[0] = part_val[:-2]
                            
                            row_str = "| " + " | ".join(str(x).replace('\n', ' ') for x in vals) + " |"
                            rows.append(row_str)
                            
                        table_md = f"{header}\n{separator}\n" + "\n".join(rows)
                        
                        f.write(table_md)
                        f.write("\n\n---\n\n")
                        
                        file_count += 1
                        
                    except Exception as e:
                        f.write(f"## File: {rel_path}\n\n")
                        f.write(f"**ERROR**: {str(e)}\n\n---\n\n")
                        print(f"[ERROR] {file}: {e}")

    print(f"\nDone. Processed {file_count} files.")

if __name__ == '__main__':
    generate_preview()
