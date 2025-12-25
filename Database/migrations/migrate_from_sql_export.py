"""
完整資料遷移腳本
===============
將 20251219.sql 匯出檔案中的資料匯入到 sbir_equipment_db_v3 資料庫

資料表對照：
- SQL: web_app.users → DB: web_app."User"
- SQL: web_app.applications → DB: web_app.application  
- SQL: web_app.user_sessions → DB: web_app.usersession
- SQL: web_app.application_attachments → DB: web_app.applicationattachment

欄位對照：
- created_at → date_created
- updated_at → date_updated

注意: applications 表的 schema 已變更，需要欄位映射

作者: 自動生成
日期: 2025-12-26
"""

import psycopg2
import re
import codecs
import sys
from datetime import datetime

# ==================== 設定區 ====================
DB_CONFIG = {
    "host": "localhost",
    "database": "sbir_equipment_db_v3",
    "user": "postgres",
    "password": "willlin07"
}

SQL_FILE = r"C:\github\SBIR\Database\export\20251219.sql"

# 表格對照 (SQL表名 -> DB表名)
TABLE_MAPPING = {
    "web_app.users": 'web_app."User"',
    "web_app.applications": "web_app.application",
    "web_app.user_sessions": "web_app.usersession",
    "web_app.application_attachments": "web_app.applicationattachment"
}

# 欄位對照 (舊名 -> 新名)
COLUMN_MAPPING = {
    "created_at": "date_created",
    "updated_at": "date_updated"
}

# DB application 表的有效欄位
DB_APPLICATION_COLUMNS = [
    "id", "user_id", "item_uuid", "date_created", "date_updated", "deleted_at",
    "form_serial_number", "system_code", "mrc_data", "applicant_unit", 
    "contact_info", "apply_date", "official_nsn_stamp", "official_nsn_final",
    "nsn_filled_at", "closed_at", "status", "sub_status", "created_at", 
    "updated_at", "nsn_filled_by", "closed_by"
]

# SQL applications 欄位順序 (從 SQL 檔案中取得)
SQL_APPLICATION_COLUMNS = [
    "id", "user_id", "form_serial_number", "part_number", "english_name",
    "chinese_name", "inc_code", "fiig_code", "status", "sub_status",
    "created_at", "updated_at", "deleted_at", "accounting_unit_code",
    "issue_unit", "unit_price", "spec_indicator", "unit_pack_quantity",
    "storage_life_months", "storage_life_action_code", "storage_type_code",
    "secrecy_code", "expendability_code", "repairability_code",
    "manufacturability_code", "source_code", "category_code", "system_code",
    "pn_acquisition_level", "pn_acquisition_source", "manufacturer",
    "part_number_reference", "ship_type", "cid_no", "model_type",
    "equipment_name", "usage_location", "quantity_per_unit", "mrc_data",
    "document_reference", "manufacturer_name", "agent_name", "applicant_unit",
    "contact_info", "apply_date", "official_nsn_stamp", "official_nsn_final",
    "nsn_filled_at", "nsn_filled_by", "closed_at", "closed_by"
]

# 需要保留的欄位 (在兩個 schema 中都存在)
COMMON_APP_COLUMNS = [
    "id", "user_id", "form_serial_number", "status", "sub_status",
    "created_at", "updated_at", "deleted_at", "system_code", "mrc_data",
    "applicant_unit", "contact_info", "apply_date", "official_nsn_stamp",
    "official_nsn_final", "nsn_filled_at", "nsn_filled_by", "closed_at", "closed_by"
]

# ==================== 工具函數 ====================
def log(msg, level="INFO"):
    """輸出日誌"""
    timestamp = datetime.now().strftime("%H:%M:%S")
    print(f"[{timestamp}] [{level}] {msg}")

