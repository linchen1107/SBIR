#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段14: FIIG-INC對應資料轉換
對應檔案: 根據FIIG與INC的對應關係
輸出表格: fiig_inc_xref
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

class FIIGINCXrefConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_fiig_inc_xref_data(self):
        """解析FIIG-INC對應資料 (從raw_data/fiig_inc_xref/)"""
        logging.info("🔍 階段14: 解析FIIG-INC對應資料...")
        
        # 檢查對應目錄下的檔案
        fiig_inc_dir = self.raw_data_path / 'fiig_inc_xref'
        if not fiig_inc_dir.exists():
            logging.error(f"❌ FIIG-INC對應目錄不存在: {fiig_inc_dir}")
            return False
            
        # 找尋可能的檔案
        possible_files = list(fiig_inc_dir.glob('*.TXT')) + list(fiig_inc_dir.glob('*.txt'))
        if not possible_files:
            logging.warning(f"⚠️  未找到FIIG-INC對應檔案，將生成空的SQL檔案")
            return self._create_empty_sql()
            
        fiig_inc_file = possible_files[0]
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段14: FIIG-INC對應資料匯入",
            f"-- 對應檔案: raw_data/fiig_inc_xref/{fiig_inc_file.name}",
            "-- 目標表格: fiig_inc_xref",
            "-- 依賴: fiig, inc",
            "-- 注意: 使用臨時表格和JOIN來避免外鍵約束錯誤",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM fiig_inc_xref;",
            "",
            "-- 創建臨時表格來儲存原始對應資料",
            "CREATE TEMPORARY TABLE temp_fiig_inc_xref (",
            "    fiig_code VARCHAR(10),",
            "    inc_code VARCHAR(15)",
            ");",
            ""
        ]
        
        count = 0
        batch_size = 1000
        temp_inserts = []
        
        try:
            with open(fiig_inc_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if '|' in line:
                        parts = line.split('|')
                        if len(parts) >= 2:
                            # 格式: FIIG_CODE|INC_CODE|其他欄位
                            fiig_code = parts[0].strip()
                            inc_code = parts[1].strip()
                            
                            if fiig_code and inc_code:
                                safe_fiig = fiig_code.replace("'", "''")
                                safe_inc = inc_code.replace("'", "''")
                                
                                temp_inserts.append(
                                    f"INSERT INTO temp_fiig_inc_xref (fiig_code, inc_code) VALUES ('{safe_fiig}', '{safe_inc}');"
                                )
                                count += 1
                                
                                if count % batch_size == 0:
                                    logging.info(f"已處理 {count} 筆FIIG-INC對應資料...")
                    
                    # 定期記錄進度
                    if line_num % 10000 == 0:
                        logging.info(f"已掃描 {line_num} 行...")
                        
        except Exception as e:
            logging.error(f"❌ 解析FIIG-INC對應檔案時發生錯誤: {e}")
            return False
        
        # 添加臨時表格的插入語句
        sql_parts.extend(temp_inserts)
        
        # 使用JOIN來只匯入有效的資料
        sql_parts.extend([
            "",
            "-- 從臨時表格匯入到正式表格，只保留有效的 FIIG 和 INC 代碼",
            "INSERT INTO fiig_inc_xref (fiig_code, inc_code, relationship_type)",
            "SELECT t.fiig_code, t.inc_code, 'APPLIES_TO'",
            "FROM temp_fiig_inc_xref t",
            "INNER JOIN fiig f ON t.fiig_code = f.fiig_code",
            "INNER JOIN inc i ON t.inc_code = i.inc_code;",
            "",
            "-- 取得統計資訊",
            "-- 原始資料筆數:",
            f"-- {count}",
            "-- 有效匯入筆數: (將在執行時計算)",
            "",
            "COMMIT;",
            "",
            f"-- 統計: 處理 {count} 筆原始FIIG-INC對應資料"
        ])
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '13_import_fiig_inc_xref.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ FIIG-INC對應轉換完成: {count} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False
            
    def _create_empty_sql(self):
        """創建空的SQL檔案"""
        sql_parts = [
            "-- =================================================================",
            "-- 階段14: FIIG-INC對應資料匯入",
            "-- 對應檔案: raw_data/fiig_inc_xref/ (未找到檔案)",
            "-- 目標表格: fiig_inc_xref",
            "-- 依賴: fiig, inc",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM fiig_inc_xref;",
            "",
            "-- 注意: 未找到對應檔案，表格將保持空白",
            "",
            "COMMIT;",
            "",
            "-- 統計: 成功匯入 0 筆FIIG-INC對應資料"
        ]
        
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '13_import_fiig_inc_xref.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ 建立空的FIIG-INC對應SQL檔案 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段14: FIIG-INC對應資料轉換")
    print("=" * 60)
    
    converter = FIIGINCXrefConverter()
    success = converter.parse_fiig_inc_xref_data()
    
    if success:
        print("\n🎉 FIIG-INC對應資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/13_import_fiig_inc_xref.sql")
        print("📋 下一步: 執行 '14_convert_fiig_inc_mrc_xref.py'")
    else:
        print("\n❌ FIIG-INC對應資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main()
