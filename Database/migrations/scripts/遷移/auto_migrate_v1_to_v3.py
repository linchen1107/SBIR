#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Database Migration Script
功能:
  1. 解析 20251219.sql 中的 INSERT 語句
  2. 根據欄位映射規則自動轉換
  3. 生成新的遷移 SQL 腳本 (migrate_v1_to_v3.sql)
  4. 支援 item 表去重 (多個 application 可共用同一個 item)

主要改進:
  - item 去重邏輯，避免 UNIQUE constraint 違反
         原始 126 筆 applications → 42 個不同 items
         多個申編單可以引用同一個品項 (符合業務邏輯)

使用方法:
  執行後會在同目錄生成 migrate_v1_to_v3.sql，然後使用以下命令匯入：
  
  $env:PGPASSWORD='willlin07'
  & "C:\\Program Files\\PostgreSQL\\16\\bin\\psql.exe" -h localhost -p 5432 `
    -U postgres -d sbir_equipment_db_v3 -f migrate_v1_to_v3.sql

遷移表格對照:
  Part 1: users → User (18 欄位)
  Part 2: applications → 8 個表 (複雜拆分，支援去重)
    - item (品項主檔，去重)
    - item_material_ext (料件屬性)
    - item_equipment_ext (裝備屬性)
    - supplier (廠商，去重)
    - item_number_xref (零件號關聯)
    - technicaldocument (技術文件，去重)
    - item_document_xref (品項文件關聯)
    - application (申編單，保留 20 欄位)
  Part 3: user_sessions → usersession (9 欄位)
  Part 4: application_attachments → applicationattachment (12 欄位)
"""

import re
import sys
import uuid
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from collections import defaultdict

# =====================================================================
# 欄位映射配置
# =====================================================================

# Part 1: users → User (18 個欄位)
USER_FIELD_MAPPING = {
    'id': 'id',
    'username': 'username',
    'email': 'email',
    'password_hash': 'password_hash',
    'english_code': 'english_code',
    'full_name': 'full_name',
    'department': 'department',
    'position': 'position',
    'phone': 'phone',
    'role': 'role',
    'is_active': 'is_active',
    'is_verified': 'is_verified',
    'email_verified_at': 'email_verified_at',
    'last_login_at': 'last_login_at',
    'failed_login_attempts': 'failed_login_attempts',
    'locked_until': 'locked_until',
    'created_at': 'date_created',
    'updated_at': 'date_updated',
}

# Part 3: user_sessions → usersession (9 個欄位)
SESSION_FIELD_MAPPING = {
    'session_id': 'session_id',
    'user_id': 'user_id',
    'ip_address': 'ip_address',
    'user_agent': 'user_agent',
    'is_active': 'is_active',
    'remember_me': 'remember_me',
    'expires_at': 'expires_at',
    'created_at': 'date_created',
    'last_activity_at': 'last_activity_at',
}

# Part 4: application_attachments → applicationattachment (12 個欄位)
ATTACHMENT_FIELD_MAPPING = {
    'id': 'id',
    'application_id': 'application_id',
    'user_id': 'user_id',
    'file_data': 'file_data',
    'filename': 'filename',
    'original_filename': 'original_filename',
    'mimetype': 'mimetype',
    'file_type': 'file_type',
    'page_selection': 'page_selection',
    'sort_order': 'sort_order',
    'created_at': 'date_created',
    'updated_at': 'date_updated',
}

# Part 2: applications → application (20 個欄位保留)
APPLICATION_KEEP_FIELDS = {
    'id': 'id',
    'user_id': 'user_id',
    'form_serial_number': 'form_serial_number',
    'status': 'status',
    'sub_status': 'sub_status',
    'system_code': 'system_code',
    'mrc_data': 'mrc_data',
    'applicant_unit': 'applicant_unit',
    'contact_info': 'contact_info',
    'apply_date': 'apply_date',
    'official_nsn_stamp': 'official_nsn_stamp',
    'official_nsn_final': 'official_nsn_final',
    'nsn_filled_at': 'nsn_filled_at',
    'nsn_filled_by': 'nsn_filled_by',
    'closed_at': 'closed_at',
    'closed_by': 'closed_by',
    'created_at': 'date_created',
    'updated_at': 'date_updated',
    'deleted_at': 'deleted_at',
}

# Part 2: applications → item (4 個欄位)
APPLICATION_TO_ITEM_FIELDS = ['part_number', 'english_name', 'chinese_name']

# Part 2: applications → item_material_ext (16 個欄位)
APPLICATION_TO_MATERIAL_FIELDS = [
    'inc_code', 'fiig_code', 'accounting_unit_code', 'issue_unit', 'unit_price',
    'spec_indicator', 'unit_pack_quantity', 'storage_life_months', 
    'storage_life_action_code', 'storage_type_code', 'secrecy_code',
    'expendability_code', 'repairability_code', 'manufacturability_code',
    'source_code', 'category_code'
]

# Part 2: applications → item_equipment_ext (5 個欄位)
APPLICATION_TO_EQUIPMENT_FIELDS = [
    'ship_type', 'model_type', 'usage_location', 'quantity_per_unit'
]

# Part 2: applications → supplier (3 個欄位)
APPLICATION_TO_SUPPLIER_FIELDS = [
    'manufacturer', 'manufacturer_name', 'agent_name'
]

# Part 2: applications → item_number_xref (3 個欄位)
APPLICATION_TO_NUMBER_XREF_FIELDS = [
    'part_number_reference', 'pn_acquisition_level', 'pn_acquisition_source'
]

# Part 2: applications → technicaldocument (1 個欄位)
APPLICATION_TO_DOCUMENT_FIELDS = ['document_reference']


# =====================================================================
# SQL 解析函數
# =====================================================================

def parse_insert_statement(line: str) -> Optional[Tuple[str, List[str], List[str]]]:
    """
    解析單行 INSERT 語句
    
    參數:
        line: INSERT 語句字串
        
    返回:
        (表名, 欄位列表, 值列表) 或 None
    """
    # 匹配: INSERT INTO schema.table (col1, col2, ...) VALUES (val1, val2, ...);
    pattern = r'INSERT INTO\s+(\w+)\.(\w+)\s*\(([^)]+)\)\s*VALUES\s*\((.+)\);'
    match = re.match(pattern, line, re.IGNORECASE | re.DOTALL)
    
    if not match:
        return None
    
    schema = match.group(1)
    table = match.group(2)
    columns_str = match.group(3)
    values_str = match.group(4)
    
    # 解析欄位名
    columns = [col.strip() for col in columns_str.split(',')]
    
    # 解析值 (需要處理複雜情況: 字串、NULL、JSON、BYTEA 等)
    values = parse_values(values_str)
    
    return (table, columns, values)


def parse_values(values_str: str) -> List[str]:
    """
    解析 VALUES 子句中的值
    
    處理:
    - 單引號字串 (包含轉義)
    - NULL
    - 數字
    - uuid::uuid
    - timestamp::timestamp
    - json::json
    - bytea (\\x...)
    """
    values = []
    current = ""
    in_string = False
    escape_next = False
    paren_depth = 0  # 追蹤括號深度 (用於 JSON)
    
    i = 0
    while i < len(values_str):
        char = values_str[i]
        
        if escape_next:
            current += char
            escape_next = False
            i += 1
            continue
        
        if char == '\\':
            current += char
            escape_next = True
            i += 1
            continue
        
        if char == "'" and not in_string:
            in_string = True
            current += char
        elif char == "'" and in_string:
            # 檢查是否是單引號轉義 ('')
            if i + 1 < len(values_str) and values_str[i + 1] == "'":
                current += "''"
                i += 1
            else:
                in_string = False
                current += char
        elif in_string:
            current += char
        elif char in '({[':
            paren_depth += 1
            current += char
        elif char in ')}]':
            paren_depth -= 1
            current += char
        elif char == ',' and paren_depth == 0:
            # 遇到分隔符,保存當前值
            values.append(current.strip())
            current = ""
        else:
            current += char
        
        i += 1
    
    # 添加最後一個值
    if current.strip():
        values.append(current.strip())
    
    return values


def create_insert_statement(table: str, columns: List[str], values: List[str]) -> str:
    """
    生成 INSERT 語句
    
    參數:
        table: 表名
        columns: 欄位列表
        values: 值列表
        
    返回:
        INSERT 語句字串
    """
    columns_str = ', '.join(columns)
    values_str = ', '.join(values)
    
    return f"INSERT INTO web_app.{table} ({columns_str}) VALUES ({values_str});"


# =====================================================================
# 轉換函數 - Part 1, 3, 4 (映射)
# =====================================================================

def convert_users(columns: List[str], values: List[str]) -> str:
    """
    轉換 users → User
    """
    # 建立欄位值映射
    col_value_map = dict(zip(columns, values))
    
    # 生成新欄位和值
    new_columns = []
    new_values = []
    
    for old_col, new_col in USER_FIELD_MAPPING.items():
        if old_col in col_value_map:
            new_columns.append(new_col)
            value = col_value_map[old_col]
            
            # 特殊處理: phone 長度限制 (50→20)
            if old_col == 'phone' and value != 'NULL':
                # 如果是字串,截斷至 20 字元
                if value.startswith("'"):
                    phone_str = value.strip("'")
                    if len(phone_str) > 20:
                        phone_str = phone_str[:20]
                    value = f"'{phone_str}'"
            
            new_values.append(value)
    
    return create_insert_statement('"User"', new_columns, new_values)


def convert_user_sessions(columns: List[str], values: List[str]) -> str:
    """
    轉換 user_sessions → usersession
    """
    col_value_map = dict(zip(columns, values))
    
    new_columns = []
    new_values = []
    
    for old_col, new_col in SESSION_FIELD_MAPPING.items():
        if old_col in col_value_map:
            new_columns.append(new_col)
            new_values.append(col_value_map[old_col])
    
    return create_insert_statement('usersession', new_columns, new_values)


def convert_application_attachments(columns: List[str], values: List[str]) -> str:
    """
    轉換 application_attachments → applicationattachment
    """
    col_value_map = dict(zip(columns, values))
    
    new_columns = []
    new_values = []
    
    for old_col, new_col in ATTACHMENT_FIELD_MAPPING.items():
        if old_col in col_value_map:
            new_columns.append(new_col)
            new_values.append(col_value_map[old_col])
    
    return create_insert_statement('applicationattachment', new_columns, new_values)


# =====================================================================
# 轉換函數 - Part 2 (application 拆分)
# =====================================================================

def convert_applications_complex(columns: List[str], values: List[str], item_map: Dict[str, str]) -> Dict[str, List[str]]:
    """
    轉換 applications → 7 個表 (複雜拆分)
    
    參數:
        columns: 欄位列表
        values: 值列表
        item_map: item_code -> item_uuid 的映射表（用於去重）
    
    返回:
        {
            'item': [INSERT 語句],
            'item_material_ext': [INSERT 語句],
            'item_equipment_ext': [INSERT 語句],
            'supplier': [INSERT 語句],
            'item_number_xref': [INSERT 語句],
            'technicaldocument': [INSERT 語句],
            'item_document_xref': [INSERT 語句],
            'application': [INSERT 語句],
        }
    """
    col_value_map = dict(zip(columns, values))
    
    # 取得 item_code
    item_code = col_value_map.get('part_number', "''")
    if item_code == "''" and 'cid_no' in col_value_map:
        item_code = col_value_map['cid_no']
    
    # 去除引號以便作為 key
    item_code_key = item_code.strip("'")
    
    # 檢查是否已存在，如果存在則重用 UUID
    if item_code_key and item_code_key in item_map:
        item_uuid = item_map[item_code_key]
        create_new_item = False
    else:
        # 生成新的 UUID
        item_uuid = str(uuid.uuid4())
        if item_code_key:
            item_map[item_code_key] = item_uuid
        create_new_item = True
    
    # 提取時間戳
    created_at = col_value_map.get('created_at', 'NULL')
    updated_at = col_value_map.get('updated_at', 'NULL')
    
    result = {}
    
    # ===== 1. item 表 (只有在新建時才插入) =====
    if create_new_item:
        item_columns = ['item_uuid', 'item_code', 'item_name_en', 'item_name_zh', 
                        'item_type', 'uom', 'status', 'date_created', 'date_updated']
        item_values = [
            f"'{item_uuid}'::uuid",
            item_code,
            col_value_map.get('english_name', "''"),
            col_value_map.get('chinese_name', "''"),
            "'RM'",  # 預設類型
            col_value_map.get('issue_unit', "'EA'"),
            "'Active'",  # 預設狀態
            created_at,
            updated_at
        ]
        result['item'] = [create_insert_statement('item', item_columns, item_values)]
    else:
        result['item'] = []  # 已存在，不插入
    
    # ===== 2. item_material_ext 表 (只有在新建 item 時才插入) =====
    if create_new_item:
        material_columns = ['item_uuid'] + APPLICATION_TO_MATERIAL_FIELDS + ['date_created', 'date_updated']
        material_values = [f"'{item_uuid}'::uuid"]
        
        for field in APPLICATION_TO_MATERIAL_FIELDS:
            material_values.append(col_value_map.get(field, 'NULL'))
        
        material_values.extend([created_at, updated_at])
        result['item_material_ext'] = [create_insert_statement('item_material_ext', material_columns, material_values)]
    else:
        result['item_material_ext'] = []
    
    # ===== 3. item_equipment_ext 表 (只有在新建 item 時才插入) =====
    if create_new_item:
        equipment_columns = ['item_uuid', 'ship_type', 'equipment_type', 'usage_location', 
                             'installation_qty', 'date_created', 'date_updated']
        equipment_values = [
            f"'{item_uuid}'::uuid",
            col_value_map.get('ship_type', 'NULL'),
            col_value_map.get('model_type', 'NULL'),  # model_type → equipment_type
            col_value_map.get('usage_location', 'NULL'),
            col_value_map.get('quantity_per_unit', 'NULL'),
            created_at,
            updated_at
        ]
        result['item_equipment_ext'] = [create_insert_statement('item_equipment_ext', equipment_columns, equipment_values)]
    else:
        result['item_equipment_ext'] = []
    
    # ===== 4. supplier 表 (需要去重) =====
    supplier_code = col_value_map.get('manufacturer', 'NULL')
    if supplier_code != 'NULL':
        supplier_columns = ['supplier_code', 'supplier_name_en', 'supplier_name_zh', 
                           'agent_name', 'date_created', 'date_updated']
        supplier_values = [
            supplier_code,
            supplier_code,  # supplier_name_en 使用 code
            col_value_map.get('manufacturer_name', 'NULL'),
            col_value_map.get('agent_name', 'NULL'),
            created_at,
            updated_at
        ]
        result['supplier'] = [create_insert_statement('supplier', supplier_columns, supplier_values)]
    else:
        result['supplier'] = []
    
    # ===== 5. item_number_xref 表 =====
    if col_value_map.get('part_number_reference', 'NULL') != 'NULL':
        xref_columns = ['item_uuid', 'supplier_id', 'part_number_reference', 
                        'pn_acquisition_level', 'pn_acquisition_source', 
                        'is_primary', 'date_created', 'date_updated']
        xref_values = [
            f"'{item_uuid}'::uuid",
            '(SELECT supplier_id FROM web_app.supplier WHERE supplier_code = ' + supplier_code + ')',
            col_value_map.get('part_number_reference', 'NULL'),
            col_value_map.get('pn_acquisition_level', 'NULL'),
            col_value_map.get('pn_acquisition_source', 'NULL'),
            'true',
            created_at,
            updated_at
        ]
        result['item_number_xref'] = [create_insert_statement('item_number_xref', xref_columns, xref_values)]
    else:
        result['item_number_xref'] = []
    
    # ===== 6. technicaldocument 表 (需要去重) =====
    document_ref = col_value_map.get('document_reference', 'NULL')
    if document_ref != 'NULL':
        doc_columns = ['document_reference', 'date_created', 'date_updated']
        doc_values = [document_ref, created_at, updated_at]
        result['technicaldocument'] = [create_insert_statement('technicaldocument', doc_columns, doc_values)]
    else:
        result['technicaldocument'] = []
    
    # ===== 7. item_document_xref 表 =====
    if document_ref != 'NULL':
        doc_xref_columns = ['item_uuid', 'document_id', 'date_created', 'date_updated']
        doc_xref_values = [
            f"'{item_uuid}'::uuid",
            '(SELECT document_id FROM web_app.technicaldocument WHERE document_reference = ' + document_ref + ')',
            created_at,
            updated_at
        ]
        result['item_document_xref'] = [create_insert_statement('item_document_xref', doc_xref_columns, doc_xref_values)]
    else:
        result['item_document_xref'] = []
    
    # ===== 8. application 表 (保留欄位) =====
    app_columns = list(APPLICATION_KEEP_FIELDS.values()) + ['item_uuid']
    app_values = []
    
    for old_col in APPLICATION_KEEP_FIELDS.keys():
        app_values.append(col_value_map.get(old_col, 'NULL'))
    
    # 把 item_uuid 加到最後 (與 app_columns 順序一致)
    app_values.append(f"'{item_uuid}'::uuid")
    
    result['application'] = [create_insert_statement('application', app_columns, app_values)]
    
    return result


# =====================================================================
# 主處理函數
# =====================================================================

def process_sql_file(input_file: Path, output_file: Path):
    """
    處理 SQL 檔案,轉換並輸出新的遷移腳本
    
    參數:
        input_file: 輸入檔案路徑 (20251219.sql)
        output_file: 輸出檔案路徑 (migrate_v1_to_v3_generated.sql)
    """
    print(f"開始處理: {input_file}")
    print(f"輸出至: {output_file}")
    
    # 統計
    stats = {
        'users': 0,
        'user_sessions': 0,
        'application_attachments': 0,
        'applications': 0,
        'errors': 0
    }
    
    # 儲存轉換結果
    users_sqls = []
    sessions_sqls = []
    attachments_sqls = []
    applications_parts = defaultdict(list)
    
    # 用於去重 (item, supplier, technicaldocument)
    item_map = {}  # part_number -> item_uuid 的映射
    supplier_set = set()
    document_set = set()
    
    # 讀取並處理檔案
    try:
        # 讀取整個檔案內容
        with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # 使用正則表達式提取所有 INSERT 語句
        # 匹配: INSERT INTO schema.table (...) VALUES (...);
        pattern = r'INSERT INTO\s+(\w+)\.(\w+)\s*\(([^)]+)\)\s*VALUES\s*\((.+?)\);'
        matches = re.finditer(pattern, content, re.IGNORECASE | re.DOTALL)
        
        for match in matches:
            schema = match.group(1)
            table = match.group(2)
            columns_str = match.group(3)
            values_str = match.group(4)
            
            # 解析欄位名
            columns = [col.strip() for col in columns_str.split(',')]
            
            # 解析值
            values = parse_values(values_str)
            
            # 根據表名進行轉換
            try:
                if table == 'users':
                    users_sqls.append(convert_users(columns, values))
                    stats['users'] += 1
                
                elif table == 'user_sessions':
                    sessions_sqls.append(convert_user_sessions(columns, values))
                    stats['user_sessions'] += 1
                
                elif table == 'application_attachments':
                    attachments_sqls.append(convert_application_attachments(columns, values))
                    stats['application_attachments'] += 1
                
                elif table == 'applications':
                    result = convert_applications_complex(columns, values, item_map)
                    
                    # 合併結果
                    for key, sqls in result.items():
                        if key == 'supplier':
                            # 去重 supplier
                            for sql in sqls:
                                if sql not in supplier_set:
                                    supplier_set.add(sql)
                                    applications_parts[key].append(sql)
                        elif key == 'technicaldocument':
                            # 去重 technicaldocument
                            for sql in sqls:
                                if sql not in document_set:
                                    document_set.add(sql)
                                    applications_parts[key].append(sql)
                        else:
                            applications_parts[key].extend(sqls)
                    
                    stats['applications'] += 1
                
                # 定期輸出進度
                total_records = stats['users'] + stats['user_sessions'] + stats['application_attachments'] + stats['applications']
                if total_records % 100 == 0 and total_records > 0:
                    print(f"已處理: users={stats['users']}, sessions={stats['user_sessions']}, "
                          f"attachments={stats['application_attachments']}, applications={stats['applications']}")
            
            except Exception as e:
                print(f"錯誤: {e}")
                print(f"  表: {table}")
                print(f"  欄位數: {len(columns)}, 值數: {len(values)}")
                stats['errors'] += 1
    
    except FileNotFoundError:
        print(f"錯誤: 找不到檔案 {input_file}")
        return
    except Exception as e:
        print(f"處理檔案時發生錯誤: {e}")
        return
    
    # ===== 寫入輸出檔案 =====
    print("\n正在生成輸出檔案...")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        # 寫入標題
        f.write("""-- =====================================================================
-- 檔案名稱: migrate_v1_to_v3.sql
-- 用途: 自動生成的資料遷移腳本 (V1.0 → V3.2)
-- 來源: C:/github/SBIR/Database/export/20251219.sql
-- 目標: 新資料庫 sbir_equipment_db_v3 (V3.2) - web_app schema
-- 生成工具: auto_migrate_v1_to_v3.py V2.0
-- 生成日期: 2025-12-29
-- 
-- 重要特性:
--   ✓ item 表自動去重 (126 筆 applications → 42 個不同 items)
--   ✓ 多個申編單共用同一個品項 (例如: 4320YETL 被 18 個申編單使用)
--   ✓ supplier 和 technicaldocument 自動去重
--   ✓ 保持外鍵關聯完整性
-- 
-- 匯入方法:
--   $env:PGPASSWORD='your_password'
--   & "C:\\Program Files\\PostgreSQL\\16\\bin\\psql.exe" -h localhost -p 5432 `
--     -U postgres -d sbir_equipment_db_v3 -f migrate_v1_to_v3.sql
-- =====================================================================