def connect_db():
    """連接資料庫"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.set_client_encoding('UTF8')
        return conn
    except Exception as e:
        log(f"資料庫連接失敗: {e}", "ERROR")
        sys.exit(1)

def read_sql_file():
    """讀取 SQL 檔案"""
    log(f"讀取 SQL 檔案: {SQL_FILE}")
    try:
        with codecs.open(SQL_FILE, 'r', encoding='utf-8') as f:
            content = f.read()
        log(f"SQL 檔案大小: {len(content):,} 字元")
        return content
    except Exception as e:
        log(f"讀取 SQL 檔案失敗: {e}", "ERROR")
        sys.exit(1)

def extract_inserts(content, sql_table_name):
    """從 SQL 內容中提取 INSERT 語句"""
    # 匹配 INSERT INTO table (cols) VALUES (vals);
    pattern = rf"INSERT INTO {re.escape(sql_table_name)} \(([^)]+)\) VALUES \((.+?)\);"
    matches = list(re.finditer(pattern, content, re.DOTALL))
    return matches

def transform_columns(columns_str):
    """轉換欄位名稱"""
    for old_name, new_name in COLUMN_MAPPING.items():
        columns_str = columns_str.replace(old_name, new_name)
    return columns_str

def parse_sql_values(values_str):
    """解析 SQL VALUES 字串，返回值列表"""
    values = []
    current = ""
    in_string = False
    string_char = None
    paren_depth = 0
    i = 0
    
    while i < len(values_str):
        char = values_str[i]
        
        if not in_string:
            if char in ("'",):
                in_string = True
                string_char = char
                current += char
            elif char == '(':
                paren_depth += 1
                current += char
            elif char == ')':
                paren_depth -= 1
                current += char
            elif char == ',' and paren_depth == 0:
                values.append(current.strip())
                current = ""
            else:
                current += char
        else:
            current += char
            if char == string_char:
                # 檢查是否為轉義的引號
                if i + 1 < len(values_str) and values_str[i + 1] == string_char:
                    current += values_str[i + 1]
                    i += 1
                else:
                    in_string = False
                    string_char = None
        i += 1
    
    if current.strip():
        values.append(current.strip())
    
    return values

# ==================== 清除資料 ====================
def clear_all_data(conn):
    """清除所有現有資料（按正確順序）"""
    log("=" * 50)
    log("開始清除現有資料...")
    cursor = conn.cursor()
    
    # 按外鍵依賴順序刪除
    tables_to_clear = [
        "web_app.applicationattachment",
        "web_app.usersession", 
        "web_app.application",
        'web_app."User"'
    ]
    
    for table in tables_to_clear:
        try:
            cursor.execute(f"DELETE FROM {table}")
            deleted = cursor.rowcount
            log(f"  清除 {table}: {deleted} 筆")
        except Exception as e:
            log(f"  清除 {table} 失敗: {e}", "ERROR")
            conn.rollback()
            return False
    
    conn.commit()
    log("資料清除完成")
    return True

# ==================== 匯入函數 ====================
def import_users(conn, content):
    """匯入 Users 資料"""
    log("=" * 50)
    log("匯入 Users...")
    cursor = conn.cursor()
    
    matches = extract_inserts(content, "web_app.users")
    log(f"找到 {len(matches)} 筆 Users 記錄")
    
    imported = 0
    errors = 0
    
    for match in matches:
        try:
            columns_str = transform_columns(match.group(1))
            values_str = match.group(2)
            
            insert_sql = f'INSERT INTO web_app."User" ({columns_str}) VALUES ({values_str})'
            cursor.execute(insert_sql)
            imported += 1
        except Exception as e:
            errors += 1
            log(f"  錯誤: {str(e)[:100]}", "ERROR")
    
    conn.commit()
    log(f"Users 匯入完成: 成功 {imported}, 錯誤 {errors}")
    return imported, errors

def import_applications(conn, content):
    """匯入 Applications 資料 (需要欄位映射)"""
    log("=" * 50)
    log("匯入 Applications (需要欄位映射)...")
    cursor = conn.cursor()
    
    matches = extract_inserts(content, "web_app.applications")
    log(f"找到 {len(matches)} 筆 Applications 記錄")
    
    imported = 0
    errors = 0
    
    for match in matches:
        try:
            columns_str = match.group(1)
            values_str = match.group(2)
            
            # 解析欄位和值
            sql_columns = [c.strip() for c in columns_str.split(',')]
            sql_values = parse_sql_values(values_str)
            
            # 只保留共同欄位
            new_columns = []
            new_values = []
            
            for i, col in enumerate(sql_columns):
                if col in COMMON_APP_COLUMNS:
                    # 轉換欄位名稱
                    new_col = COLUMN_MAPPING.get(col, col)
                    new_columns.append(new_col)
                    new_values.append(sql_values[i])
            
            # 建構插入語句
            cols_str = ", ".join(new_columns)
            vals_str = ", ".join(new_values)
            
            insert_sql = f"INSERT INTO web_app.application ({cols_str}) VALUES ({vals_str})"
            cursor.execute(insert_sql)
            imported += 1
            
        except Exception as e:
            errors += 1
            log(f"  錯誤: {str(e)[:150]}", "ERROR")
            conn.rollback()
    
    conn.commit()
    log(f"Applications 匯入完成: 成功 {imported}, 錯誤 {errors}")
    return imported, errors

def import_user_sessions(conn, content):
    """匯入 User Sessions 資料"""
    log("=" * 50)
    log("匯入 User Sessions...")
    cursor = conn.cursor()
    
    matches = extract_inserts(content, "web_app.user_sessions")
    log(f"找到 {len(matches)} 筆 User Sessions 記錄")
    
    imported = 0
    errors = 0
    
    for match in matches:
        try:
            columns_str = transform_columns(match.group(1))
            values_str = match.group(2)
            
            insert_sql = f"INSERT INTO web_app.usersession ({columns_str}) VALUES ({values_str})"
            cursor.execute(insert_sql)
            imported += 1
        except Exception as e:
            errors += 1
            log(f"  錯誤: {str(e)[:100]}", "ERROR")
    
    conn.commit()
    log(f"User Sessions 匯入完成: 成功 {imported}, 錯誤 {errors}")
    return imported, errors

def import_attachments(conn, content):
    """匯入 Application Attachments 資料"""
    log("=" * 50)
    log("匯入 Application Attachments...")
    cursor = conn.cursor()
    
    matches = extract_inserts(content, "web_app.application_attachments")
    log(f"找到 {len(matches)} 筆 Attachments 記錄")
    
    imported = 0
    errors = 0
    
    for match in matches:
        try:
            columns_str = transform_columns(match.group(1))
            values_str = match.group(2)
            
            insert_sql = f"INSERT INTO web_app.applicationattachment ({columns_str}) VALUES ({values_str})"
            cursor.execute(insert_sql)
            imported += 1
        except Exception as e:
            errors += 1
            log(f"  錯誤: {str(e)[:100]}", "ERROR")
    
    conn.commit()
    log(f"Attachments 匯入完成: 成功 {imported}, 錯誤 {errors}")
    return imported, errors

# ==================== 驗證函數 ====================
def verify_data(conn):
    """驗證匯入的資料"""
    log("=" * 50)
    log("驗證匯入結果...")
    cursor = conn.cursor()
    
    tables = [
        ('web_app."User"', "Users"),
        ("web_app.application", "Applications"),
        ("web_app.usersession", "User Sessions"),
        ("web_app.applicationattachment", "Attachments")
    ]
    
    results = {}
    for table, name in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        results[name] = count
        log(f"  {name}: {count} 筆")
    
    return results

# ==================== 主程式 ====================
def main():
    """主程式"""
    log("=" * 50)
    log("資料遷移腳本 - 開始執行")
    log("=" * 50)
    
    # 連接資料庫
    conn = connect_db()
    log("資料庫連接成功")
    
    # 讀取 SQL 檔案
    content = read_sql_file()
    
    # 清除現有資料
    if not clear_all_data(conn):
        log("清除資料失敗，終止執行", "ERROR")
        conn.close()
        sys.exit(1)
    
    # 依序匯入資料（按外鍵依賴順序）
    total_imported = 0
    total_errors = 0
    
    # 1. Users (無外鍵依賴)
    imported, errors = import_users(conn, content)
    total_imported += imported
    total_errors += errors
    
    # 2. Applications (依賴 Users)
    imported, errors = import_applications(conn, content)
    total_imported += imported
    total_errors += errors
    
    # 3. User Sessions (依賴 Users)
    imported, errors = import_user_sessions(conn, content)
    total_imported += imported
    total_errors += errors
    
    # 4. Attachments (依賴 Applications, Users)
    imported, errors = import_attachments(conn, content)
    total_imported += imported
    total_errors += errors
    
    # 驗證結果
    results = verify_data(conn)
    
    # 關閉連接
    conn.close()
    
    # 輸出總結
    log("=" * 50)
    log("遷移完成總結")
    log("=" * 50)
    log(f"總匯入: {total_imported} 筆")
    log(f"總錯誤: {total_errors} 筆")
    log("")
    log("各表記錄數:")
    for name, count in results.items():
        log(f"  - {name}: {count}")
    
    if total_errors == 0:
        log("")
        log("✅ 遷移成功完成！", "SUCCESS")
    else:
        log("")
        log("⚠️ 遷移完成但有錯誤，請檢查上方日誌", "WARNING")
    
    return total_errors == 0

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
