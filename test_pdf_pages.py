import pdfplumber

pdf_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\原始資料\C20_E-II73643-4WU_00-EN_OCR.pdf'

def inspect_pages(path):
    with pdfplumber.open(path) as pdf:
        for i in range(1, 4): # Check pages 2, 3, 4 (index 1, 2, 3)
            if i >= len(pdf.pages): break
            
            print(f"\n--- Page {i+1} Text ---")
            page = pdf.pages[i]
            text = page.extract_text()
            print(text[:500]) # Print first 500 chars
            
            print(f"\n--- Page {i+1} Tables (Text Strategy) ---")
            tables = page.extract_tables(table_settings={
                "vertical_strategy": "text", 
                "horizontal_strategy": "text"
            })
            for j, table in enumerate(tables):
                print(f"Table {j} (First 3 rows):")
                for row in table[:3]:
                    print(row)

inspect_pages(pdf_path)
