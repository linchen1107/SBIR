import pdfplumber
import pandas as pd

pdf_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\原始資料\C20_E-II73643-4WU_00-EN_OCR.pdf'

def extract_table_from_pdf(path):
    print(f"Extracting from: {path}")
    all_rows = []
    with pdfplumber.open(path) as pdf:
        for i, page in enumerate(pdf.pages):
            print(f"  Processing page {i+1}")
            tables = page.extract_tables()
            for table in tables:
                # Filter out empty rows or headers if needed
                # For now, just collect everything to inspect structure
                for row in table:
                    cleaned_row = [str(cell).strip() if cell else '' for cell in row]
                    all_rows.append(cleaned_row)
    
    return all_rows

rows = extract_table_from_pdf(pdf_path)

print(f"Extracted {len(rows)} rows.")
print("First 5 rows:")
for r in rows[:5]:
    print(r)

print("\nLast 5 rows:")
for r in rows[-5:]:
    print(r)
