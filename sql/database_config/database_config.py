#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
NSN料號申編系統 - 資料庫配置管理工具
提供統一的資料庫連線配置管理
"""

import os
import logging
import psycopg2
from psycopg2 import pool
from typing import Dict, Any

class DatabaseConfig:
    """資料庫配置管理類別"""

    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self._connection_pool = None

    def get_connection_string(
        self,
        host: str = None,
        port: int = None,
        database: str = None,
        username: str = None,
        password: str = None
    ) -> str:
        """
        從環境變數或預設值生成資料庫連線字串。
        優先順序: 函式參數 > 環境變數 > 預設值
        """
        # --- 從環境變數讀取，如果函式參數未提供 ---
        db_host = host or os.environ.get('DATABASE_HOST', 'localhost')
        db_port = port or int(os.environ.get('DATABASE_PORT', 5432))
        db_name = database or os.environ.get('DATABASE_NAME', 'nsn_database')
        db_user = username or os.environ.get('DATABASE_USER', 'postgres')
        db_pass = password or os.environ.get('DATABASE_PASSWORD', 'postgres')

        return f"postgresql://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}"

    def get_db_params(self) -> Dict[str, Any]:
        """從環境變數獲取資料庫連線參數字典"""
        return {
            "host": os.environ.get('DATABASE_HOST', 'localhost'),
            "port": int(os.environ.get('DATABASE_PORT', 5432)),
            "dbname": os.environ.get('DATABASE_NAME', 'nsn_database'),
            "user": os.environ.get('DATABASE_USER', 'postgres'),
            "password": os.environ.get('DATABASE_PASSWORD', 'postgres'),
            "options": '-c search_path=web_app,public'
        }

    def get_connection(self):
        """取得資料庫連線"""
        return psycopg2.connect(**self.get_db_params())

    def init_connection_pool(self, min_conn: int = 1, max_conn: int = 10):
        """初始化資料庫連線池"""
        try:
            self._connection_pool = psycopg2.pool.ThreadedConnectionPool(
                min_conn, max_conn, **self.get_db_params()
            )
            self.logger.info("資料庫連線池初始化成功")
        except Exception as e:
            self.logger.error(f"資料庫連線池初始化失敗: {e}")
            raise

    def get_pool_connection(self):
        """從連線池取得連線"""
        if not self._connection_pool:
            self.init_connection_pool()
        return self._connection_pool.getconn()

    def return_connection(self, conn):
        """歸還連線到連線池"""
        if self._connection_pool:
            self._connection_pool.putconn(conn)

    def test_connection(self) -> bool:
        """測試資料庫連線"""
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            cursor.close()
            conn.close()
            self.logger.info("資料庫連線測試成功")
            return True
        except Exception as e:
            self.logger.error(f"資料庫連線測試失敗: {e}")
            return False

# ==============================================================================
#  提供一個單例 (Singleton) 實例，方便全局調用
# ==============================================================================
_db_config_instance = None

def get_db_config_instance() -> "DatabaseConfig":
    global _db_config_instance
    if _db_config_instance is None:
        _db_config_instance = DatabaseConfig()
    return _db_config_instance

# 主執行塊，用於測試
if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    
    print("\n===== 測試統一資料庫配置管理 (從環境變數) =====")
    
    # 為了測試，可以手動設定環境變數
    # os.environ['DATABASE_HOST'] = 'localhost'
    
    db_manager = get_db_config_instance()
    
    print("\n--- 1. 取得連線字串 ---")
    conn_str = db_manager.get_connection_string()
    print(f"連線字串: {conn_str}")
    
    print("\n--- 2. 測試直接連線 ---")
    db_manager.test_connection()
        
    print("\n===== 測試完成 =====")
