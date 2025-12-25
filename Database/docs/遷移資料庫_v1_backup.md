# 資料庫遷移說明文件

## 📋 概述

- **遷移日期**: 2025-12-24
- **來源資料庫**: `web_app` schema (舊版，來自 `web_app_schema.sql`)
- **目標資料庫**: `sbir_equipment_db_v3` - `web_app` schema (V3.2)
- **遷移資料表數量**: 6 個

---

## 📊 遷移資料表清單

| 序號 | 舊表名 | 新表名 | 主要變更 |
|------|--------|--------|----------|
| 1 | `users` | `User` | 時間戳欄位重命名 |
| 2 | `applications` | `Application` | 新增 `item_uuid` 外鍵、時間戳重命名 |
| 3 | `audit_logs` | `AuditLog` | 時間戳欄位重命名 |
| 4 | `user_sessions` | `UserSession` | 時間戳欄位重命名 |
| 5 | `application_attachments` | `ApplicationAttachment` | 時間戳欄位重命名 |
| 6 | `application_logs` | `ApplicationLog` | 結構基本相同 |

---

## 🔄 詳細欄位對照表

### 1. users → User

| 舊欄位名 | 新欄位名 | 資料類型 | 變更說明 |
|----------|----------|----------|----------|
| `id` | `id` | UUID | 無變更 |
| `username` | `username` | VARCHAR(80) | 無變更 |
| `email` | `email` | VARCHAR(120) | 無變更 |
| `password_hash` | `password_hash` | VARCHAR(256) | 無變更 |
| `english_code` | `english_code` | VARCHAR(10) | 無變更 |
| `full_name` | `full_name` | VARCHAR(100) | 無變更 |
| `department` | `department` | VARCHAR(100) | 無變更 |
| `position` | `position` | VARCHAR(100) | 無變更 |
| `phone` | `phone` | VARCHAR(20) | ⚠️ 長度縮短 50→20 |
| `role` | `role` | VARCHAR(50) | ⚠️ 長度擴展 20→50 |
| `is_active` | `is_active` | BOOLEAN | 無變更 |
| `is_verified` | `is_verified` | BOOLEAN | 無變更 |
| `email_verified_at` | `email_verified_at` | TIMESTAMP | 無變更 |
| `last_login_at` | `last_login_at` | TIMESTAMP | 無變更 |
| `failed_login_attempts` | `failed_login_attempts` | INT | 無變更 |
| `locked_until` | `locked_until` | TIMESTAMP | 無變更 |
| `created_at` | `date_created` | TIMESTAMP | ⭐ **欄位重命名** |
| `updated_at` | `date_updated` | TIMESTAMP | ⭐ **欄位重命名** |

**遷移 SQL**:
```sql
INSERT INTO web_app."User" (
    id, username, email, password_hash, english_code, full_name,
    department, position, phone, role, is_active, is_verified,
    email_verified_at, last_login_at, failed_login_attempts, locked_until,
    date_created, date_updated
)
SELECT 
    id, username, email, password_hash, english_code, full_name,
    department, position, 
    LEFT(phone, 20),  -- 截斷電話號碼至 20 字元
    role, is_active, is_verified,
    email_verified_at, last_login_at, failed_login_attempts, locked_until,
    created_at AS date_created, 
    updated_at AS date_updated
FROM old_web_app.users;
```

---

### 2. applications → Application