SET client_encoding = 'UTF8';
SET search_path TO web_app, public;

""")
        
        # Part 1: User
        f.write(f"""-- =====================================================================
-- Part 1: 遷移 User 表 ({stats['users']} 筆記錄)
-- =====================================================================

""")
        for sql in users_sqls:
            f.write(sql + "\n")
        
        # Part 2: applications (分 8 個子部分)
        f.write(f"""
-- =====================================================================
-- Part 2: 遷移 applications 表 ({stats['applications']} 筆記錄)
-- =====================================================================

""")
        
        # 2.1: item
        f.write(f"""-- ═══════════════════════════════════════════════════════════════════════
-- Part 2.1: 插入 item 表 ({len(applications_parts['item'])} 筆)
-- ═══════════════════════════════════════════════════════════════════════

""")
        for sql in applications_parts['item']:
            f.write(sql + "\n")
        
        # 2.2: item_material_ext
        f.write(f"""
-- ═══════════════════════════════════════════════════════════════════════
-- Part 2.2: 插入 item_material_ext 表 ({len(applications_parts['item_material_ext'])} 筆)
-- ═══════════════════════════════════════════════════════════════════════

""")
        for sql in applications_parts['item_material_ext']:
            f.write(sql + "\n")
        
        # 2.3: item_equipment_ext
        f.write(f"""
