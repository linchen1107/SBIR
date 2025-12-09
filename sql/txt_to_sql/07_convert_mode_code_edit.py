#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段8: Mode Code Edit (模式代碼編輯規則) 資料轉換
對應檔案: Tabl390.TXT
輸出表格: mode_code_edit
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

class ModeCodeEditConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_mode_code_edit_data(self):
        """解析Mode Code Edit資料 (從Tabl390.TXT)"""
        logging.info("🔍 階段8: 解析Mode Code Edit (模式代碼編輯規則) 資料...")
        
        mode_file = self.raw_data_path / 'mode_code_edit' / 'Tabl390.TXT'
        if not mode_file.exists():
            logging.error(f"❌ Mode Code Edit檔案不存在: {mode_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段8: Mode Code Edit (模式代碼編輯規則) 資料匯入",
            "-- 對應檔案: Tabl390.TXT", 
            "-- 目標表格: mode_code_edit",
            "-- 依賴: 無",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM mode_code_edit;",
            ""
        ]
        
        count = 0
        seen_codes = set()  # 用於追蹤已處理的mode_code
        
        try:
            with open(mode_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if line and '|' in line:
                        parts = line.split('|')
                        if len(parts) >= 3:
                            # 解析格式: MODE_CD|EDIT_RULE|DESCRIPTION|...
                            mode_code = parts[0].strip()
                            edit_rule = parts[1].strip()
                            description = parts[2].strip() if len(parts) > 2 else ''
                            
                            if mode_code and mode_code not in seen_codes:
                                seen_codes.add(mode_code)  # 記錄已處理的code
                                
                                # 清理資料
                                safe_rule = edit_rule.replace("'", "''")[:100] if edit_rule else ''
                                safe_desc = description.replace("'", "''")[:500] if description else mode_code
                                
                                # 使用ON CONFLICT處理重複鍵
                                sql_parts.append(f"""INSERT INTO mode_code_edit (mode_code, mode_description, edit_instructions) 
VALUES ('{mode_code}', '{safe_desc}', '{safe_rule}') 
ON CONFLICT (mode_code) DO UPDATE SET 
    mode_description = EXCLUDED.mode_description,
    edit_instructions = EXCLUDED.edit_instructions;""")
                                count += 1
                                
        except Exception as e:
            logging.error(f"❌ 解析Mode Code Edit檔案時發生錯誤: {e}")
            return False
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count} 筆Mode Code Edit資料"
        ])
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '07_import_mode_code_edit.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ Mode Code Edit轉換完成: {count} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段8: Mode Code Edit (模式代碼編輯規則) 資料轉換")
    print("=" * 60)
    
    converter = ModeCodeEditConverter()
    success = converter.parse_mode_code_edit_data()
    
    if success:
        print("\n🎉 Mode Code Edit資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/07_import_mode_code_edit.sql")
        print("📋 下一步: 執行 '08_convert_inc_fsc_xref.py'")
    else:
        print("\n❌ Mode Code Edit資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main() 
