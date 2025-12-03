import pdfplumber
import re

pdf_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\原始資料\C20_E-II73643-4WU_00-EN_OCR.pdf'

def parse_page_5(path):
    with pdfplumber.open(path) as pdf:
        page = pdf.pages[4]
        text = page.extract_text()
        
        lines = text.split('\n')
        print(f"Total lines: {len(lines)}")
        
        # Regex Pattern
        # 1 C147356/WU 1 Pee HOUSING C
        # Pos Item Qty Unit Name WEC
        pattern = re.compile(r'^(\d+)\s+([A-Z0-9/.-]+)\s+(\d+)\s+([A-Za-z]+)\s+(.+?)(?:\s+([A-Z]))?$')
        
        parsed_data = []
        
        for line in lines:
            line = line.strip()
            match = pattern.match(line)
            if match:
                data = match.groups()
                parsed_data.append(data)
                print(f"[MATCH] {data}")
            else:
                # Check if it's an Assembly Header (e.g. II73643/4WU CLEAN. BLOCK UNIT)
                # Assembly header usually doesn't have Pos, Qty, Unit
                if "CLEAN. BLOCK UNIT" in line:
                     print(f"[ASSEMBLY] {line}")
                else:
                     print(f"[SKIP] {line}")

        print(f"\nParsed {len(parsed_data)} items.")

parse_page_5(pdf_path)