-- ═══════════════════════════════════════════════════════════════════════
-- Part 2.3: 插入 item_equipment_ext 表 ({len(applications_parts['item_equipment_ext'])} 筆)
-- ═══════════════════════════════════════════════════════════════════════

""")
        for sql in applications_parts['item_equipment_ext']:
            f.write(sql + "\n")
        
        # 2.4: supplier
        f.write(f"""
-- ═══════════════════════════════════════════════════════════════════════
-- Part 2.4: 插入 supplier 表 ({len(applications_parts['supplier'])} 筆,已去重)
-- ═══════════════════════════════════════════════════════════════════════

""")
        for sql in applications_parts['supplier']:
            f.write(sql + "\n")
        
        # 2.5: item_number_xref
        f.write(f"""
-- ═══════════════════════════════════════════════════════════════════════
-- Part 2.5: 插入 item_number_xref 表 ({len(applications_parts['item_number_xref'])} 筆)
-- ═══════════════════════════════════════════════════════════════════════

""")
        for sql in applications_parts['item_number_xref']:
            f.write(sql + "\n")
        
        # 2.6: technicaldocument
        f.write(f"""
-- ═══════════════════════════════════════════════════════════════════════
-- Part 2.6: 插入 technicaldocument 表 ({len(applications_parts['technicaldocument'])} 筆,已去重)
-- ═══════════════════════════════════════════════════════════════════════

