#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段12: FIIG (物品識別指南) 資料轉換
對應檔案: 從 fiig_inc_xref 中提取 FIIG 代碼
輸出表格: fiig
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

class FIIGConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_fiig_data(self):
        """從 FIIG-INC 對應檔案中提取 FIIG 代碼"""
        logging.info("🔍 階段12: 從 FIIG-INC 對應資料中提取 FIIG 代碼...")
        
        # 檢查 FIIG-INC 對應檔案
        fiig_inc_file = self.raw_data_path / 'fiig_inc_xref' / 'Tabl122.TXT'
        if not fiig_inc_file.exists():
            logging.error(f"❌ FIIG-INC對應檔案不存在: {fiig_inc_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段12: FIIG (物品識別指南) 資料匯入",
            "-- 對應檔案: 從 fiig_inc_xref 中提取",
            "-- 目標表格: fiig",
            "-- 依賴: 無",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM fiig;",
            "",
            "-- 重設序列",
            "-- ALTER SEQUENCE fiig_id_seq RESTART WITH 1;",
            ""
        ]
        
        # 用於儲存唯一的 FIIG 代碼
        fiig_codes = set()
        
        try:
            with open(fiig_inc_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if '|' in line:
                        parts = line.split('|')
                        if len(parts) >= 1:
                            # 格式: FIIG_CODE|INC_CODE|其他欄位
                            fiig_code = parts[0].strip()
                            
                            if fiig_code and len(fiig_code) <= 10:  # 確保不超過欄位長度
                                fiig_codes.add(fiig_code)
                    
                    # 定期記錄進度
                    if line_num % 10000 == 0:
                        logging.info(f"已掃描 {line_num} 行，找到 {len(fiig_codes)} 個唯一FIIG代碼...")
                        
        except Exception as e:
            logging.error(f"❌ 解析FIIG-INC對應檔案時發生錯誤: {e}")
            return False
        
        # 生成 FIIG 插入語句
        count = 0
        for fiig_code in sorted(fiig_codes):
            safe_fiig = fiig_code.replace("'", "''")
            # 使用 FIIG 代碼作為描述的一部分
            description = f"FIIG {safe_fiig} - Federal Item Identification Guide"
            
            sql_parts.append(
                f"INSERT INTO fiig (fiig_code, fiig_description) VALUES ('{safe_fiig}', '{description}');"
            )
            count += 1
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count} 筆FIIG資料"
        ])
        
        # 寫入檔案
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '11_import_fiig.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ FIIG轉換完成: {count} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段12: FIIG 資料轉換")
    print("=" * 60)
    
    converter = FIIGConverter()
    success = converter.parse_fiig_data()
    
    if success:
        print("\n🎉 FIIG 資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/11_import_fiig.sql")
        print("📋 下一步: 執行 '12_convert_mrc_reply_table_xref.py'")
    else:
        print("\n❌ FIIG 資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main()
