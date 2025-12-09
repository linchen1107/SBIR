#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段13: MRC回應表對應資料轉換
對應檔案: 根據MRC與Reply Table的對應關係
輸出表格: mrc_reply_table_xref
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

class MRCReplyTableXrefConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_mrc_reply_table_xref_data(self):
        """解析MRC回應表對應資料 (從raw_data/mrc_reply_table_xref/)"""
        logging.info("🔍 階段13: 解析MRC回應表對應資料...")
        
        # 檢查對應目錄下的檔案
        mrc_reply_dir = self.raw_data_path / 'mrc_reply_table_xref'
        if not mrc_reply_dir.exists():
            logging.error(f"❌ MRC回應表對應目錄不存在: {mrc_reply_dir}")
            return False
            
        # 找尋可能的檔案
        possible_files = list(mrc_reply_dir.glob('*.TXT')) + list(mrc_reply_dir.glob('*.txt'))
        if not possible_files:
            logging.warning(f"⚠️  未找到MRC回應表對應檔案，將生成空的SQL檔案")
            return self._create_empty_sql()
            
        mrc_reply_file = possible_files[0]
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段13: MRC回應表對應資料匯入",
            f"-- 對應檔案: raw_data/mrc_reply_table_xref/{mrc_reply_file.name}",
            "-- 目標表格: mrc_reply_table_xref",
            "-- 依賴: mrc, reply_table",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM mrc_reply_table_xref;",
            "",
            "-- 重設序列",
            "-- ALTER SEQUENCE mrc_reply_table_xref_id_seq RESTART WITH 1;",
            ""
        ]
        
        count = 0
        batch_size = 1000
        
        try:
            with open(mrc_reply_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if '|' in line:
                        parts = line.split('|')
                        if len(parts) >= 2:
                            # 格式: MRC_CODE|REPLY_TABLE_NUMBER|其他欄位
                            mrc_code = parts[0].strip()
                            reply_table_number = parts[1].strip()
                            
                            if mrc_code and reply_table_number:
                                safe_mrc = mrc_code.replace("'", "''")
                                safe_reply_table = reply_table_number.replace("'", "''")
                                
                                sql_parts.append(
                                    f"INSERT INTO mrc_reply_table_xref (mrc_code, reply_table_number) VALUES ('{safe_mrc}', '{safe_reply_table}');"
                                )
                                count += 1
                                
                                if count % batch_size == 0:
                                    logging.info(f"已處理 {count} 筆MRC回應表對應資料...")
                    
                    # 定期記錄進度
                    if line_num % 10000 == 0:
                        logging.info(f"已掃描 {line_num} 行...")
                        
        except Exception as e:
            logging.error(f"❌ 解析MRC回應表對應檔案時發生錯誤: {e}")
            return False
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count} 筆MRC回應表對應資料"
        ])
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '12_import_mrc_reply_table_xref.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ MRC回應表對應轉換完成: {count} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False
            
    def _create_empty_sql(self):
        """創建空的SQL檔案"""
        sql_parts = [
            "-- =================================================================",
            "-- 階段13: MRC回應表對應資料匯入",
            "-- 對應檔案: raw_data/mrc_reply_table_xref/ (未找到檔案)",
            "-- 目標表格: mrc_reply_table_xref",
            "-- 依賴: mrc, reply_table",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM mrc_reply_table_xref;",
            "",
            "-- 注意: 未找到對應檔案，表格將保持空白",
            "",
            "COMMIT;",
            "",
            "-- 統計: 成功匯入 0 筆MRC回應表對應資料"
        ]
        
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '12_import_mrc_reply_table_xref.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ 建立空的MRC回應表對應SQL檔案 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段13: MRC回應表對應資料轉換")
    print("=" * 60)
    
    converter = MRCReplyTableXrefConverter()
    success = converter.parse_mrc_reply_table_xref_data()
    
    if success:
        print("\n🎉 MRC回應表對應資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/12_import_mrc_reply_table_xref.sql")
        print("📋 下一步: 執行 '13_convert_fiig_inc_xref.py'")
    else:
        print("\n❌ MRC回應表對應資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main()
