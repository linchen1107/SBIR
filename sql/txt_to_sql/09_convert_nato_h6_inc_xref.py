#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段10: NATO H6-INC Cross Reference (NATO H6與INC對應關係) 資料轉換
對應檔案: NATO-H6.TXT (INC代碼在管道符號後)
輸出表格: nato_h6_inc_xref
依賴表格: nato_h6_item_name, inc
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

class NATOH6INCXrefConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_nato_h6_inc_xref(self):
        """解析NATO H6與INC對應關係 (從NATO-H6.TXT管道符號後的INC代碼)"""
        logging.info("🔍 階段10: 解析NATO H6-INC Cross Reference 資料...")
        
        h6_file = self.raw_data_path / 'nato_h6_inc_xref' / 'NATO-H6.TXT'
        if not h6_file.exists():
            logging.error(f"❌ NATO H6檔案不存在: {h6_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段10: NATO H6-INC Cross Reference 資料匯入",
            "-- 對應檔案: NATO-H6.TXT (管道符號後的INC代碼列表)", 
            "-- 目標表格: nato_h6_inc_xref",
            "-- 依賴表格: nato_h6_item_name, inc",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 建立臨時表格來處理對應關係",
            "CREATE TEMP TABLE temp_h6_inc_mapping (",
            "    h6_record_id VARCHAR(20),",
            "    inc_code VARCHAR(15)",
            ");",
            "",
            "-- 清除現有資料",
            "DELETE FROM nato_h6_inc_xref;",
            ""
        ]
        
        count = 0
        batch_size = 1000
        processed_pairs = set()  # 避免重複
        
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
                            
                            # 尋找管道符號，INC代碼在最後部分
                            if '|' in content:
                                # 分割並取得最後部分的INC代碼
                                parts = content.split('|')
                                if len(parts) > 1:
                                    # 最後一部分通常包含INC代碼列表
                                    inc_part = parts[-1].strip()
                                    if inc_part:  # 確保不是空字串
                                        # 如果有多個INC代碼，用|分割
                                        inc_codes = [code.strip() for code in inc_part.split('|') if code.strip()]
                                        
                                        for inc_code in inc_codes:
                                            # 驗證INC代碼格式 (通常是4-6位數字)
                                            if self.is_valid_inc_code(inc_code):
                                                # 避免重複記錄
                                                pair_key = f"{h6_record_id}:{inc_code}"
                                                if pair_key not in processed_pairs:
                                                    processed_pairs.add(pair_key)
                                                    
                                                    safe_h6 = h6_record_id.replace("'", "''")
                                                    safe_inc = inc_code.replace("'", "''")
                                                    
                                                    sql_parts.append(f"INSERT INTO temp_h6_inc_mapping (h6_record_id, inc_code) VALUES ('{safe_h6}', '{safe_inc}');")
                                                    count += 1
                                                    
                                                    if count % batch_size == 0:
                                                        logging.info(f"⏳ 處理進度: {count:,} 筆")
                                        
                        except Exception as e:
                            logging.debug(f"跳過行 {line_num}: {str(e)}")
                            continue
                    
                    # 定期記錄進度
                    if line_num % 10000 == 0:
                        logging.info(f"已掃描 {line_num:,} 行...")
                            
        except Exception as e:
            logging.error(f"❌ 解析NATO H6-INC對應檔案時發生錯誤: {e}")
            return False
        
        # 現在將有效的對應關係插入到正式表格
        sql_parts.extend([
            "",
            "-- 只插入兩個表格都存在的記錄，避免外鍵約束錯誤",
            "INSERT INTO nato_h6_inc_xref (h6_record_id, inc_code)",
            "SELECT DISTINCT t.h6_record_id, t.inc_code",
            "FROM temp_h6_inc_mapping t",
            "WHERE EXISTS (SELECT 1 FROM nato_h6_item_name h WHERE h.h6_record_id = t.h6_record_id)",
            "  AND EXISTS (SELECT 1 FROM inc i WHERE i.inc_code = t.inc_code);",
            "",
            "-- 統計實際匯入的記錄數",
            "SELECT COUNT(*) as actual_imported FROM nato_h6_inc_xref;",
            "",
            "COMMIT;",
            "",
            f"-- 統計: 處理了 {count:,} 筆潛在的NATO H6-INC對應關係"
        ])
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '09_import_nato_h6_inc_xref.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ NATO H6-INC對應關係轉換完成: 處理 {count:,} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False
    
    def is_valid_inc_code(self, code):
        """驗證INC代碼格式"""
        # INC代碼通常是4-6位數字
        if not code:
            return False
        
        # 移除前後空白
        code = code.strip()
        
        # 檢查是否為數字且長度合適
        if re.match(r'^\d{4,6}$', code):
            return True
        
        # 也接受可能的字母數字組合
        if re.match(r'^[A-Z0-9]{4,8}$', code):
            return True
        
        return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段10: NATO H6-INC Cross Reference 資料轉換")
    print("=" * 60)
    
    converter = NATOH6INCXrefConverter()
    success = converter.parse_nato_h6_inc_xref()
    
    if success:
        print("\n🎉 NATO H6-INC對應關係轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/09_import_nato_h6_inc_xref.sql")
        print("📋 下一步: 執行 '10_convert_colloquial_inc_xref.py'")
    else:
        print("\n❌ NATO H6-INC對應關係轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main()