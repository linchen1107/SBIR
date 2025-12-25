-- ============================================================
-- 步驟 4：遷移後驗證與清理
-- 驗證資料完整性並可選擇性清理暫存資料
-- 日期：2025-12-26
-- 版本：v1.0
-- ============================================================

-- 設定搜尋路徑
SET search_path TO web_app, public;

-- ============================================================
-- 驗證區塊 1：計數比對
-- ============================================================

SELECT '=============== 資料計數驗證 ===============' AS section;

SELECT '--- 來源資料 (old_data) ---' AS category;
SELECT 'old_data.users' AS table_name, COUNT(*) AS count FROM old_data.users
UNION ALL
SELECT 'old_data.applications' AS table_name, COUNT(*) AS count FROM old_data.applications;

SELECT '--- 目標資料 (web_app) ---' AS category;
SELECT 'web_app.User' AS table_name, COUNT(*) AS count FROM web_app."User"
UNION ALL SELECT 'web_app.item' AS table_name, COUNT(*) AS count FROM web_app.item
UNION ALL SELECT 'web_app.item_material_ext' AS table_name, COUNT(*) AS count FROM web_app.item_material_ext
UNION ALL SELECT 'web_app.item_equipment_ext' AS table_name, COUNT(*) AS count FROM web_app.item_equipment_ext
UNION ALL SELECT 'web_app.application' AS table_name, COUNT(*) AS count FROM web_app.application
UNION ALL SELECT 'web_app.supplier' AS table_name, COUNT(*) AS count FROM web_app.supplier
UNION ALL SELECT 'web_app.technicaldocument' AS table_name, COUNT(*) AS count FROM web_app.technicaldocument
UNION ALL SELECT 'web_app.item_number_xref' AS table_name, COUNT(*) AS count FROM web_app.item_number_xref
UNION ALL SELECT 'web_app.item_document_xref' AS table_name, COUNT(*) AS count FROM web_app.item_document_xref;

-- ============================================================
-- 驗證區塊 2：外鍵完整性
-- ============================================================

SELECT '=============== 外鍵完整性驗證 ===============' AS section;

SELECT 
    'Application.user_id → User' AS "檢查項目",
    COUNT(*) AS "孤立記錄數"
FROM web_app.application a
WHERE a.user_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM web_app."User" u WHERE u.id = a.user_id);

SELECT 
    'Application.item_uuid → Item' AS "檢查項目",
    COUNT(*) AS "孤立記錄數"
FROM web_app.application a
WHERE a.item_uuid IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM web_app.item i WHERE i.item_uuid = a.item_uuid);

SELECT 
    'Item_Material_Ext.item_uuid → Item' AS "檢查項目",
    COUNT(*) AS "孤立記錄數"
FROM web_app.item_material_ext ime
WHERE NOT EXISTS (SELECT 1 FROM web_app.item i WHERE i.item_uuid = ime.item_uuid);

SELECT 
    'Item_Equipment_Ext.item_uuid → Item' AS "檢查項目",
    COUNT(*) AS "孤立記錄數"
FROM web_app.item_equipment_ext iee
WHERE NOT EXISTS (SELECT 1 FROM web_app.item i WHERE i.item_uuid = iee.item_uuid);

SELECT 
    'item_number_xref.item_uuid → Item' AS "檢查項目",
    COUNT(*) AS "孤立記錄數"
FROM web_app.item_number_xref inx
WHERE NOT EXISTS (SELECT 1 FROM web_app.item i WHERE i.item_uuid = inx.item_uuid);

-- ============================================================
-- 驗證區塊 3：使用者資料完整性
-- ============================================================

SELECT '=============== 使用者資料驗證 ===============' AS section;

SELECT 
    id,
    username,
    email,
    role,
    is_active,
    date_created
FROM web_app."User"
ORDER BY date_created;

-- ============================================================
-- 驗證區塊 4：資料抽樣檢查
-- ============================================================

SELECT '=============== 資料抽樣檢查 ===============' AS section;

SELECT 
    'Application 範例' AS check_type,
    a.id,
    a.form_serial_number,
    a.status,
    i.item_code,
    i.item_name_zh
FROM web_app.application a
LEFT JOIN web_app.item i ON i.item_uuid = a.item_uuid
LIMIT 5;

-- ============================================================
-- 清理區塊（可選）
-- 警告：以下命令會刪除暫存資料，請確認遷移完成後再執行
-- ============================================================

-- 取消註解以下命令來清理暫存資料：

-- DROP TABLE IF EXISTS old_data.applications CASCADE;
-- DROP TABLE IF EXISTS old_data.users CASCADE;
-- DROP SCHEMA IF EXISTS old_data CASCADE;

SELECT '=============== 驗證完成 ===============' AS section;
SELECT '若要清理 old_data schema，請取消註解上方的 DROP 命令' AS note;