| 舊欄位名 | 新欄位名 | 資料類型 | 變更說明 |
|----------|----------|----------|----------|
| `id` | `id` | UUID | 無變更 |
| `user_id` | `user_id` | UUID | 無變更 |
| - | `item_uuid` | UUID | ⭐ **新增欄位** (FK → Item) |
| `form_serial_number` | `form_serial_number` | VARCHAR(50) | 無變更 |
| `part_number` | `part_number` | VARCHAR(50) | 無變更 |
| `english_name` | `english_name` | VARCHAR(255) | 無變更 |
| `chinese_name` | `chinese_name` | VARCHAR(255) | 無變更 |
| `inc_code` | `inc_code` | VARCHAR(20) | 無變更 |
| `fiig_code` | `fiig_code` | VARCHAR(20) | 無變更 |
| `accounting_unit_code` | `accounting_unit_code` | VARCHAR(50) | 無變更 |
| `issue_unit` | `issue_unit` | VARCHAR(10) | 無變更 |
| `unit_price` | `unit_price` | NUMERIC(10,2) | 無變更 |
| `spec_indicator` | `spec_indicator` | VARCHAR(10) | 無變更 |
| `unit_pack_quantity` | `unit_pack_quantity` | VARCHAR(10) | 無變更 |
| `storage_life_months` | `storage_life_months` | VARCHAR(10) | 無變更 |
| `storage_life_action_code` | `storage_life_action_code` | VARCHAR(10) | 無變更 |
| `storage_type_code` | `storage_type_code` | VARCHAR(10) | 無變更 |
| `secrecy_code` | `secrecy_code` | VARCHAR(10) | 無變更 |
| `expendability_code` | `expendability_code` | VARCHAR(10) | 無變更 |
| `repairability_code` | `repairability_code` | VARCHAR(10) | 無變更 |
| `manufacturability_code` | `manufacturability_code` | VARCHAR(10) | 無變更 |
| `source_code` | `source_code` | VARCHAR(10) | 無變更 |
| `category_code` | `category_code` | VARCHAR(10) | 無變更 |
| `system_code` | `system_code` | VARCHAR(100) | 無變更 |
| `pn_acquisition_level` | `pn_acquisition_level` | VARCHAR(100) | 無變更 |
| `pn_acquisition_source` | `pn_acquisition_source` | VARCHAR(100) | 無變更 |
| `manufacturer` | `manufacturer` | VARCHAR(255) | 無變更 |
| `part_number_reference` | `part_number_reference` | VARCHAR(255) | 無變更 |
| `manufacturer_name` | `manufacturer_name` | VARCHAR(255) | 無變更 |
| `agent_name` | `agent_name` | VARCHAR(255) | ⚠️ 長度縮短 255→100 |
| `ship_type` | `ship_type` | VARCHAR(100) | 無變更 |
| `cid_no` | `cid_no` | VARCHAR(100) | 無變更 |
| `model_type` | `model_type` | VARCHAR(255) | 無變更 |
| `equipment_name` | `equipment_name` | VARCHAR(255) | 無變更 |
| `usage_location` | `usage_location` | VARCHAR(255) → INT | ⚠️ **類型變更** |
| `quantity_per_unit` | `quantity_per_unit` | INTEGER → JSON | ⚠️ **類型變更** |
| `mrc_data` | `mrc_data` | JSON | 無變更 |
| `document_reference` | `document_reference` | VARCHAR(255) | 無變更 |
| `applicant_unit` | `applicant_unit` | VARCHAR(100) | 無變更 |
| `contact_info` | `contact_info` | VARCHAR(100) | 無變更 |
| `apply_date` | `apply_date` | DATE | 無變更 |
| `official_nsn_stamp` | `official_nsn_stamp` | VARCHAR(10) | 無變更 |
| `official_nsn_final` | `official_nsn_final` | VARCHAR(20) | 無變更 |
| `nsn_filled_at` | `nsn_filled_at` | TIMESTAMP | 無變更 |
| `nsn_filled_by` | `nsn_filled_by` | UUID | 無變更 |
| `status` | `status` | VARCHAR(50) | 無變更 |
| `sub_status` | `sub_status` | VARCHAR(50) | 無變更 |
| `closed_at` | `closed_at` | TIMESTAMP | 無變更 |
| `closed_by` | `closed_by` | UUID | 無變更 |
| `created_at` | `date_created` | TIMESTAMP | ⭐ **欄位重命名** |
| `updated_at` | `date_updated` | TIMESTAMP | ⭐ **欄位重命名** |
| `deleted_at` | `deleted_at` | TIMESTAMP | 無變更 |

