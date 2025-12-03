import pdfplumber

pdf_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\原始資料\C20_E-II73643-4WU_00-EN_OCR.pdf'

def inspect_text(path):
    print(f"Inspecting text from: {path}")
    with pdfplumber.open(path) as pdf:
        page = pdf.pages[0]
        text = page.extract_text()
        print("--- Page 1 Text ---")
        print(text)
        print("-------------------")
        
        # Also try table extraction with text strategy
        print("\nAttempting table extraction with 'text' strategy...")
        tables = page.extract_tables(table_settings={
            "vertical_strategy": "text", 
            "horizontal_strategy": "text"
        })
        for i, table in enumerate(tables):
            print(f"Table {i}:")
            for row in table[:3]: # Print first 3 rows
                print(row)

inspect_text(pdf_path)
