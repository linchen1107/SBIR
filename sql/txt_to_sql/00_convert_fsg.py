#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段1: FSG (聯邦供應組別) 資料轉換
對應檔案: Tabl316.TXT
輸出表格: fsg
"""

import os
import sys
from pathlib import Path
import logging
import json

# 設定日誌
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class FSGConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)

    def write_fsg_jsonl(self, fsg_data):
        """
        輸出 FSG 資料為 JSONL 格式
        用途: 供大模型上下文使用
        """
        jsonl_file = self.output_dir / 'fsg.jsonl'

        try:
            with open(jsonl_file, 'w', encoding='utf-8') as f:
                for fsg_code in sorted(fsg_data.keys()):
                    record = {
                        "fsg_code": fsg_code,
                        "fsg_title": fsg_data[fsg_code]
                    }
                    f.write(json.dumps(record, ensure_ascii=False) + '\n')

            logging.info(f"✅ JSONL輸出完成: {len(fsg_data)} 筆資料 → {jsonl_file}")
            return True
        except Exception as e:
            logging.error(f"❌ JSONL寫入失敗: {e}")
            return False

    def parse_fsg_data(self):
        """解析FSG資料 (從raw_data/fsg/Tabl316.TXT)"""
        logging.info("🔍 階段1: 解析FSG (聯邦供應組別) 資料...")
        
        fsg_file = self.raw_data_path / 'fsg' / 'Tabl316.TXT'
        if not fsg_file.exists():
            logging.error(f"❌ FSG檔案不存在: {fsg_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段1: FSG (聯邦供應組別) 資料匯入",
            "-- 對應檔案: raw_data/fsg/Tabl316.TXT", 
            "-- 目標表格: fsg",
            "-- 依賴: 無",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM fsg;",
            "",
            "-- 重設序列",
            "-- ALTER SEQUENCE fsg_id_seq RESTART WITH 1;",
            ""
        ]
        
        fsg_data = {}
        count = 0
        
        try:
            with open(fsg_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    if '|' in line:
                        parts = line.strip().split('|')
                        if len(parts) >= 4:
                            # 解析FSG格式: FSG代碼|A|備註|標題|日期|
                            # 例如: 10|A|Note-This group includes...|Weapons|1974091|
                            fsg_code = parts[0].strip()
                            fsg_title = parts[3].strip() if len(parts) > 3 and parts[3].strip() else f"Federal Supply Group {fsg_code}"
                            
                            if fsg_code and fsg_code.isdigit() and len(fsg_code) == 2:
                                if fsg_code not in fsg_data:
                                    fsg_data[fsg_code] = fsg_title[:200]  # 限制長度
                                    count += 1
                                    
        except Exception as e:
            logging.error(f"❌ 解析FSG檔案時發生錯誤: {e}")
            return False
        
        # 生成SQL插入語句
        for fsg_code in sorted(fsg_data.keys()):
            fsg_title = fsg_data[fsg_code]
            safe_title = fsg_title.replace("'", "''")
            sql_parts.append(f"INSERT INTO fsg (fsg_code, fsg_title) VALUES ('{fsg_code}', '{safe_title}');")
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count} 筆FSG資料"
        ])
        
        # 寫入 SQL 檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '00_import_fsg.sql'

        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ SQL轉換完成: {count} 筆資料 → {output_file}")
        except Exception as e:
            logging.error(f"❌ SQL寫入失敗: {e}")
            return False

        # 寫入 JSONL 檔案 (供大模型上下文使用)
        if not self.write_fsg_jsonl(fsg_data):
            return False

        return True

def main():
    """主程式"""
    print("=" * 60)
    print("階段1: FSG (聯邦供應組別) 資料轉換")
    print("=" * 60)
    
    converter = FSGConverter()
    success = converter.parse_fsg_data()
    
    if success:
        print("\n🎉 FSG資料轉換成功完成！")
        print("📂 輸出檔案:")
        print("   - SQL: sql/data_import/00_import_fsg.sql")
        print("   - JSONL: sql/data_import/fsg.jsonl (供大模型上下文使用)")
        print("📋 下一步: 執行 '01_convert_mrc_key_group.py'")
    else:
        print("\n❌ FSG資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main() 