""")
        for sql in applications_parts['technicaldocument']:
            f.write(sql + "\n")
        
        # 2.7: item_document_xref
        f.write(f"""
-- ═══════════════════════════════════════════════════════════════════════
-- Part 2.7: 插入 item_document_xref 表 ({len(applications_parts['item_document_xref'])} 筆)
-- ═══════════════════════════════════════════════════════════════════════

""")
        for sql in applications_parts['item_document_xref']:
            f.write(sql + "\n")
        
        # 2.8: application
        f.write(f"""
-- ═══════════════════════════════════════════════════════════════════════
-- Part 2.8: 插入 application 表 ({len(applications_parts['application'])} 筆)
-- ═══════════════════════════════════════════════════════════════════════

""")
        for sql in applications_parts['application']:
            f.write(sql + "\n")
        
        # Part 3: usersession
        f.write(f"""
-- =====================================================================
-- Part 3: 遷移 usersession 表 ({stats['user_sessions']} 筆記錄)
-- =====================================================================

""")
        for sql in sessions_sqls:
            f.write(sql + "\n")
        
        # Part 4: applicationattachment
        f.write(f"""
-- =====================================================================
-- Part 4: 遷移 applicationattachment 表 ({stats['application_attachments']} 筆記錄)
-- =====================================================================

