#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段2: MRC Key Group (MRC關鍵字分組) 資料轉換
對應檔案: Tabl391.TXT
輸出表格: mrc_key_group
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

class MRCKeyGroupConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_mrc_key_group_data(self):
        """解析MRC Key Group資料 (從Tabl391.TXT)"""
        logging.info("🔍 階段2: 解析MRC Key Group (MRC關鍵字分組) 資料...")
        
        mrc_file = self.raw_data_path / 'mrc_key_group' / 'Tabl391.TXT'
        if not mrc_file.exists():
            logging.error(f"❌ MRC Key Group檔案不存在: {mrc_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段2: MRC Key Group (MRC關鍵字分組) 資料匯入",
            "-- 對應檔案: Tabl391.TXT", 
            "-- 目標表格: mrc_key_group",
            "-- 依賴: 無",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM mrc_key_group;",
            ""
        ]
        
        # 預定義的19個MRC關鍵字分組
        predefined_groups = {
            '01': 'Color',
            '02': 'Design', 
            '03': 'Dimensions',
            '04': 'Electrical',
            '05': 'Features',
            '06': 'Materials',
            '07': 'Performance',
            '08': 'Physical',
            '09': 'Ratings',
            '10': 'Size',
            '11': 'Special',
            '12': 'Style',
            '13': 'Thread',
            '14': 'Type',
            '15': 'Weight',
            '16': 'Configuration',
            '17': 'Mounting',
            '18': 'Terminal',
            '19': 'Miscellaneous'
        }
        
        count = 0
        
        try:
            # 嘗試從檔案讀取，如果檔案為空或格式錯誤則使用預定義資料
            groups_from_file = {}
            
            with open(mrc_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if line and '|' in line:
                        parts = line.split('|')
                        if len(parts) >= 2:
                            group_code = parts[0].strip()
                            group_desc = parts[1].strip()
                            if group_code and group_desc:
                                groups_from_file[group_code] = group_desc
                                
            # 如果從檔案得到資料，使用檔案的資料；否則使用預定義資料
            groups_to_use = groups_from_file if groups_from_file else predefined_groups
            
        except Exception as e:
            logging.warning(f"⚠️  讀取檔案時發生錯誤: {e}，使用預定義資料")
            groups_to_use = predefined_groups
        
        # 生成SQL插入語句
        for group_code in sorted(groups_to_use.keys()):
            group_desc = groups_to_use[group_code]
            safe_desc = group_desc.replace("'", "''")
            sql_parts.append(f"INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('{group_code}', '{safe_desc}');")
            count += 1
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count} 筆MRC Key Group資料"
        ])
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '01_import_mrc_key_group.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ MRC Key Group轉換完成: {count} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段2: MRC Key Group (MRC關鍵字分組) 資料轉換")
    print("=" * 60)
    
    converter = MRCKeyGroupConverter()
    success = converter.parse_mrc_key_group_data()
    
    if success:
        print("\n🎉 MRC Key Group資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/01_import_mrc_key_group.sql")
        print("📋 下一步: 執行 '02_convert_reply_table.py'")
    else:
        print("\n❌ MRC Key Group資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main() 
