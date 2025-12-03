import os
import pdfplumber
import re
import pandas as pd

DATA_ROOT = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單'
OUTPUT_FILE = r'c:\github\SBIR\Database\docs\20-EMU3000系統\02-EMU3000_資料預覽.md'

# Regex Patterns
# Item Line: 1 C147356/WU 1 Pee HOUSING C
ITEM_PATTERN = re.compile(r'^(\d+)\s+([A-Z0-9/.-]+)\s+(\d+)\s+([A-Za-z]+)\s+(.+?)(?:\s+([A-Z]))?$')

def find_pdf_files(root_dir):
    pdf_files = []
    for root, dirs, files in os.walk(root_dir):
        if '原始資料' in root.split(os.sep):
            for file in files:
                if file.lower().endswith('.pdf'):
                    pdf_files.append(os.path.join(root, file))
    return pdf_files

def parse_pdf(pdf_path):
    print(f"Parsing {os.path.basename(pdf_path)}...")
    items = []
    current_assembly = "Unknown"
    
    with pdfplumber.open(pdf_path) as pdf:
        # Find start page
        start_page_idx = -1
        for i, page in enumerate(pdf.pages):
            text = page.extract_text()
            if text and ("Item number" in text or "Part" in text and "Quantity" in text):
                start_page_idx = i
                break
        
        if start_page_idx == -1:
            print("  [WARN] No headers found. Skipping.")
            return []

        # Parse pages
        for i in range(start_page_idx, len(pdf.pages)):
            page = pdf.pages[i]
            text = page.extract_text()
            if not text: continue
            
            lines = text.split('\n')
            for line in lines:
                line = line.strip()
                
                # Skip known garbage
                if "Spare parts catalog" in line or "KNORR-BREMSE" in line or "Page" in line:
                    continue
                
                # Try matching Item
                match = ITEM_PATTERN.match(line)
                if match:
                    pos, item_no, qty, unit, name, wec = match.groups()
                    items.append({
                        'Assembly': current_assembly,
                        'Part': pos,
                        'Item number': item_no,
                        'Quantity': qty,
                        'Unit': unit,
                        'Name': name,
                        'WEC': wec or ''
                    })
                else:
                    # Check for Assembly Header
                    # Heuristic: Starts with Item Code pattern, followed by Name, no digits at start
                    # e.g. II73643/4WU CLEAN. BLOCK UNIT
                    # Avoid matching "Pos. Item number..." header line
                    if "Item number" in line: continue
                    
                    parts = line.split(' ', 1)
                    if len(parts) == 2:
                        code, name = parts
                        # Simple check if code looks like item code (has numbers, slashes, uppercase)
                        if len(code) > 3 and any(c.isdigit() for c in code) and code[0].isalnum():
                             current_assembly = f"{code} {name}"
                             # print(f"  [Assembly] {current_assembly}")

    return items

def generate_markdown(all_data):
    md_content = "# EMU3000 維修物料清單預覽 (Source: PDF)\n\n"
    
    # Group by Maintenance Cycle (Folder Name)
    # File path: .../5年維護/01 .../原始資料/...
    
    files_by_cycle = {}
    
    for file_path, items in all_data.items():
        if not items: continue
        
        parts = file_path.split(os.sep)
        try:
            # Find 'EMU 3000 維修物料清單' index
            root_idx = parts.index('EMU 3000 維修物料清單')
            cycle = parts[root_idx + 1] # e.g. 5年維護
            subfolder = parts[root_idx + 2] # e.g. 01 清潔塊單元...
            
            if cycle not in files_by_cycle:
                files_by_cycle[cycle] = {}
            if subfolder not in files_by_cycle[cycle]:
                files_by_cycle[cycle][subfolder] = []
            
            files_by_cycle[cycle][subfolder].append((file_path, items))
        except:
            cycle = "Unknown"
            if cycle not in files_by_cycle: files_by_cycle[cycle] = {}
            files_by_cycle[cycle][os.path.basename(file_path)] = [(file_path, items)]

    # Sort cycles
    sorted_cycles = sorted(files_by_cycle.keys())
    
    for cycle in sorted_cycles:
        md_content += f"## {cycle}\n\n"
        
        subfolders = sorted(files_by_cycle[cycle].keys())
        for subfolder in subfolders:
            md_content += f"### {subfolder}\n\n"
            
            files = files_by_cycle[cycle][subfolder]
            for file_path, items in files:
                filename = os.path.basename(file_path)
                md_content += f"#### {filename}\n\n"
                
                # Create DataFrame for Markdown table
                df = pd.DataFrame(items)
                if not df.empty:
                    # Select columns
                    cols = ['Part', 'Item number', 'Quantity', 'Unit', 'Name', 'WEC', 'Assembly']
                    # Convert to Markdown
                    md_table = df[cols].to_markdown(index=False)
                    md_content += md_table + "\n\n"
                else:
                    md_content += "*No data extracted*\n\n"

    return md_content

def main():
    print("Scanning for PDF files...")
    pdf_files = find_pdf_files(DATA_ROOT)
    print(f"Found {len(pdf_files)} PDF files.")
    
    all_data = {}
    for pdf in pdf_files:
        items = parse_pdf(pdf)
        all_data[pdf] = items
        print(f"  Extracted {len(items)} items.")
        
    print("Generating Markdown...")
    md_content = generate_markdown(all_data)
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(md_content)
        
    print(f"Done! Written to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