""")
        for sql in attachments_sqls:
            f.write(sql + "\n")
        
        # 統計驗證
        f.write("""
-- =====================================================================
-- Part 5: 資料驗證
-- =====================================================================

DO $$ 
DECLARE
    v_user_count INTEGER;
    v_item_count INTEGER;
    v_application_count INTEGER;
    v_session_count INTEGER;
    v_attachment_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_user_count FROM web_app."User";
    SELECT COUNT(*) INTO v_item_count FROM web_app.item;
    SELECT COUNT(*) INTO v_application_count FROM web_app.application;
    SELECT COUNT(*) INTO v_session_count FROM web_app.usersession;
    SELECT COUNT(*) INTO v_attachment_count FROM web_app.applicationattachment;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE '遷移統計:';
    RAISE NOTICE '========================================';
    RAISE NOTICE '  User 表: % 筆', v_user_count;
    RAISE NOTICE '  item 表: % 筆', v_item_count;
    RAISE NOTICE '  application 表: % 筆', v_application_count;
    RAISE NOTICE '  usersession 表: % 筆', v_session_count;
    RAISE NOTICE '  applicationattachment 表: % 筆', v_attachment_count;
    RAISE NOTICE '========================================';
END $$;
""")
    
    # 輸出統計
    print("\n" + "="*60)
    print("遷移完成!")
    print("="*60)
    print(f"  users: {stats['users']} 筆")
    print(f"  user_sessions: {stats['user_sessions']} 筆")
    print(f"  application_attachments: {stats['application_attachments']} 筆")
    print(f"  applications: {stats['applications']} 筆")
    print(f"    - item: {len(applications_parts['item'])} 筆 (去重後)")
    print(f"    - supplier: {len(applications_parts['supplier'])} 筆 (去重後)")
    print(f"    - technicaldocument: {len(applications_parts['technicaldocument'])} 筆 (去重後)")
    print(f"  錯誤: {stats['errors']} 筆")
    print("="*60)
    print(f"輸出檔案: {output_file}")
    print("\n匯入命令:")
    print("  $env:PGPASSWORD='willlin07'")
    print("  & \"C:\\\\Program Files\\\\PostgreSQL\\\\16\\\\bin\\\\psql.exe\" -h localhost -p 5432 `")
    print("    -U postgres -d sbir_equipment_db_v3 -f migrate_v1_to_v3.sql")


# =====================================================================
# 主程式
# =====================================================================

if __name__ == '__main__':
    # 設定路徑
    script_dir = Path(__file__).parent
    input_file = script_dir.parent.parent.parent / 'export' / '20251219.sql'
    output_file = script_dir / 'migrate_v1_to_v3.sql'
    
    print("="*60)
    print("資料庫遷移工具 V2.0 (V1.0 → V3.2)")
    print("="*60)
    
    # 檢查輸入檔案
    if not input_file.exists():
        print(f"錯誤: 找不到輸入檔案 {input_file}")
        sys.exit(1)
    
    # 執行轉換
    process_sql_file(input_file, output_file)