**遷移 SQL**:
```sql
INSERT INTO web_app."Application" (
    id, user_id, item_uuid, form_serial_number, part_number,
    english_name, chinese_name, inc_code, fiig_code,
    accounting_unit_code, issue_unit, unit_price, spec_indicator,
    unit_pack_quantity, storage_life_months, storage_life_action_code,
    storage_type_code, secrecy_code, expendability_code,
    repairability_code, manufacturability_code, source_code,
    category_code, system_code, pn_acquisition_level, pn_acquisition_source,
    manufacturer, part_number_reference, manufacturer_name, agent_name,
    ship_type, cid_no, model_type, equipment_name, usage_location,
    quantity_per_unit, mrc_data, document_reference,
    applicant_unit, contact_info, apply_date,
    official_nsn_stamp, official_nsn_final, nsn_filled_at, nsn_filled_by,
    status, sub_status, closed_at, closed_by,
    date_created, date_updated, deleted_at
)
SELECT 
    id, user_id, 
    NULL AS item_uuid,  -- 新欄位，預設為 NULL
    form_serial_number, part_number,
    english_name, chinese_name, inc_code, fiig_code,
    accounting_unit_code, issue_unit, unit_price, spec_indicator,
    unit_pack_quantity, storage_life_months, storage_life_action_code,
    storage_type_code, secrecy_code, expendability_code,
    repairability_code, manufacturability_code, source_code,
    category_code, system_code, pn_acquisition_level, pn_acquisition_source,
    manufacturer, part_number_reference, manufacturer_name, 
    LEFT(agent_name, 100),  -- 截斷至 100 字元
    ship_type, cid_no, model_type, equipment_name, 
    CASE 
        WHEN usage_location ~ '^\d+$' THEN usage_location::INT 
        ELSE NULL 
    END AS usage_location,  -- 轉換為 INT，非數字設為 NULL
    CASE 
        WHEN quantity_per_unit IS NOT NULL THEN json_build_object('value', quantity_per_unit)
        ELSE NULL 
    END AS quantity_per_unit,  -- 轉換為 JSON 格式
    mrc_data, document_reference,
    applicant_unit, contact_info, apply_date,
    official_nsn_stamp, official_nsn_final, nsn_filled_at, nsn_filled_by,
    status, sub_status, closed_at, closed_by,
    created_at AS date_created, 
    updated_at AS date_updated, 
    deleted_at
FROM old_web_app.applications;
```

---

### 3. audit_logs → AuditLog

| 舊欄位名 | 新欄位名 | 資料類型 | 變更說明 |
|----------|----------|----------|----------|
| `log_id` | `log_id` | UUID | 無變更 |
| `user_id` | `user_id` | UUID | 無變更 |
| `action` | `action` | VARCHAR(100) | 無變更 |
| `resource_type` | `resource_type` | VARCHAR(50) | 無變更 |
| `resource_id` | `resource_id` | VARCHAR(100) | 無變更 |
| `old_values` | `old_values` | JSON | 無變更 |
| `new_values` | `new_values` | JSON | 無變更 |
| `ip_address` | `ip_address` | VARCHAR(45) | 無變更 |
| `user_agent` | `user_agent` | TEXT | 無變更 |
| `success` | `success` | BOOLEAN | 無變更 |
| `error_message` | `error_message` | TEXT | 無變更 |
| `created_at` | `date_created` | TIMESTAMP | ⭐ **欄位重命名** |

**遷移 SQL**:
```sql
INSERT INTO web_app."AuditLog" (
    log_id, user_id, action, resource_type, resource_id,
    old_values, new_values, ip_address, user_agent,
    success, error_message, date_created
)
SELECT 
    log_id, user_id, action, resource_type, resource_id,
    old_values, new_values, ip_address, user_agent,
    success, error_message,
    created_at AS date_created
FROM old_web_app.audit_logs;
```

---

