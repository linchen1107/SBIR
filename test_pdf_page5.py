import pdfplumber

pdf_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\原始資料\C20_E-II73643-4WU_00-EN_OCR.pdf'

def extract_page_5(path):
    with pdfplumber.open(path) as pdf:
        page = pdf.pages[4] # Page 5 is index 4
        
        print("--- Extracting Table (Text Strategy) ---")
        tables = page.extract_tables(table_settings={
            "vertical_strategy": "text", 
            "horizontal_strategy": "text",
            "snap_tolerance": 3,
        })
        
        for i, table in enumerate(tables):
            print(f"Table {i}:")
            for row in table:
                cleaned = [str(c).strip().replace('\n', ' ') if c else '' for c in row]
                print(cleaned)

extract_page_5(pdf_path)
