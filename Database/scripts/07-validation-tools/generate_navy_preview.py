import os
import pandas as pd
from pathlib import Path

def generate_markdown_table(df):
    """Generates a Markdown table from a pandas DataFrame."""
    if df.empty:
        return ""
    
    # Replace NaN with empty string
    df = df.fillna("")
    
    # Create header row
    header = "| " + " | ".join(str(col) for col in df.columns) + " |"
    
    # Create separator row
    separator = "| " + " | ".join("---" for _ in df.columns) + " |"
    
    # Create data rows
    rows = []
    for _, row in df.iterrows():
        row_str = "| " + " | ".join(str(val) for val in row) + " |"
        rows.append(row_str)
        
    return "\n".join([header, separator] + rows)

def main():
    base_dir = Path(r"c:\github\SBIR\Database\data\海軍")
    output_file = Path(r"c:\github\SBIR\Database\docs\海軍\01-海軍_資料預覽.md")
    
    # Ensure output directory exists
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    target_dirs = [
        base_dir / "總表-範例",
        base_dir / "電笛_各M表"
    ]
    
    files_data = []
    
    print("Scanning files...")
    
    for target_dir in target_dirs:
        if not target_dir.exists():
            print(f"Warning: Directory not found: {target_dir}")
            continue
            
        category = target_dir.name
        for file_path in target_dir.rglob("*.xlsx"):
            if file_path.name.startswith("~$"): # Skip temporary files
                continue
                
            print(f"Processing: {file_path}")
            try:
                # Read Excel file
                # Using openpyxl engine and treating all columns as string to preserve formatting
                df = pd.read_excel(file_path, engine='openpyxl', dtype=str)
                
                files_data.append({
                    "category": category,
                    "path": file_path,
                    "rel_path": file_path.relative_to(base_dir),
                    "rows": len(df),
                    "df": df
                })
            except Exception as e:
                print(f"Error reading {file_path}: {e}")

    # Sort files by category and then filename
    files_data.sort(key=lambda x: (x["category"], x["path"].name))
    
    print("Generating Markdown...")
    
    with open(output_file, "w", encoding="utf-8") as f:
        f.write("# 海軍資料匯入預覽\n\n")
        f.write("本文件由腳本自動產生，列出所有將被匯入的 Excel 檔案內容。\n\n")
        
        # Summary Table
        f.write("## 📁 檔案統計摘要\n\n")
        f.write("| 資料夾名稱 | Excel 檔案數 |\n")
        f.write("|---|---|\n")
        
        category_counts = {}
        for item in files_data:
            cat = item["category"]
            category_counts[cat] = category_counts.get(cat, 0) + 1
            
        for cat in sorted(category_counts.keys()):
            f.write(f"| {cat} | {category_counts[cat]} |\n")
            
        f.write(f"| **總計** | **{len(files_data)}** |\n\n")
        f.write("---\n\n")
        
        # File Details
        for item in files_data:
            f.write(f"## File: {item['category']}\\{item['path'].name}\n\n")
            f.write(f"- **Path**: `{item['path']}`\n")
            f.write(f"- **Rows**: {item['rows']}\n\n")
            
            f.write(generate_markdown_table(item['df']))
            f.write("\n\n---\n\n")
            
    print(f"Done! Output written to: {output_file}")

if __name__ == "__main__":
    main()