### 4. user_sessions → UserSession

| 舊欄位名 | 新欄位名 | 資料類型 | 變更說明 |
|----------|----------|----------|----------|
| `session_id` | `session_id` | VARCHAR(255) | 無變更 |
| `user_id` | `user_id` | UUID | 無變更 |
| `ip_address` | `ip_address` | VARCHAR(45) | 無變更 |
| `user_agent` | `user_agent` | TEXT | 無變更 |
| `is_active` | `is_active` | BOOLEAN | 無變更 |
| `remember_me` | `remember_me` | BOOLEAN | 無變更 |
| `expires_at` | `expires_at` | TIMESTAMP | 無變更 |
| `created_at` | `date_created` | TIMESTAMP | ⭐ **欄位重命名** |
| `last_activity_at` | `last_activity_at` | TIMESTAMP | 無變更 |

**遷移 SQL**:
```sql
INSERT INTO web_app."UserSession" (
    session_id, user_id, ip_address, user_agent,
    is_active, remember_me, expires_at,
    date_created, last_activity_at
)
SELECT 
    session_id, user_id, ip_address, user_agent,
    is_active, remember_me, expires_at,
    created_at AS date_created, 
    last_activity_at
FROM old_web_app.user_sessions;
```

---

### 5. application_attachments → ApplicationAttachment

| 舊欄位名 | 新欄位名 | 資料類型 | 變更說明 |
|----------|----------|----------|----------|
| `id` | `id` | UUID | 無變更 |
| `application_id` | `application_id` | UUID | 無變更 |
| `user_id` | `user_id` | UUID | 無變更 |
| `file_data` | `file_data` | BYTEA | 無變更 |
| `filename` | `filename` | VARCHAR(255) | 無變更 |
| `original_filename` | `original_filename` | VARCHAR(255) | 無變更 |
| `mimetype` | `mimetype` | VARCHAR(100) | 無變更 |
| `file_type` | `file_type` | VARCHAR(20) | 無變更 |
| `page_selection` | `page_selection` | VARCHAR(200) | 無變更 |
| `sort_order` | `sort_order` | INT | 無變更 |
| `created_at` | `date_created` | TIMESTAMP | ⭐ **欄位重命名** |
| `updated_at` | `date_updated` | TIMESTAMP | ⭐ **欄位重命名** |

**遷移 SQL**:
```sql
INSERT INTO web_app."ApplicationAttachment" (
    id, application_id, user_id, file_data,
    filename, original_filename, mimetype, file_type,
    page_selection, sort_order,
    date_created, date_updated
)
SELECT 
    id, application_id, user_id, file_data,
    filename, original_filename, mimetype, file_type,
    page_selection, sort_order,
    created_at AS date_created, 
    updated_at AS date_updated
FROM old_web_app.application_attachments;
```

---

### 6. application_logs → ApplicationLog

| 舊欄位名 | 新欄位名 | 資料類型 | 變更說明 |
|----------|----------|----------|----------|
| `log_id` | `log_id` | UUID | 無變更 |
| `timestamp` | `timestamp` | TIMESTAMPTZ | 無變更 |
| `level` | `level` | VARCHAR(10) | 無變更 |
| `logger` | `logger` | VARCHAR(100) | 無變更 |
| `message` | `message` | TEXT | 無變更 |
| `request_id` | `request_id` | VARCHAR(36) | 無變更 |
| `method` | `method` | VARCHAR(10) | 無變更 |
| `path` | `path` | VARCHAR(500) | 無變更 |
| `status_code` | `status_code` | INT | 無變更 |
| `elapsed_time_ms` | `elapsed_time_ms` | NUMERIC(10,2) | 無變更 |
| `user_id` | `user_id` | UUID | 無變更 |
| `remote_addr` | `remote_addr` | INET | 無變更 |
| `user_agent` | `user_agent` | TEXT | 無變更 |
| `module` | `module` | VARCHAR(100) | 無變更 |
| `function` | `function` | VARCHAR(100) | 無變更 |
| `line` | `line` | INT | 無變更 |
| `exception_type` | `exception_type` | VARCHAR(100) | 無變更 |
| `exception_message` | `exception_message` | TEXT | 無變更 |
| `exception_traceback` | `exception_traceback` | JSONB | 無變更 |
| `extra_fields` | `extra_fields` | JSONB | 無變更 |
| `created_date` | `created_date` | DATE | 無變更 |

