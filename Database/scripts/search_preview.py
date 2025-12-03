file_path = r'c:\github\SBIR\Database\docs\20-EMU3000系統\02-EMU3000_資料預覽.md'
search_term = "清潔塊單元C20、C21大修料件清單--60個月.xlsx"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()
    
if search_term in content:
    print("Found file in preview.")
    # Find the section
    start_idx = content.find(search_term)
    end_idx = content.find("## File:", start_idx + 1)
    if end_idx == -1:
        end_idx = len(content)
        
    print(content[start_idx:end_idx])
else:
    print("File NOT found in preview.")
