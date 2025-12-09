#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段11: 俗稱INC對應資料轉換
對應檔案: Tabl091.TXT
輸出表格: colloquial_inc_xref
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

class ColloquialINCXrefConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_colloquial_inc_xref_data(self):
        """解析俗稱INC對應資料 (從raw_data/colloquial_inc_xref/Tabl091.TXT)"""
        logging.info("🔍 階段11: 解析俗稱INC對應資料...")
        
        colloquial_file = self.raw_data_path / 'colloquial_inc_xref' / 'Tabl091.TXT'
        if not colloquial_file.exists():
            logging.error(f"❌ 俗稱INC對應檔案不存在: {colloquial_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段11: 俗稱INC對應資料匯入",
            "-- 對應檔案: raw_data/colloquial_inc_xref/Tabl091.TXT",
            "-- 目標表格: colloquial_inc_xref",
            "-- 依賴: inc",
            "-- 格式: 俗稱代碼|正式INC代碼|建立日期|生效日期",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 建立臨時表格來處理俗稱對應關係",
            "CREATE TEMP TABLE temp_colloquial_mapping (",
            "    colloquial_code VARCHAR(10),",
            "    primary_inc_code VARCHAR(15),",
            "    establishment_date INTEGER,",
            "    effective_date INTEGER",
            ");",
            "",
            "-- 清除現有資料",
            "DELETE FROM colloquial_inc_xref;",
            ""
        ]
        
        count = 0
        batch_size = 1000
        
        try:
            with open(colloquial_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if '|' in line:
                        parts = line.split('|')
                        if len(parts) >= 2:
                            # 格式: COLLOQUIAL_CODE|PRIMARY_INC_CODE|DATE1|DATE2|
                            colloquial_code = parts[0].strip()  # G0001, G0002等俗稱代碼
                            primary_inc_code = parts[1].strip()  # 16449, 38131等正式INC代碼
                            establishment_date = parts[2].strip() if len(parts) > 2 else ''
                            effective_date = parts[3].strip() if len(parts) > 3 else ''
                            
                            if colloquial_code and primary_inc_code:
                                safe_colloquial = colloquial_code.replace("'", "''")
                                safe_primary = primary_inc_code.replace("'", "''")
                                
                                # 轉換日期格式（如果有的話）
                                est_date_value = "NULL"
                                eff_date_value = "NULL"
                                
                                if establishment_date and establishment_date.isdigit():
                                    est_date_value = establishment_date
                                if effective_date and effective_date.isdigit():
                                    eff_date_value = effective_date
                                
                                # 插入到臨時表格
                                sql_parts.append(
                                    f"INSERT INTO temp_colloquial_mapping (colloquial_code, primary_inc_code, establishment_date, effective_date) "
                                    f"VALUES ('{safe_colloquial}', '{safe_primary}', {est_date_value}, {eff_date_value});"
                                )
                                count += 1
                                
                                if count % batch_size == 0:
                                    logging.info(f"⏳ 處理進度: {count:,} 筆俗稱對應")
                    
                    # 定期記錄進度
                    if line_num % 10000 == 0:
                        logging.info(f"已掃描 {line_num:,} 行...")
                        
        except Exception as e:
            logging.error(f"❌ 解析俗稱INC對應檔案時發生錯誤: {e}")
            return False
        
        # 現在建立實際的對應關係
        # 由於俗稱代碼不是有效的INC代碼，我們需要修改策略：
        # 將primary_inc_code作為主INC，將俗稱代碼暫時視為關聯的INC
        # 但這需要創建俗稱代碼的記錄在INC表中，或者修改資料庫結構
        
        sql_parts.extend([
            "",
            "-- 方案1: 將俗稱代碼作為非官方INC插入到inc表中",
            "-- 然後建立俗稱INC到正式INC的對應關係",
            "",
            "-- 首先將俗稱代碼插入到inc表中（如果不存在的話）",
            "INSERT INTO inc (inc_code, short_name, is_official, status_code)",
            "SELECT DISTINCT t.colloquial_code, ", 
            "       'COLLOQUIAL: ' || t.colloquial_code,",
            "       FALSE,",
            "       'A'",
            "FROM temp_colloquial_mapping t",
            "WHERE NOT EXISTS (SELECT 1 FROM inc i WHERE i.inc_code = t.colloquial_code)",
            "  AND EXISTS (SELECT 1 FROM inc i WHERE i.inc_code = t.primary_inc_code);",
            "",
            "-- 然後建立俗稱INC到正式INC的對應關係",
            "INSERT INTO colloquial_inc_xref (colloquial_inc_code, primary_inc_code)",
            "SELECT DISTINCT t.colloquial_code, t.primary_inc_code", 
            "FROM temp_colloquial_mapping t",
            "WHERE EXISTS (SELECT 1 FROM inc i WHERE i.inc_code = t.colloquial_code)",
            "  AND EXISTS (SELECT 1 FROM inc i WHERE i.inc_code = t.primary_inc_code);",
            "",
            "-- 統計實際匯入的記錄數",
            "SELECT COUNT(*) as actual_imported FROM colloquial_inc_xref;",
            "",
            f"-- 臨時表格包含 {count:,} 筆俗稱到INC的對應關係",
            "",
            "COMMIT;",
            "",
            f"-- 統計: 處理了 {count:,} 筆俗稱INC對應資料"
        ])
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '10_import_colloquial_inc_xref.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ 俗稱INC對應轉換完成: 處理 {count:,} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段11: 俗稱INC對應資料轉換")
    print("=" * 60)
    
    converter = ColloquialINCXrefConverter()
    success = converter.parse_colloquial_inc_xref_data()
    
    if success:
        print("\n🎉 俗稱INC對應資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/10_import_colloquial_inc_xref.sql")
        print("📋 說明：俗稱代碼將作為非官方INC插入，並建立到正式INC的對應關係")
        print("📋 下一步: 執行 '11_convert_fiig.py'")
    else:
        print("\n❌ 俗稱INC對應資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main()
