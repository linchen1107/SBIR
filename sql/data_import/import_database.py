#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
NSN料號申編系統 - 資料庫匯入工具
(適用於 Docker 環境)
"""

import os
import sys
import time
import psycopg2
import logging
from datetime import datetime
from pathlib import Path

# --- 新的、更可靠的路徑設定 ---
script_dir = Path(__file__).parent.resolve()
project_root = script_dir.parent.parent
sys.path.insert(0, str(project_root))
# --- 結束路徑設定 ---

from sql.database_config.database_config import get_db_config_instance

class DatabaseImporter:
    """資料庫匯入器"""

    def __init__(self):
        # --- FINAL FIX: Hardcode connection params to bypass all environment issues ---
        self.db_config = {
            "host": "postgres",
            "port": 5432,
            "dbname": "nsn_database",
            "user": "postgres",
            "password": "postgres",
        }
        # --- END FIX ---
        self.script_dir = Path(__file__).parent.resolve()
        self.setup_logging()
        
        # SQL檔案清單（按照順序）
        self.sql_files = [
            "00_import_fsg.sql", "01_import_mrc_key_group.sql", 
            "02_import_reply_table.sql", "03_import_fsc.sql",
            "04_import_nato_h6_item_name.sql", "05_import_inc.sql",
            "06_import_mrc.sql", "07_import_mode_code_edit.sql",
            "08_import_inc_fsc_xref.sql", "09_import_nato_h6_inc_xref.sql",
            "10_import_colloquial_inc_xref.sql", "11_import_fiig.sql",
            "12_import_mrc_reply_table_xref.sql", "13_import_fiig_inc_xref.sql",
            "14_import_fiig_inc_mrc_xref.sql"
        ]

    def setup_logging(self):
        """設定日誌記錄"""
        log_filename = self.script_dir / f"import_log_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_filename, encoding='utf-8'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)
        self.logger.info(f"日誌檔案: {log_filename}")

    def test_connection(self):
        """測試資料庫連線"""
        try:
            conn = psycopg2.connect(**self.db_config)
            cursor = conn.cursor()
            cursor.execute("SELECT version();")
            version = cursor.fetchone()[0]
            cursor.close()
            conn.close()
            self.logger.info("✅ 資料庫連線成功")
            self.logger.info(f"PostgreSQL版本: {version}")
            return True
        except Exception as e:
            self.logger.error(f"❌ 資料庫連線失敗: {e}")
            return False

    def execute_sql_file(self, filename):
        """執行單一SQL檔案"""
        filepath = self.script_dir / filename
        if not filepath.exists():
            self.logger.error(f"❌ 檔案不存在: {filepath}")
            return False
        
        file_size_mb = filepath.stat().st_size / (1024 * 1024)
        self.logger.info(f"📄 準備執行: {filename} ({file_size_mb:.1f} MB)")
        
        if file_size_mb > 50: # 大檔案警告
             self.logger.info(f"⚠️  大檔案警告: 此檔案較大 ({file_size_mb:.1f} MB)，預計需要較長時間...")

        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            
            conn = psycopg2.connect(**self.db_config)
            conn.autocommit = True
            cursor = conn.cursor()
            
            start_time = time.time()
            cursor.execute(sql_content)
            end_time = time.time()
            
            self.logger.info(f"✅ 完成: {filename}, 耗時: {end_time - start_time:.2f}秒")
            
            cursor.close()
            conn.close()
            return True
        except Exception as e:
            self.logger.error(f"❌ 執行失敗: {filename}")
            self.logger.error(f"錯誤詳情: {e}")
            return False

    def run_import(self):
        """執行完整的匯入流程"""
        db_info = self.db_config
        self.logger.info("=" * 60)
        self.logger.info("  NSN料號申編系統 - 資料庫匯入工具 (Docker版)")
        self.logger.info(f"  目標資料庫: {db_info.get('host')}:{db_info.get('port')}/{db_info.get('dbname')}")
        self.logger.info("=" * 60)
        
        if not self.test_connection():
            return False
        
        start_time = time.time()
        success_count = 0
        
        for i, filename in enumerate(self.sql_files, 1):
            self.logger.info(f"🚀 [{i:2d}/{len(self.sql_files)}] 執行中...")
            if self.execute_sql_file(filename):
                success_count += 1
                self.logger.info(f"✅ [{i:2d}/{len(self.sql_files)}] 完成\n")
            else:
                self.logger.error(f"❌ [{i:2d}/{len(self.sql_files)}] 失敗，停止執行")
                return False
        
        total_time = time.time() - start_time
        self.logger.info("=" * 60)
        self.logger.info("🎉 資料匯入完成！")
        self.logger.info(f"✅ 成功執行: {success_count}/{len(self.sql_files)} 個檔案")
        self.logger.info(f"⏱️  總耗時: {total_time//60:.0f}分{total_time%60:.1f}秒")
        return True

def main():
    """主函數"""
    importer = DatabaseImporter()
    if not importer.run_import():
        sys.exit(1)

if __name__ == "__main__":
    main()
