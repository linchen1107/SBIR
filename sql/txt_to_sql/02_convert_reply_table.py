#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段3: Reply Table (回應選項表) 資料轉換
對應檔案: Tabl128.TXT
輸出表格: reply_table
"""

import os
import sys
from pathlib import Path
import logging

# 設定日誌
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class ReplyTableConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_reply_table_data(self):
        """解析Reply Table資料 (從Tabl128.TXT)"""
        logging.info("🔍 階段3: 解析Reply Table (回應選項表) 資料...")
        
        reply_file = self.raw_data_path / 'reply_table' / 'Tabl128.TXT'
        if not reply_file.exists():
            logging.error(f"❌ Reply Table檔案不存在: {reply_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段3: Reply Table (回應選項表) 資料匯入",
            "-- 對應檔案: Tabl128.TXT", 
            "-- 目標表格: reply_table",
            "-- 依賴: 無",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM reply_table;",
            ""
        ]
        
        count = 0
        batch_size = 1000
        current_batch = 0
        
        try:
            with open(reply_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if line and '|' in line:
                        parts = line.split('|')
                        if len(parts) >= 3:
                            # 解析格式: RPLY_TBL_MRD_8254|CDD_RPLY_3465|DCOD_RPLY_ST_3864|...
                            reply_table_number = parts[0].strip()
                            reply_code = parts[1].strip()
                            reply_description = parts[2].strip()
                            
                            if reply_table_number and reply_code:
                                # 清理資料
                                safe_desc = reply_description.replace("'", "''")[:500]
                                
                                sql_parts.append(f"INSERT INTO reply_table (reply_table_number, reply_code, reply_description) VALUES ('{reply_table_number}', '{reply_code}', '{safe_desc}');")
                                count += 1
                                
                                # 分批處理大檔案
                                if count % batch_size == 0:
                                    current_batch += 1
                                    logging.info(f"⏳ 處理進度: {count:,} 筆 (第 {current_batch} 批次)")
                                    
        except Exception as e:
            logging.error(f"❌ 解析Reply Table檔案時發生錯誤: {e}")
            return False
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count:,} 筆Reply Table資料"
        ])
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '02_import_reply_table.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ Reply Table轉換完成: {count:,} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段3: Reply Table (回應選項表) 資料轉換")
    print("=" * 60)
    
    converter = ReplyTableConverter()
    success = converter.parse_reply_table_data()
    
    if success:
        print("\n🎉 Reply Table資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/02_import_reply_table.sql")
        print("📋 下一步: 執行 '03_convert_fsc.py'")
    else:
        print("\n❌ Reply Table資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main() 