**遷移 SQL**:
```sql
INSERT INTO web_app."ApplicationLog" (
    log_id, timestamp, level, logger, message,
    request_id, method, path, status_code, elapsed_time_ms,
    user_id, remote_addr, user_agent,
    module, function, line,
    exception_type, exception_message, exception_traceback,
    extra_fields, created_date
)
SELECT 
    log_id, timestamp, level, logger, message,
    request_id, method, path, status_code, elapsed_time_ms,
    user_id, remote_addr, user_agent,
    module, function, line,
    exception_type, exception_message, exception_traceback,
    extra_fields, created_date
FROM old_web_app.application_logs;
```

---

## ⚠️ 重要變更注意事項

### 1. 時間戳欄位統一重命名

所有資料表的時間戳欄位都從 `created_at`/`updated_at` 重命名為 `date_created`/`date_updated`，以保持整個資料庫的命名一致性。

### 2. Application 表新增 item_uuid 欄位

新版本的 `Application` 表新增了 `item_uuid` 外鍵欄位，用於關聯到 `Item` 表。遷移時此欄位設為 `NULL`，後續需要手動建立關聯或透過程式邏輯處理。

### 3. 資料類型變更

| 表名 | 欄位 | 舊類型 | 新類型 | 處理方式 |
|------|------|--------|--------|----------|
| Application | `usage_location` | VARCHAR(255) | INT | 嘗試轉換，失敗設為 NULL |
| Application | `quantity_per_unit` | INTEGER | JSON | 轉換為 JSON 物件 |
| User | `phone` | VARCHAR(50) | VARCHAR(20) | 截斷超長資料 |
| Application | `agent_name` | VARCHAR(255) | VARCHAR(100) | 截斷超長資料 |

### 4. 表名大小寫變更

新版本使用 **PascalCase** 表名（如 `User`、`Application`），需要在 SQL 中使用雙引號包覆：

```sql
-- 正確寫法
SELECT * FROM web_app."User";
SELECT * FROM web_app."Application";

-- 錯誤寫法（會找不到表）
SELECT * FROM web_app.User;
SELECT * FROM web_app.Application;
```

---

## 🚀 遷移步驟

### 步驟 1：備份舊資料庫

```bash
pg_dump -h localhost -U postgres -d old_database -n web_app -F c -f backup_web_app_$(date +%Y%m%d).dump
```

### 步驟 2：建立新的資料庫結構

確保目標資料庫 `sbir_equipment_db_v3` 已建立，且 `web_app` schema 中的表結構已就緒。

### 步驟 3：設定舊資料庫連接

```sql
-- 方式一：使用 dblink
CREATE EXTENSION IF NOT EXISTS dblink;

-- 方式二：使用 postgres_fdw（外部資料封裝器）
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER old_db_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'localhost', dbname 'old_database', port '5432');

CREATE USER MAPPING FOR current_user
    SERVER old_db_server
    OPTIONS (user 'postgres', password 'your_password');

IMPORT FOREIGN SCHEMA web_app
    FROM SERVER old_db_server
    INTO old_web_app;
```

### 步驟 4：依序執行遷移 SQL

**重要**：必須按照以下順序執行，以維護外鍵約束：

1. `User` (無依賴)
2. `Application` (依賴 User)
3. `UserSession` (依賴 User)
4. `ApplicationAttachment` (依賴 Application, User)
5. `AuditLog` (依賴 User)
6. `ApplicationLog` (依賴 User)

### 步驟 5：驗證遷移結果

