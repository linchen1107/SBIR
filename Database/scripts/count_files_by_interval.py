import os

DATA_ROOT = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單'

def count_files():
    intervals = ['5年維護', '6年維護', '8年維護', '16年維護', '20年維護']
    
    print(f"Scanning {DATA_ROOT}...\n")
    
    total_excel = 0
    
    for item in os.listdir(DATA_ROOT):
        # Match interval folders (some have extra text like 8年維護...)
        matched_interval = None
        for interval in intervals:
            if item.startswith(interval):
                matched_interval = interval
                break
        
        if matched_interval:
            dir_path = os.path.join(DATA_ROOT, item)
            if os.path.isdir(dir_path):
                count = 0
                for root, dirs, files in os.walk(dir_path):
                    # Exclude '原始資料'
                    path_parts = root.split(os.sep)
                    if '原始資料' in path_parts:
                        continue
                        
                    for file in files:
                        if file.endswith('.xlsx') and not file.startswith('~$'):
                            count += 1
                
                print(f"[{matched_interval}] ({item}): {count} Excel files")
                total_excel += count
        else:
             if os.path.isdir(os.path.join(DATA_ROOT, item)):
                 print(f"[OTHER] {item}")

    print(f"\nTotal Excel files found: {total_excel}")

if __name__ == '__main__':
    count_files()
