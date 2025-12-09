#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段7: MRC (主需求代碼) 資料轉換
對應檔案: Tabl127.TXT + Tabl347.TXT
輸出表格: mrc
依賴: mrc_key_group
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

class MRCConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def map_key_group_code(self, raw_key_group):
        """映射key_group_code到標準的key_group_number"""
        if not raw_key_group or raw_key_group.strip() == '':
            return '19'  # 預設為 Miscellaneous
        
        key_group = raw_key_group.strip().upper()
        
        # 根據常見的分類映射到19個標準群組
        key_group_map = {
            'A': '01',    # Color類型
            'B': '02',    # Design類型  
            'C': '01',    # Color類型
            'D': '03',    # Dimensions類型
            'E': '04',    # Electrical類型
            'F': '05',    # Features類型
            'G': '06',    # Materials類型
            'H': '07',    # Performance類型
            'I': '08',    # Physical類型
            'J': '09',    # Ratings類型
            'K': '10',    # Size類型
            'L': '11',    # Special類型
            'M': '12',    # Style類型
            'N': '13',    # Thread類型
            'O': '14',    # Type類型
            'P': '15',    # Weight類型
            'Q': '16',    # Configuration類型
            'R': '17',    # Mounting類型
            'S': '18',    # Terminal類型
            'T': '14',    # Type類型
            'U': '19',    # Miscellaneous
            'V': '19',    # Miscellaneous
            'W': '19',    # Miscellaneous
            'X': '19',    # Miscellaneous
            'Y': '19',    # Miscellaneous
            'Z': '19',    # Miscellaneous
        }
        
        # 如果是數字代碼，嘗試對應到標準分組
        if key_group.isdigit():
            num = int(key_group)
            if 1 <= num <= 19:
                return f"{num:02d}"
            else:
                return '19'  # 超出範圍，歸類為Miscellaneous
        
        return key_group_map.get(key_group, '19')  # 預設為Miscellaneous
        
    def parse_mrc_data(self):
        """解析MRC資料 (從Tabl127.TXT + Tabl347.TXT)"""
        logging.info("🔍 階段7: 解析MRC (主需求代碼) 資料...")
        
        mrc_file = self.raw_data_path / 'mrc' / 'Tabl127.TXT'
        definition_file = self.raw_data_path / 'mrc' / 'Tabl347.TXT'
        
        if not mrc_file.exists():
            logging.error(f"❌ MRC檔案不存在: {mrc_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段7: MRC (主需求代碼) 資料匯入",
            "-- 對應檔案: Tabl127.TXT + Tabl347.TXT", 
            "-- 目標表格: mrc",
            "-- 依賴: mrc_key_group (外鍵: key_group_number)",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM mrc;",
            ""
        ]
        
        # 讀取定義檔案
        definitions = {}
        if definition_file.exists():
            try:
                with open(definition_file, 'r', encoding='utf-8', errors='ignore') as f:
                    for line in f:
                        if '|' in line:
                            parts = line.strip().split('|')
                            if len(parts) >= 2:
                                mrc_code = parts[0].strip()
                                definition = parts[1].strip()
                                definitions[mrc_code] = definition
                logging.info(f"📚 讀取 {len(definitions)} 筆MRC定義")
            except Exception as e:
                logging.warning(f"⚠️  無法讀取定義檔案: {e}")
        
        count = 0
        batch_size = 500
        key_group_stats = {}
        
        try:
            with open(mrc_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if line and '|' in line:
                        parts = line.split('|')
                        if len(parts) >= 4:
                            # 解析格式: 9000| |D| |DATE OF PRECEDING RECORD|15|...
                            mrc_code = parts[0].strip()
                            raw_key_group = parts[1].strip()
                            requirement_statement = parts[4].strip() if len(parts) > 4 else ''
                            mode_code = parts[2].strip() if len(parts) > 2 else ''
                            
                            if mrc_code:
                                # 映射key_group_code
                                key_group_number = self.map_key_group_code(raw_key_group)
                                
                                # 統計映射情況
                                mapping_key = f"{raw_key_group} -> {key_group_number}"
                                key_group_stats[mapping_key] = key_group_stats.get(mapping_key, 0) + 1
                                
                                # 查詢詳細定義
                                requirement_definition = definitions.get(mrc_code, '')
                                
                                # 清理資料
                                safe_statement = requirement_statement.replace("'", "''")[:500] if requirement_statement else 'No requirement statement'
                                safe_definition = requirement_definition.replace("'", "''")[:1000] if requirement_definition else ''
                                
                                # 設定資料類型
                                data_type = self.determine_data_type(requirement_statement, mode_code)
                                
                                sql_parts.append(f"""INSERT INTO mrc (mrc_code, key_group_number, requirement_statement, data_type, help_text) 
VALUES ('{mrc_code}', '{key_group_number}', '{safe_statement}', '{data_type}', '{safe_definition}');""")
                                count += 1
                                
                                if count % batch_size == 0:
                                    logging.info(f"⏳ 處理進度: {count:,} 筆")
                                    
        except Exception as e:
            logging.error(f"❌ 解析MRC檔案時發生錯誤: {e}")
            return False
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count:,} 筆MRC資料",
            "-- Key Group映射統計:"
        ])
        
        # 加入映射統計
        for mapping, count_val in sorted(key_group_stats.items()):
            sql_parts.append(f"-- {mapping}: {count_val:,} 筆")
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '06_import_mrc.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ MRC轉換完成: {count:,} 筆資料 → {output_file}")
            
            # 輸出映射統計到控制台
            logging.info("📊 Key Group映射統計:")
            for mapping, count_val in sorted(key_group_stats.items()):
                logging.info(f"  {mapping}: {count_val:,} 筆")
            
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False
    
    def determine_data_type(self, statement, mode_code):
        """根據需求描述和模式代碼判斷資料類型"""
        if not statement:
            return 'TEXT'
            
        statement_lower = statement.lower()
        
        if any(keyword in statement_lower for keyword in ['length', 'width', 'height', 'diameter', 'thickness']):
            return 'NUMERIC'
        elif any(keyword in statement_lower for keyword in ['color', 'colour', 'material']):
            return 'TEXT'
        elif mode_code in ['D', 'H']:  # 通常D和H模式用於數值
            return 'NUMERIC'
        else:
            return 'TEXT'

def main():
    """主程式"""
    print("=" * 60)
    print("階段7: MRC (主需求代碼) 資料轉換")
    print("=" * 60)
    
    converter = MRCConverter()
    success = converter.parse_mrc_data()
    
    if success:
        print("\n🎉 MRC資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/06_import_mrc.sql")
        print("📋 下一步: 執行 '07_convert_mode_code_edit.py'")
    else:
        print("\n❌ MRC資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main() 
