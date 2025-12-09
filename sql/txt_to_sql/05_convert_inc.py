#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
階段6: INC (物品名稱代碼) 資料轉換
對應檔案: Tabl098.TXT (以 '|' 分隔), iig.txt (以 ';' 分隔)
輸出表格: inc
說明: 此腳本整合來自 Tabl098.TXT 的基本 INC 資料和來自 iig.txt 的完整物品名稱，
      以 iig.txt 的資料為優先，解決名稱截斷問題。
"""

import os
import sys
import re
from pathlib import Path
import logging

# 設定日誌
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class INCConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')
        self.output_dir = Path('../data_import')
        self.output_dir.mkdir(exist_ok=True)
        self.iig_data = self._load_iig_data()
        self.inc_definitions = self._load_inc_definitions()

    def normalize_for_search(self, text):
        """
        將文字正規化為搜尋格式：移除所有標點符號、空格、特殊字元
        範例: "TRAP, MOISTURE" → "TRAPMOISTURE"
        """
        if not text:
            return ''

        # 移除所有非字母數字字元，保留英文和數字
        normalized = re.sub(r'[^A-Za-z0-9]', '', text)

        # 轉換為大寫
        return normalized.upper()

    def normalize_status_code(self, raw_status):
        """正規化狀態碼"""
        if not raw_status or raw_status.strip() == '':
            return 'A'  # 預設為活躍
        
        status = raw_status.strip().upper()
        
        # 狀態碼映射表
        status_map = {
            'A': 'A',      # Active
            'ACTIVE': 'A',
            'I': 'I',      # Inactive  
            'INACTIVE': 'I',
            'P': 'P',      # Proposed
            'PROPOSED': 'P',
            'S': 'S',      # Superseded
            'SUPERSEDED': 'S',
            # 其他可能的值映射到最接近的標準值
            'F': 'I',      # 可能表示 Final/Finished -> Inactive
            'C': 'I',      # 可能表示 Cancelled -> Inactive  
            'D': 'I',      # 可能表示 Deleted -> Inactive
            'E': 'A',      # 可能表示 Effective -> Active
            'O': 'I',      # 可能表示 Obsolete -> Inactive
            'R': 'S',      # 可能表示 Replaced -> Superseded
            'T': 'P',      # 可能表示 Temporary -> Proposed
        }
        
        return status_map.get(status, 'A')  # 不認識的預設為 Active
        
    def _load_iig_data(self):
        """從 iig.txt (分號分隔) 加載 INC 和物品名稱的對應關係"""
        iig_file = self.raw_data_path / 'inc' / 'iig.txt'
        iig_data = {}
        if not iig_file.exists():
            logging.warning(f"⚠️ iig.txt 檔案不存在於 {iig_file}，將僅使用主要資料來源。")
            return iig_data
        
        logging.info(f"📖 正在從 {iig_file} 加載完整的物品名稱...")
        with open(iig_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                line = line.strip()
                if ';' in line:
                    parts = line.split(';', 1)
                    if len(parts) == 2:
                        inc_code, item_name = parts
                        iig_data[inc_code.strip()] = item_name.strip()
        logging.info(f"✅ 成功加載 {len(iig_data)} 筆來自 iig.txt 的物品名稱。")
        return iig_data

    def _parse_nato_h6_line(self, line):
        """解析 NATO-H6 的單行資料，回傳 INC 與定義內容"""
        if not line or not line.startswith('@') or len(line) < 6:
            return None

        length = len(line)
        inc_code = line[1:6].strip()
        if not inc_code:
            return None

        pos = 6

        # 跳過 FIIG (固定 9 個字元) 與審核碼 (10 個字元)
        pos = min(length, pos + 9)
        pos = min(length, pos + 10)

        # 跳過多餘空白
        while pos < length and line[pos].isspace():
            pos += 1

        if pos + 4 > length:
            return None
        name_len_str = line[pos:pos + 4]
        if not name_len_str.isdigit():
            return None
        name_len = int(name_len_str)
        pos += 4

        if pos + name_len > length:
            return None
        pos += name_len

        if pos + 4 > length:
            return None
        definition_len_str = line[pos:pos + 4]
        if not definition_len_str.isdigit():
            return None
        definition_len = int(definition_len_str)
        pos += 4

        if definition_len == 0 or pos >= length:
            return None

        remaining = line[pos:]
        definition = remaining[:definition_len] if definition_len <= len(remaining) else remaining
        definition = definition.strip()

        if not definition:
            return None

        return {
            'inc_code': inc_code,
            'definition': definition
        }

    def _load_inc_definitions(self):
        """載入 NATO-H6 物品定義資料"""
        nato_file = self.raw_data_path / 'inc' / 'NATO-H6.TXT'
        definitions = {}

        if not nato_file.exists():
            logging.warning(f"⚠️ NATO-H6.TXT 檔案不存在於 {nato_file}，無法載入物品定義。")
            return definitions

        logging.info(f"📖 正在載入 INC 物品定義: {nato_file}")
        loaded = 0
        skipped = 0

        with open(nato_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line_num, raw_line in enumerate(f, 1):
                line = raw_line.rstrip('\r\n')
                if not line:
                    continue

                parsed = self._parse_nato_h6_line(line)
                if not parsed:
                    skipped += 1
                    continue

                inc_code = parsed['inc_code']
                definition = parsed['definition']

                definitions[inc_code] = definition
                loaded += 1

        logging.info(f"✅ 成功載入 {loaded:,} 筆物品定義（略過 {skipped:,} 筆）。")
        return definitions

    def parse_inc_data(self):
        """解析INC資料 (主要從 Tabl098.TXT (管線符號 '|' 分隔), 並用 iig.txt 進行擴充)"""
        logging.info("🔍 階段6: 解析INC (物品名稱代碼) 資料...")
        
        inc_file = self.raw_data_path / 'inc' / 'Tabl098.TXT'
        if not inc_file.exists():
            logging.error(f"❌ INC檔案不存在: {inc_file}")
            return False
        
        sql_parts = [
            "-- =================================================================",
            "-- 階段6: INC (物品名稱代碼) 資料匯入",
            "-- 對應檔案: Tabl098.TXT (基礎), iig.txt (完整名稱)", 
            "-- 目標表格: inc",
            "-- 依賴: 無",
            "-- =================================================================",
            "",
            "BEGIN;",
            "",
            "-- 清除現有資料",
            "DELETE FROM inc;",
            ""
        ]
        
        count = 0
        batch_size = 1000
        processed_inc = set()
        
        try:
            with open(inc_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if not line or '|' not in line:
                        continue
                    
                    try:
                        line_parts = line.split('|')
                        if len(line_parts) < 5: # 確保至少有足夠的欄位來解析
                            continue

                        inc_code_from_file = line_parts[0].strip()

                        if not inc_code_from_file or inc_code_from_file in processed_inc:
                            continue

                        # 建立查詢鍵，移除 'G' 等非數字前綴，以匹配 iig.txt 中的鍵 (例如 'G00232' -> '00232')
                        lookup_key = re.sub(r'^[A-Z]+', '', inc_code_from_file)
                        
                        # 嘗試從 iig.txt 的快取資料中獲取完整名稱
                        full_name_from_iig = self.iig_data.get(lookup_key)
                        
                        short_name, name_prefix, name_root_remainder = '', '', ''
                        is_official = False
                        full_name = ""

                        # 步驟1: 優先從 iig.txt 獲取官方、完整的名稱
                        if full_name_from_iig:
                            is_official = True
                            full_name = full_name_from_iig
                        # 步驟2: 如果 iig.txt 中沒有，則從 Tabl098.TXT 中重建名稱
                        else:
                            name_part1 = line_parts[4].strip()
                            # 名稱的接續部分通常在第6個索引 (第7欄)
                            name_part2 = line_parts[6].strip() if len(line_parts) > 6 else ""
                            full_name = (name_part1 + name_part2).strip()
                        
                        # 解析最終得到的名稱 (無論來源是 iig 還是 Tabl098)
                        if full_name:
                            name_parts = [p.strip() for p in full_name.split(',')]
                            if len(name_parts) > 0: short_name = name_parts[0]
                            if len(name_parts) > 1: name_prefix = name_parts[1]
                            if len(name_parts) > 2: name_root_remainder = ','.join(name_parts[2:])

                        # 從 Tabl098.TXT 的第3個索引 (第4欄) 取得狀態碼
                        status_code_raw = line_parts[3].strip()
                        status_code = self.normalize_status_code(status_code_raw)

                        # 生成 search_text（正規化搜尋文字）
                        search_text = self.normalize_for_search(full_name)

                        # 清理特殊字元（如單引號），以避免 SQL 語法錯誤
                        safe_short_name = short_name.replace("'", "''")
                        safe_name_prefix = name_prefix.replace("'", "''")
                        safe_name_root_remainder = name_root_remainder.replace("'", "''")
                        safe_search_text = search_text  # 已經正規化，不包含特殊字元

                        definition_text = self.inc_definitions.get(inc_code_from_file)
                        if not definition_text:
                            definition_text = self.inc_definitions.get(lookup_key)

                        if definition_text:
                            safe_definition = definition_text.replace("'", "''")
                            definition_value = f"'{safe_definition}'"
                        else:
                            definition_value = "NULL"

                        # 建立 INSERT INTO 陳述式
                        sql_parts.append(
                            f"INSERT INTO inc (inc_code, short_name, name_prefix, name_root_remainder, search_text, status_code, is_official, item_name_definition) "
                            f"VALUES ('{inc_code_from_file}', '{safe_short_name}', '{safe_name_prefix}', '{safe_name_root_remainder}', '{safe_search_text}', '{status_code}', {is_official}, {definition_value});"
                        )
                        processed_inc.add(inc_code_from_file)
                        count += 1
                        
                        if count % batch_size == 0:
                            logging.info(f"⏳ 處理進度: {count:,} 筆")
                    
                    except Exception as e:
                        logging.warning(f"⚠️ 跳過行 {line_num}: {line}，原因: {e}")
                        continue
                            
        except Exception as e:
            logging.error(f"❌ 解析INC檔案時發生錯誤: {e}")
            return False
        
        sql_parts.extend([
            "",
            "COMMIT;",
            "",
            f"-- 統計: 成功匯入 {count:,} 筆INC資料"
        ])
        
        sql_content = '\n'.join(sql_parts) + '\n'
        output_file = self.output_dir / '05_import_inc.sql'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            logging.info(f"✅ INC轉換完成: {count:,} 筆資料 → {output_file}")
            return True
        except Exception as e:
            logging.error(f"❌ 寫入檔案失敗: {e}")
            return False

def main():
    """主程式"""
    print("=" * 60)
    print("階段6: INC (物品名稱代碼) 資料轉換")
    print("=" * 60)
    
    converter = INCConverter()
    success = converter.parse_inc_data()
    
    if success:
        print("\n🎉 INC資料轉換成功完成！")
        print("📂 輸出檔案: sql/data_import/05_import_inc.sql")
        print("📄 資料來源: Tabl098.TXT, iig.txt")
        print("📋 下一步: 執行 '06_convert_mrc.py'")
    else:
        print("\n❌ INC資料轉換失敗，請檢查錯誤訊息")
        sys.exit(1)

if __name__ == "__main__":
    main() 
