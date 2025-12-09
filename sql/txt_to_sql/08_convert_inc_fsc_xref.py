#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段9: INC-FSC交叉參照 資料轉換
對應檔案: Tabl099.TXT
輸出表格: inc_fsc_xref
依賴: inc, fsc
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

class IncFscXrefConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_inc_fsc_xref_data(self):
        """解析INC-FSC交叉參照資料 (從raw_data/inc_fsc_xref/Tabl099.TXT)"""
        logging.info("🔍 階段9: 解析INC-FSC交叉參照資料...")
        
        source_file = self.raw_data_path / 'inc_fsc_xref' / 'Tabl099.TXT'
        if not source_file.exists():
            logging.error(f"❌ 來源檔案不存在: {source_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段9: INC-FSC交叉參照資料匯入",
            "-- 對應檔案: raw_data/inc_fsc_xref/Tabl099.TXT",
            "-- 目標表格: inc_fsc_xref", 
            "-- 依賴: inc (外鍵: inc_code), fsc (外鍵: fsc_code)",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM inc_fsc_xref;",
            ""
        ]
        
        count = 0
        batch_size = 1000
        
        try:
            with open(source_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if '|' in line:
                        parts = line.split('|')
                        if len(parts) >= 3:
                            # 解析格式: NM_CD_2303|FSG_3994|FSC_WI_FSG_3996|...
                            inc_code = parts[0].strip()
                            fsg_code = parts[1].strip()
                            fsc_within_fsg = parts[2].strip()
                            
                            # 建立完整FSC代碼
                            fsc_code = fsg_code + fsc_within_fsg
                            
                            if inc_code and fsc_code and len(fsc_code) == 4:
                                sql_parts.append(f"INSERT INTO inc_fsc_xref (inc_code, fsc_code) VALUES ('{inc_code}', '{fsc_code}');")
                                count += 1
                                
                                if count % batch_size == 0:
                                    logging.info(f"⏳ 處理進度: {count:,} 筆")
                    
                    # 定期記錄進度
                    if line_num % 10000 == 0:
                        logging.info(f"已掃描 {line_num} 行...")
                        
        except Exception as e:
            logging.error(f"❌ 解析INC-FSC交叉參照檔案時發生錯誤: {e}")
            return False
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count:,} 筆INC-FSC交叉參照資料"
        ])
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '08_import_inc_fsc_xref.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ INC-FSC交叉參照轉換完成: {count:,} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段9: INC-FSC交叉參照資料轉換")
    print("=" * 60)
    
    converter = IncFscXrefConverter()
    success = converter.parse_inc_fsc_xref_data()
    
    if success:
        print("\n🎉 INC-FSC交叉參照資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/08_import_inc_fsc_xref.sql")
        print("📋 下一步: 執行 '09_convert_nato_h6_inc_xref.py'")
    else:
        print("\n❌ INC-FSC交叉參照資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main()


