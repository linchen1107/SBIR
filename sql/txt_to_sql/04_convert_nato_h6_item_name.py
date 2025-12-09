#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段5: NATO H6 Item Name (NATO H6物品名稱) 資料轉換
對應檔案: NATO-H6.TXT
輸出表格: nato_h6_item_name
"""

import os
import sys
import re
from pathlib import Path
import logging

# 設定日誌
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class NATOH6Converter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_nato_h6_data(self):
        """解析NATO H6資料 (從NATO-H6.TXT)"""
        logging.info("🔍 階段5: 解析NATO H6 Item Name 資料...")
        
        h6_file = self.raw_data_path / 'nato_h6_item_name' / 'NATO-H6.TXT'
        if not h6_file.exists():
            logging.error(f"❌ NATO H6檔案不存在: {h6_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段5: NATO H6 Item Name 資料匯入",
            "-- 對應檔案: NATO-H6.TXT", 
            "-- 目標表格: nato_h6_item_name",
            "-- 依賴: 無",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM nato_h6_item_name;",
            ""
        ]
        
        count = 0
        batch_size = 1000
        
        try:
            with open(h6_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if line and line.startswith('@'):
                        # NATO H6格式解析
                        try:
                            # 移除@符號並解析
                            content = line[1:]
                            
                            # 提取H6代碼 (前5位)
                            h6_record_id = content[:5]
                            
                            # 使用正規表達式解析剩餘內容
                            # 範例: G0001         A41989020 0017meter,switchboard...
                            pattern = r'^(\w+)\s+(\w+)\s+(\d+)([a-zA-Z].*)$'
                            match = re.match(pattern, content)
                            
                            if match:
                                h6_code = match.group(1)
                                country_code = match.group(2)[:3]
                                length_info = match.group(3)
                                item_content = match.group(4)
                                
                                # 提取物品名稱
                                item_name = self.extract_item_name(item_content)
                                
                                if item_name and len(item_name) > 2:
                                    # 清理資料
                                    safe_name = item_name.replace("'", "''")[:255]
                                    
                                    sql_parts.append(f"INSERT INTO nato_h6_item_name (h6_record_id, nato_item_name, country_code, status_code) VALUES ('{h6_record_id}', '{safe_name}', '{country_code}', 'A');")
                                    count += 1
                                    
                                    if count % batch_size == 0:
                                        logging.info(f"⏳ 處理進度: {count:,} 筆")
                                        
                        except Exception as e:
                            logging.debug(f"跳過行 {line_num}: {str(e)}")
                            continue
                            
        except Exception as e:
            logging.error(f"❌ 解析NATO H6檔案時發生錯誤: {e}")
            return False
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count:,} 筆NATO H6資料"
        ])
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '04_import_nato_h6_item_name.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ NATO H6轉換完成: {count:,} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False
    
    def extract_item_name(self, content):
        """從內容中提取物品名稱"""
        # 尋找第一個英文字母開始的部分
        for i, char in enumerate(content):
            if char.isalpha():
                name_part = content[i:]
                
                # 移除常見的結尾標記
                for delimiter in [',', ';', '0004', 'see ', 'SEE ']:
                    if delimiter in name_part:
                        name_part = name_part.split(delimiter)[0].strip()
                        break
                
                # 清理並返回
                return name_part.strip()[:50]
        
        return ""

def main():
    """主程式"""
    print("=" * 60)
    print("階段5: NATO H6 Item Name 資料轉換")
    print("=" * 60)
    
    converter = NATOH6Converter()
    success = converter.parse_nato_h6_data()
    
    if success:
        print("\n🎉 NATO H6資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/04_import_nato_h6_item_name.sql")
        print("📋 下一步: 執行 '05_convert_inc.py'")
    else:
        print("\n❌ NATO H6資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main() 
