import pdfplumber

pdf_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\原始資料\C20_E-II73643-4WU_00-EN_OCR.pdf'

def find_headers(path):
    print(f"Scanning {path}...")
    with pdfplumber.open(path) as pdf:
        for i, page in enumerate(pdf.pages):
            text = page.extract_text()
            if text:
                if "Item number" in text or "Part" in text and "Quantity" in text:
                    print(f"Found headers on Page {i+1}")
                    print(text[:300])
                    return i
    print("Headers not found.")
    return -1

page_idx = find_headers(pdf_path)
