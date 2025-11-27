#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EMU3000 維修物料清單資料導入腳本
用途: 將 EMU3000 Excel 檔案導入 sbir_equipment_db_v2 資料庫
作者: SBIR 專案團隊
日期: 2025-11-24

使用方法:
1. 先執行 alter_database_for_emu3000.sql 調整資料庫結構
2. 執行本腳本: python import_emu3000_data.py
"""

import pandas as pd
import psycopg2
import os
import uuid
import logging

# ============================================
# 設定日誌
# ============================================

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ============================================
# 資料庫連線設定
# ============================================

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v2',
    'user': 'postgres',
    'password': 'willlin07'
}

# ============================================
# 主程式 - 簡化版（示範用）
# ============================================

def main():
    """主程式 - 測試資料庫連線並顯示資訊"""
    logger.info('EMU3000 資料導入程式（簡化版）')

    try:
        # 連接資料庫
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        logger.info('資料庫連線成功！')

        # 檢查是否已經調整資料庫結構
        cursor.execute("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'Item' AND column_name = 'project_code'
        """)

        if cursor.fetchone():
            logger.info('✓ 資料庫結構已更新（project_code 欄位存在）')
        else:
            logger.warning('✗ 資料庫結構尚未更新，請先執行 alter_database_for_emu3000.sql')

        # 統計現有 EMU3000 資料
        cursor.execute("""
            SELECT COUNT(*) FROM "Item" WHERE project_code = 'EMU3000'
        """)
        count = cursor.fetchone()[0]
        logger.info(f'現有 EMU3000 品項數量: {count}')

        cursor.close()
        conn.close()

    except Exception as e:
        logger.error(f'錯誤: {e}')

if __name__ == '__main__':
    main()
