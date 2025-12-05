file_path = r'c:\github\SBIR\Database\docs\20-EMU3000系統\02-EMU3000_資料預覽.md'

with open(file_path, 'r', encoding='utf-8') as f:
    for i in range(20):
        print(f.readline().strip())
