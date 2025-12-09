#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
客製化 NSN 資料匯入工具
資料庫: sbir_equipment_db_v3
目標 Schema: public
"""

import os
import sys
import time
import psycopg2
import logging
from datetime import datetime
from pathlib import Path

class NSNDataImporter:
    """NSN 資料匯入器（客製化版本）"""

    def __init__(self, db_host='localhost', db_port=5432, db_name='sbir_equipment_db_v3', 
                 db_user='postgres', db_password='willlin07'):
        """
        初始化匯入器
        
        Args:
            db_host: 資料庫主機
            db_port: 資料庫埠號
            db_name: 資料庫名稱
            db_user: 使用者名稱
            db_password: 密碼
        """
        self.db_config = {
            "host": db_host,
            "port": db_port,
            "dbname": db_name,
            "user": db_user,
            "password": db_password,
            "options": "-c search_path=public"  # 固定使用 public schema
        }
        
        # 設定資料來源目錄（絕對路徑）
        self.script_dir = Path(__file__).parent.resolve()
        # 從 Database/scripts/03-data-import 往上到專案根目錄，再到 sql/data_import
        project_root = self.script_dir.parent.parent.parent
        self.data_source_dir = project_root / 'sql' / 'data_import'
        
        self.setup_logging()
        
        # SQL檔案清單（按照依賴順序）
        self.sql_files = [
            # 基礎資料表（無依賴）
            "00_import_fsg.sql",              # FSG 聯邦補給群組
            "01_import_mrc_key_group.sql",    # MRC 群組
            "02_import_reply_table.sql",      # 回應表主檔
            
            # 分類表（依賴 FSG）
            "03_import_fsc.sql",              # FSC 聯邦補給分類
            
            # NATO 和 INC 表
            "04_import_nato_h6_item_name.sql", # NATO H6 物品名稱
            "05_import_inc.sql",              # INC 物品名稱代碼
            
            # MRC 和模式碼
            "06_import_mrc.sql",              # MRC 物料需求代碼
            "07_import_mode_code_edit.sql",   # 模式碼編輯指南
            
            # 關聯表（依賴多個主表）
            "08_import_inc_fsc_xref.sql",     # INC-FSC 對應
            "09_import_nato_h6_inc_xref.sql", # H6-INC 對應
            "10_import_colloquial_inc_xref.sql", # 俗語 INC 對應
            
            # FIIG 系統
            "11_import_fiig.sql",             # FIIG 識別指南
            
            # 複雜關聯（依賴 MRC 和 FIIG）
            "12_import_mrc_reply_table_xref.sql",  # MRC-回應表對應
            "13_import_fiig_inc_xref.sql",    # FIIG-INC 對應
            "14_import_fiig_inc_mrc_xref.sql" # FIIG-INC-MRC 三元對應（最大檔案）
        ]

    def setup_logging(self):
        """設定日誌記錄"""
        log_dir = self.script_dir
        log_filename = log_dir / f"nsn_import_log_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        
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
            
            # 檢查 PostgreSQL 版本
            cursor.execute("SELECT version();")
            version = cursor.fetchone()[0]
            
            # 檢查 public schema 是否存在
            cursor.execute("""
                SELECT schema_name 
                FROM information_schema.schemata 
                WHERE schema_name = 'public';
            """)
            if not cursor.fetchone():
                self.logger.error("❌ public schema 不存在！")
                return False
            
            # 檢查 public schema 中的表格數量
            cursor.execute("""
                SELECT COUNT(*) 
                FROM pg_tables 
                WHERE schemaname = 'public';
            """)
            table_count = cursor.fetchone()[0]
            
            cursor.close()
            conn.close()
            
            self.logger.info("✅ 資料庫連線成功")
            self.logger.info(f"   PostgreSQL: {version.split(',')[0]}")
            self.logger.info(f"   public schema: {table_count} 個表格")
            return True
            
        except Exception as e:
            self.logger.error(f"❌ 資料庫連線失敗: {e}")
            return False

    def execute_sql_file(self, filename):
        """執行單一 SQL 檔案"""
        filepath = self.data_source_dir / filename
        
        if not filepath.exists():
            self.logger.error(f"❌ 檔案不存在: {filepath}")
            return False
        
        file_size_mb = filepath.stat().st_size / (1024 * 1024)
        self.logger.info(f"📄 準備執行: {filename} ({file_size_mb:.1f} MB)")
        
        # 大檔案警告
        if file_size_mb > 50:
            self.logger.info(f"⚠️  大檔案警告: 此檔案較大，預計需要較長時間...")
        
        try:
            # 讀取 SQL 內容
            with open(filepath, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            
            # 連接資料庫並執行
            conn = psycopg2.connect(**self.db_config)
            conn.autocommit = True
            cursor = conn.cursor()
            
            start_time = time.time()
            cursor.execute(sql_content)
            end_time = time.time()
            
            elapsed = end_time - start_time
            self.logger.info(f"✅ 完成: {filename}, 耗時: {elapsed:.2f}秒")
            
            cursor.close()
            conn.close()
            return True
            
        except psycopg2.Error as e:
            self.logger.error(f"❌ SQL 執行失敗: {filename}")
            self.logger.error(f"   錯誤: {e}")
            return False
        except Exception as e:
            self.logger.error(f"❌ 執行失敗: {filename}")
            self.logger.error(f"   錯誤: {e}")
            return False

    def verify_import(self):
        """驗證匯入結果"""
        try:
            conn = psycopg2.connect(**self.db_config)
            cursor = conn.cursor()
            
            self.logger.info("\n" + "=" * 60)
            self.logger.info("資料匯入驗證")
            self.logger.info("=" * 60)
            
            # 檢查主要表格的資料筆數
            tables_to_check = [
                ('fsg', 'FSG 聯邦補給群組'),
                ('fsc', 'FSC 聯邦補給分類'),
                ('nato_h6_item_name', 'NATO H6 物品名稱'),
                ('inc', 'INC 物品名稱代碼'),
                ('fiig', 'FIIG 識別指南'),
                ('mrc', 'MRC 物料需求代碼'),
                ('reply_table', '回應表'),
                ('fiig_inc_mrc_xref', 'FIIG-INC-MRC 對應')
            ]
            
            for table_name, description in tables_to_check:
                cursor.execute(f"SELECT COUNT(*) FROM public.{table_name};")
                count = cursor.fetchone()[0]
                self.logger.info(f"  {description:30s}: {count:>8,} 筆")
            
            cursor.close()
            conn.close()
            
            self.logger.info("=" * 60)
            return True
            
        except Exception as e:
            self.logger.error(f"❌ 驗證失敗: {e}")
            return False

    def run_import(self, start_from=0, skip_confirmation=False):
        """
        執行完整的匯入流程
        
        Args:
            start_from: 從第幾個檔案開始（0-based index）
            skip_confirmation: 是否跳過確認提示
        """
        self.logger.info("=" * 60)
        self.logger.info("  NSN 資料匯入工具（客製化版本）")
        self.logger.info(f"  目標資料庫: {self.db_config['host']}:{self.db_config['port']}/{self.db_config['dbname']}")
        self.logger.info(f"  目標 Schema: public")
        self.logger.info("=" * 60)
        
        # 測試連線
        if not self.test_connection():
            self.logger.error("❌ 連線測試失敗，終止執行")
            return False
        
        # 確認提示
        if not skip_confirmation:
            self.logger.info("\n⚠️  注意: 此操作將清除並重新匯入 public schema 的所有 NSN 資料")
            response = input("\n是否繼續？(yes/no): ").strip().lower()
            if response != 'yes':
                self.logger.info("❌ 使用者取消操作")
                return False
        
        # 開始匯入
        start_time = time.time()
        success_count = 0
        total_files = len(self.sql_files) - start_from
        
        self.logger.info(f"\n🚀 開始匯入 {total_files} 個檔案...\n")
        
        for i, filename in enumerate(self.sql_files[start_from:], start_from + 1):
            self.logger.info(f"[{i:2d}/{len(self.sql_files)}] 執行中...")
            
            if self.execute_sql_file(filename):
                success_count += 1
                self.logger.info(f"[{i:2d}/{len(self.sql_files)}] ✅ 完成\n")
            else:
                self.logger.error(f"[{i:2d}/{len(self.sql_files)}] ❌ 失敗")
                self.logger.error(f"\n⚠️  匯入在第 {i} 個檔案時失敗，是否繼續？")
                response = input("繼續執行剩餘檔案？(yes/no): ").strip().lower()
                if response != 'yes':
                    self.logger.error("使用者選擇停止執行")
                    break
        
        total_time = time.time() - start_time
        
        # 驗證結果
        self.verify_import()
        
        # 輸出摘要
        self.logger.info("\n" + "=" * 60)
        self.logger.info("🎉 資料匯入流程完成！")
        self.logger.info(f"✅ 成功執行: {success_count}/{total_files} 個檔案")
        self.logger.info(f"⏱️  總耗時: {total_time//60:.0f}分{total_time%60:.1f}秒")
        self.logger.info("=" * 60)
        
        return success_count == total_files


def main():
    """主函數"""
    import argparse
    
    parser = argparse.ArgumentParser(description='NSN 資料匯入工具')
    parser.add_argument('--host', default='localhost', help='資料庫主機')
    parser.add_argument('--port', default=5432, type=int, help='資料庫埠號')
    parser.add_argument('--database', default='sbir_equipment_db_v3', help='資料庫名稱')
    parser.add_argument('--user', default='postgres', help='使用者名稱')
    parser.add_argument('--password', default='willlin07', help='密碼')
    parser.add_argument('--start-from', default=0, type=int, help='從第幾個檔案開始（0-based）')
    parser.add_argument('--yes', action='store_true', help='跳過確認提示')
    
    args = parser.parse_args()
    
    importer = NSNDataImporter(
        db_host=args.host,
        db_port=args.port,
        db_name=args.database,
        db_user=args.user,
        db_password=args.password
    )
    
    success = importer.run_import(
        start_from=args.start_from,
        skip_confirmation=args.yes
    )
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
