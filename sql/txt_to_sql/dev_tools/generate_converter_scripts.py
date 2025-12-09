#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
腳本生成器 - 快速創建階段5轉換腳本
"""

from pathlib import Path

def generate_scripts():
    """創建轉換腳本"""
    
    # 腳本定義
    scripts_config = [
        # 已創建的腳本
        # ("00_convert_fsg.py", "FSG", "fsg", "Tabl316.TXT", "無"),
        
        # 需要創建的腳本 (階段1-7已有基礎表格)
        {
            "filename": "08_convert_inc_fsc_xref.py",
            "stage": "9",
            "table": "inc_fsc_xref",
            "description": "INC-FSC交叉參照",
            "source_file": "Tabl099.TXT",
            "dependencies": "inc (外鍵: inc_code), fsc (外鍵: fsc_code)",
            "parse_logic": """
                            # 解析格式: NM_CD_2303|FSG_3994|FSC_WI_FSG_3996|...
                            inc_code = parts[0].strip()
                            fsg_code = parts[1].strip()
                            fsc_within_fsg = parts[2].strip()
                            
                            # 建立完整FSC代碼
                            fsc_code = fsg_code + fsc_within_fsg
                            
                            if inc_code and fsc_code and len(fsc_code) == 4:
                                sql_parts.append(f"INSERT INTO inc_fsc_xref (inc_code, fsc_code) VALUES ('{inc_code}', '{fsc_code}');")"""
        },
        {
            "filename": "09_convert_nato_h6_inc_xref.py",
            "stage": "10", 
            "table": "nato_h6_inc_xref",
            "description": "NATO H6-INC對應",
            "source_file": "NATO-H6.TXT (REL_INC欄位)",
            "dependencies": "nato_h6_item_name (外鍵: h6_record_id), inc (外鍵: inc_code)",
            "parse_logic": """
                            # 從NATO H6記錄中提取關聯INC
                            if line.startswith('@') and '|' in line:
                                parts = line.strip().split('|')
                                h6_record_id = line[1:6]  # 提取H6 ID
                                
                                # 尋找關聯INC (通常在特定位置)
                                for part in parts:
                                    if part.strip().isdigit() and len(part.strip()) == 5:
                                        inc_code = part.strip()
                                        sql_parts.append(f"INSERT INTO nato_h6_inc_xref (h6_record_id, inc_code) VALUES ('{h6_record_id}', '{inc_code}');")"""
        },
        {
            "filename": "10_convert_colloquial_inc_xref.py",
            "stage": "11",
            "table": "colloquial_inc_xref", 
            "description": "俗稱INC對應",
            "source_file": "Tabl091.TXT",
            "dependencies": "inc (外鍵: primary_inc_code, colloquial_inc_code)",
            "parse_logic": """
                            # 解析格式: NM_CD_2303|REL_INC_2926|...
                            colloquial_inc = parts[0].strip()
                            related_inc = parts[1].strip()
                            
                            if colloquial_inc and related_inc:
                                sql_parts.append(f"INSERT INTO colloquial_inc_xref (primary_inc_code, colloquial_inc_code) VALUES ('{related_inc}', '{colloquial_inc}');")"""
        },
        {
            "filename": "11_convert_fiig.py",
            "stage": "12",
            "table": "fiig",
            "description": "FIIG (物品識別指南)",
            "source_file": "從編輯指南或建立",
            "dependencies": "無 (但邏輯上需要inc資料存在)",
            "parse_logic": """
                            # 可建立基本FIIG資料或從IIG_Library讀取
                            # 這裡先建立一些基礎FIIG範例
                            basic_fiigs = [
                                ('A001A0', 'Electronic Components Guide'),
                                ('B002B0', 'Mechanical Parts Guide'),
                                ('C003C0', 'Hardware Assembly Guide')
                            ]
                            
                            for fiig_code, description in basic_fiigs:
                                safe_desc = description.replace("'", "''")
                                sql_parts.append(f"INSERT INTO fiig (fiig_code, fiig_description) VALUES ('{fiig_code}', '{safe_desc}');")"""
        },
        {
            "filename": "12_convert_mrc_reply_table_xref.py",
            "stage": "13",
            "table": "mrc_reply_table_xref",
            "description": "MRC回應表對應",
            "source_file": "Tabl126.TXT",
            "dependencies": "mrc (外鍵: mrc_code), reply_table (邏輯依賴)",
            "parse_logic": """
                            # 解析格式: MRC_3445|RPLY_TBL_MRD_8254|...
                            mrc_code = parts[0].strip()
                            reply_table_number = parts[1].strip()
                            
                            if mrc_code and reply_table_number:
                                sql_parts.append(f"INSERT INTO mrc_reply_table_xref (mrc_code, reply_table_number) VALUES ('{mrc_code}', '{reply_table_number}');")"""
        },
        {
            "filename": "13_convert_fiig_inc_xref.py", 
            "stage": "14",
            "table": "fiig_inc_xref",
            "description": "FIIG-INC對應",
            "source_file": "Tabl122.TXT",
            "dependencies": "fiig (外鍵: fiig_code), inc (外鍵: inc_code)",
            "parse_logic": """
                            # 解析格式: FIIG_4065|INC_4080|...
                            fiig_code = parts[0].strip()
                            inc_code = parts[1].strip()
                            
                            if fiig_code and inc_code:
                                sql_parts.append(f"INSERT INTO fiig_inc_xref (fiig_code, inc_code) VALUES ('{fiig_code}', '{inc_code}');")"""
        },
        {
            "filename": "14_convert_fiig_inc_mrc_xref.py",
            "stage": "15", 
            "table": "fiig_inc_mrc_xref",
            "description": "FIIG-INC-MRC三元關聯",
            "source_file": "Tabl120.TXT", 
            "dependencies": "fiig (外鍵: fiig_code), inc (外鍵: inc_code), mrc (外鍵: mrc_code)",
            "parse_logic": """
                            # 解析格式: FIIG_4065|INC_4080|MRC_3445|FIIG_SEQ_NO_4404|...
                            fiig_code = parts[0].strip()
                            inc_code = parts[1].strip()
                            mrc_code = parts[2].strip()
                            sort_num = int(parts[3].strip()) if len(parts) > 3 and parts[3].strip().isdigit() else 1
                            
                            if fiig_code and inc_code and mrc_code:
                                sql_parts.append(f"INSERT INTO fiig_inc_mrc_xref (fiig_code, inc_code, mrc_code, sort_num) VALUES ('{fiig_code}', '{inc_code}', '{mrc_code}', {sort_num});")"""
        }
    ]
    
    # 生成腳本模板
    def create_script_content(config):
        return f'''#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段{config["stage"]}: {config["description"]} 資料轉換
對應檔案: {config["source_file"]}
輸出表格: {config["table"]}
依賴: {config["dependencies"]}
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

class {config["table"].title().replace("_", "")}Converter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_{config["table"]}_data(self):
        """解析{config["description"]}資料"""
        logging.info("🔍 階段{config["stage"]}: 解析{config["description"]}資料...")
        
        # 檔案路徑處理
        source_files = [
            self.raw_data_path / 'inc_fsc_xref' / 'Tabl099.TXT',
            self.raw_data_path / 'nato_h6_item_name' / 'NATO-H6.TXT',
            self.raw_data_path / 'colloquial_inc_xref' / 'Tabl091.TXT',
            self.raw_data_path / 'fiig' / 'FIIGEditGuide.txt',
            self.raw_data_path / 'mrc_reply_table_xref' / 'Tabl126.TXT',
            self.raw_data_path / 'fiig_inc_xref' / 'Tabl122.TXT',
            self.raw_data_path / 'fiig_inc_mrc_xref' / 'Tabl120.TXT'
        ]
        
        # 選擇對應的檔案
        source_file = None
        if "{config["source_file"]}" == "Tabl099.TXT":
            source_file = source_files[0]
        elif "NATO-H6" in "{config["source_file"]}":
            source_file = source_files[1]
        elif "{config["source_file"]}" == "Tabl091.TXT":
            source_file = source_files[2]
        elif "編輯指南" in "{config["source_file"]}":
            source_file = source_files[3]
        elif "{config["source_file"]}" == "Tabl126.TXT":
            source_file = source_files[4]
        elif "{config["source_file"]}" == "Tabl122.TXT":
            source_file = source_files[5]
        elif "{config["source_file"]}" == "Tabl120.TXT":
            source_file = source_files[6]
        
        if not source_file or not source_file.exists():
            logging.error(f"❌ 來源檔案不存在: {{source_file}}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段{config["stage"]}: {config["description"]} 資料匯入",
            "-- 對應檔案: {config["source_file"]}", 
            "-- 目標表格: {config["table"]}",
            "-- 依賴: {config["dependencies"]}",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM {config["table"]};",
            ""
        ]
        
        count = 0
        batch_size = 1000
        
        try:
            with open(source_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if line and ('|' in line or line.startswith('@')):
                        parts = line.split('|') if '|' in line else [line]
                        if len(parts) >= 2 or line.startswith('@'):
{config["parse_logic"]}
                            count += 1
                            
                            if count % batch_size == 0:
                                logging.info(f"⏳ 處理進度: {{count:,}} 筆")
                                
        except Exception as e:
            logging.error(f"❌ 解析檔案時發生錯誤: {{e}}")
            return False
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {{count:,}} 筆{config["description"]}資料"
        ])
        
        # 寫入檔案
        sql_content = '\\n'.join(sql_parts) + '\\n'
        output_file = self.output_dir / '{config["stage"].zfill(2)}_import_{config["table"]}.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ {config["description"]}轉換完成: {{count:,}} 筆資料 → {{output_file}}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {{e}}")
            return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段{config["stage"]}: {config["description"]} 資料轉換")
    print("=" * 60)
    
    converter = {config["table"].title().replace("_", "")}Converter()
    success = converter.parse_{config["table"]}_data()
    
    if success:
        print("\\n🎉 {config["description"]}資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/{config["stage"].zfill(2)}_import_{config["table"]}.sql")
        next_stage = int("{config["stage"]}") + 1
        if next_stage <= 15:
            print(f"📋 下一步: 執行 '{next_stage:02d}_convert_*.py'")
        else:
            print("📋 所有轉換完成，下一步: 執行 'execute_sql_scripts.py'")
    else:
        print("\\n❌ {config["description"]}資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main()
'''
    
    # 創建所有腳本
    for config in scripts_config:
        script_path = Path(config["filename"])
        
        if not script_path.exists():
            try:
                with open(script_path, 'w', encoding='utf-8') as f:
                    f.write(create_script_content(config))
                
                # 設定執行權限 (Unix系統)
                try:
                    script_path.chmod(0o755)
                except:
                    pass
                    
                print(f"✅ 已創建: {config['filename']} - {config['description']}")
            except Exception as e:
                print(f"❌ 創建失敗 {config['filename']}: {e}")
        else:
            print(f"⚠️  已存在: {config['filename']}")
    
    print(f"\n✅ 腳本生成完成！")
    print(f"📊 當前目錄共有 {len(scripts_config)} 個轉換腳本")
    print(f"🚀 使用 'master_converter.py' 來執行所有轉換")

if __name__ == "__main__":
    generate_scripts() 