```sql
-- 驗證各表筆數
SELECT 'User' AS table_name, COUNT(*) AS count FROM web_app."User"
UNION ALL
SELECT 'Application', COUNT(*) FROM web_app."Application"
UNION ALL
SELECT 'UserSession', COUNT(*) FROM web_app."UserSession"
UNION ALL
SELECT 'ApplicationAttachment', COUNT(*) FROM web_app."ApplicationAttachment"
UNION ALL
SELECT 'AuditLog', COUNT(*) FROM web_app."AuditLog"
UNION ALL
SELECT 'ApplicationLog', COUNT(*) FROM web_app."ApplicationLog";

-- 驗證外鍵關聯完整性
SELECT COUNT(*) AS orphan_applications
FROM web_app."Application" a
LEFT JOIN web_app."User" u ON a.user_id = u.id
WHERE u.id IS NULL;
```

### 步驟 6：清理暫存物件

```sql
-- 移除外部資料封裝器相關物件
DROP SCHEMA IF EXISTS old_web_app CASCADE;
DROP USER MAPPING IF EXISTS FOR current_user SERVER old_db_server;
DROP SERVER IF EXISTS old_db_server CASCADE;
```

---

## 📝 完整遷移腳本

```sql
-- ============================================================
-- SBIR 資料庫遷移腳本
-- 來源: web_app schema (舊版)
-- 目標: sbir_equipment_db_v3 - web_app schema (V3.2)
-- 日期: 2025-12-24
-- ============================================================

-- 開始交易
BEGIN;

-- 1. 遷移 User 表
INSERT INTO web_app."User" (
    id, username, email, password_hash, english_code, full_name,
    department, position, phone, role, is_active, is_verified,
    email_verified_at, last_login_at, failed_login_attempts, locked_until,
    date_created, date_updated
)
SELECT 
    id, username, email, password_hash, english_code, full_name,
    department, position, 
    LEFT(phone, 20),
    role, is_active, is_verified,
    email_verified_at, last_login_at, failed_login_attempts, locked_until,
    created_at, updated_at
FROM old_web_app.users
ON CONFLICT (id) DO NOTHING;

-- 2. 遷移 Application 表
INSERT INTO web_app."Application" (
    id, user_id, item_uuid, form_serial_number, part_number,
    english_name, chinese_name, inc_code, fiig_code,
    accounting_unit_code, issue_unit, unit_price, spec_indicator,
    unit_pack_quantity, storage_life_months, storage_life_action_code,
    storage_type_code, secrecy_code, expendability_code,
    repairability_code, manufacturability_code, source_code,
    category_code, system_code, pn_acquisition_level, pn_acquisition_source,
    manufacturer, part_number_reference, manufacturer_name, agent_name,
    ship_type, cid_no, model_type, equipment_name, usage_location,
    quantity_per_unit, mrc_data, document_reference,
    applicant_unit, contact_info, apply_date,
    official_nsn_stamp, official_nsn_final, nsn_filled_at, nsn_filled_by,
    status, sub_status, closed_at, closed_by,
    date_created, date_updated, deleted_at
)
SELECT 
    id, user_id, 
    NULL,
    form_serial_number, part_number,
    english_name, chinese_name, inc_code, fiig_code,
    accounting_unit_code, issue_unit, unit_price, spec_indicator,
    unit_pack_quantity, storage_life_months, storage_life_action_code,
    storage_type_code, secrecy_code, expendability_code,
    repairability_code, manufacturability_code, source_code,
    category_code, system_code, pn_acquisition_level, pn_acquisition_source,
    manufacturer, part_number_reference, manufacturer_name, 
    LEFT(agent_name, 100),
    ship_type, cid_no, model_type, equipment_name, 
    CASE WHEN usage_location ~ '^\d+$' THEN usage_location::INT ELSE NULL END,
    CASE WHEN quantity_per_unit IS NOT NULL THEN json_build_object('value', quantity_per_unit) ELSE NULL END,
    mrc_data, document_reference,
    applicant_unit, contact_info, apply_date,
    official_nsn_stamp, official_nsn_final, nsn_filled_at, nsn_filled_by,
    status, sub_status, closed_at, closed_by,
    created_at, updated_at, deleted_at
FROM old_web_app.applications
ON CONFLICT (id) DO NOTHING;

-- 3. 遷移 UserSession 表
INSERT INTO web_app."UserSession" (
    session_id, user_id, ip_address, user_agent,
    is_active, remember_me, expires_at,
    date_created, last_activity_at
)
SELECT 
    session_id, user_id, ip_address, user_agent,
    is_active, remember_me, expires_at,
    created_at, last_activity_at
FROM old_web_app.user_sessions
ON CONFLICT (session_id) DO NOTHING;

-- 4. 遷移 ApplicationAttachment 表
INSERT INTO web_app."ApplicationAttachment" (
    id, application_id, user_id, file_data,
    filename, original_filename, mimetype, file_type,
    page_selection, sort_order,
    date_created, date_updated
)
SELECT 
    id, application_id, user_id, file_data,
    filename, original_filename, mimetype, file_type,
    page_selection, sort_order,
    created_at, updated_at
FROM old_web_app.application_attachments
ON CONFLICT (id) DO NOTHING;

-- 5. 遷移 AuditLog 表
INSERT INTO web_app."AuditLog" (
    log_id, user_id, action, resource_type, resource_id,
    old_values, new_values, ip_address, user_agent,
    success, error_message, date_created
)
SELECT 
    log_id, user_id, action, resource_type, resource_id,
    old_values, new_values, ip_address, user_agent,
    success, error_message, created_at
FROM old_web_app.audit_logs
ON CONFLICT (log_id) DO NOTHING;

-- 6. 遷移 ApplicationLog 表
INSERT INTO web_app."ApplicationLog" (
    log_id, timestamp, level, logger, message,
    request_id, method, path, status_code, elapsed_time_ms,
    user_id, remote_addr, user_agent,
    module, function, line,
    exception_type, exception_message, exception_traceback,
    extra_fields, created_date
)
SELECT 
    log_id, timestamp, level, logger, message,
    request_id, method, path, status_code, elapsed_time_ms,
    user_id, remote_addr, user_agent,
    module, function, line,
    exception_type, exception_message, exception_traceback,
    extra_fields, created_date
FROM old_web_app.application_logs
ON CONFLICT (log_id) DO NOTHING;

-- 提交交易
COMMIT;

-- ============================================================
-- 驗證遷移結果
-- ============================================================
SELECT 'User' AS table_name, COUNT(*) AS count FROM web_app."User"
UNION ALL SELECT 'Application', COUNT(*) FROM web_app."Application"
UNION ALL SELECT 'UserSession', COUNT(*) FROM web_app."UserSession"
UNION ALL SELECT 'ApplicationAttachment', COUNT(*) FROM web_app."ApplicationAttachment"
UNION ALL SELECT 'AuditLog', COUNT(*) FROM web_app."AuditLog"
UNION ALL SELECT 'ApplicationLog', COUNT(*) FROM web_app."ApplicationLog";
```

---

## 📌 後續處理事項

1. **建立 Item 關聯**：遷移後需要根據業務邏輯，將 `Application.item_uuid` 與對應的 `Item` 記錄建立關聯。

2. **重建索引**：遷移完成後建議執行 `REINDEX` 以優化查詢效能。

3. **更新觸發器**：確認新資料庫的 `update_date_updated_column()` 觸發器已正確掛載到各表。

4. **應用程式修改**：更新應用程式中的時間戳欄位名稱（`created_at` → `date_created`）。

---

## 📚 參考文件

- [01-資料庫結構_v3.2.md](00-整體架構/01-資料庫結構_v3.2.md) - 新資料庫結構文件
- [web_app_schema.sql](../../sql/web_app_schema.sql) - 舊資料庫結構
