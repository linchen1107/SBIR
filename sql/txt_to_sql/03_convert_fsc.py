#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段4: FSC (聯邦供應分類) 資料轉換
對應檔案: Tabl076.TXT
輸出表格: fsc
依賴: fsg
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

class FSCConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)

    def write_fsc_jsonl(self, fsc_data_list):
        """
        輸出 FSC 資料為 JSONL 格式
        用途: 供大模型上下文使用
        注意: 僅包含 FSC 自己的欄位，不包含 fsg_code 或 fsg_title
        """
        jsonl_file = self.output_dir / 'fsc.jsonl'

        try:
            with open(jsonl_file, 'w', encoding='utf-8') as f:
                for item in fsc_data_list:
                    record = {
                        "fsc_code": item["fsc_code"],
                        "fsc_title": item["fsc_title"]
                    }
                    # 僅當欄位非空時才加入 (省略空值)
                    if item.get("fsc_includes"):
                        record["fsc_includes"] = item["fsc_includes"]
                    if item.get("fsc_excludes"):
                        record["fsc_excludes"] = item["fsc_excludes"]
                    if item.get("fsc_notes"):
                        record["fsc_notes"] = item["fsc_notes"]

                    f.write(json.dumps(record, ensure_ascii=False) + '\n')

            logging.info(f"✅ JSONL輸出完成: {len(fsc_data_list)} 筆資料 → {jsonl_file}")
            return True
        except Exception as e:
            logging.error(f"❌ JSONL寫入失敗: {e}")
            return False

    def parse_fsc_data(self):
        """解析FSC資料 (從Tabl076.TXT)"""
        logging.info("🔍 階段4: 解析FSC (聯邦供應分類) 資料...")
        
        fsc_file = self.raw_data_path / 'fsc' / 'Tabl076.TXT'
        if not fsc_file.exists():
            logging.error(f"❌ FSC檔案不存在: {fsc_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段4: FSC (聯邦供應分類) 資料匯入",
            "-- 對應檔案: Tabl076.TXT",
            "-- 目標表格: fsc",
            "-- 依賴: fsg (外鍵: fsg_code)",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM fsc;",
            ""
        ]

        fsc_data_list = []  # 用於收集 JSONL 輸出資料
        count = 0
        
        try:
            with open(fsc_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if not line:
                        continue

                    parts = [p.strip() for p in line.split('|')]
                    
                    if len(parts) < 7:
                        logging.warning(f"⚠️ 第 {line_num} 行格式不符，欄位數不足: {line}")
                        continue
                        
                    # 根據DLA文件解析欄位
                    fsg_code = parts[0]
                    fsc_within_fsg = parts[1]
                    # status = parts[2] # 目前未使用
                    fsc_includes_raw = parts[3]  # 原始值（用於 JSONL）
                    fsc_excludes_raw = parts[4]
                    fsc_notes_raw = parts[5]
                    fsc_title_raw = parts[6]

                    # SQL 用的轉義版本
                    fsc_includes = fsc_includes_raw.replace("'", "''")
                    fsc_excludes = fsc_excludes_raw.replace("'", "''")
                    fsc_notes = fsc_notes_raw.replace("'", "''")
                    fsc_title = fsc_title_raw.replace("'", "''")

                    # 建立完整的FSC代碼
                    fsc_code = fsg_code + fsc_within_fsg

                    if fsg_code and fsc_within_fsg and len(fsc_code) == 4:
                        # 準備SQL INSERT語句
                        sql = (
                            f"INSERT INTO fsc (fsc_code, fsg_code, fsc_title, fsc_includes, fsc_excludes, fsc_notes) "
                            f"VALUES ('{fsc_code}', '{fsg_code}', '{fsc_title}', "
                            f"NULLIF('{fsc_includes}', ''), "
                            f"NULLIF('{fsc_excludes}', ''), "
                            f"NULLIF('{fsc_notes}', ''));"
                        )
                        sql_parts.append(sql)

                        # 收集 JSONL 資料（使用原始值，不包含 fsg_code）
                        fsc_data_list.append({
                            "fsc_code": fsc_code,
                            "fsc_title": fsc_title_raw,
                            "fsc_includes": fsc_includes_raw,
                            "fsc_excludes": fsc_excludes_raw,
                            "fsc_notes": fsc_notes_raw
                        })

                        count += 1

                        if count % 100 == 0:
                            logging.info(f"⏳ 處理進度: {count} 筆FSC資料")

        except Exception as e:
            logging.error(f"❌ 解析FSC檔案時發生錯誤: {e}")
            return False
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count} 筆FSC資料"
        ])

        # 寫入 SQL 檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '03_import_fsc.sql'

        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ SQL轉換完成: {count} 筆資料 → {output_file}")
        except Exception as e:
            logging.error(f"❌ SQL寫入失敗: {e}")
            return False

        # 寫入 JSONL 檔案 (供大模型上下文使用)
        if not self.write_fsc_jsonl(fsc_data_list):
            return False

        return True

def main():
    """主程式"""
    print("=" * 60)
    print("階段4: FSC (聯邦供應分類) 資料轉換")
    print("=" * 60)
    
    converter = FSCConverter()
    success = converter.parse_fsc_data()
    
    if success:
        print("\n🎉 FSC資料轉換成功完成！")
        print("📂 輸出檔案:")
        print("   - SQL: sql/data_import/03_import_fsc.sql")
        print("   - JSONL: sql/data_import/fsc.jsonl (供大模型上下文使用)")
        print("📋 下一步: 執行 '04_convert_nato_h6_item_name.py'")
    else:
        print("\n❌ FSC資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main() 
