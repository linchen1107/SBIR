-- =================================================================
-- 階段8: Mode Code Edit (模式代碼編輯規則) 資料匯入
-- 對應檔案: Tabl390.TXT
-- 目標表格: mode_code_edit
-- 依賴: 無
-- =================================================================

BEGIN;

-- 清除現有資料
DELETE FROM mode_code_edit;

INSERT INTO mode_code_edit (mode_code, mode_description, edit_instructions) 
VALUES ('A', '0', '1A MODE REPLY') 
ON CONFLICT (mode_code) DO UPDATE SET 
    mode_description = EXCLUDED.mode_description,
    edit_instructions = EXCLUDED.edit_instructions;
INSERT INTO mode_code_edit (mode_code, mode_description, edit_instructions) 
VALUES ('B', '0', '1B MODE REPLY') 
ON CONFLICT (mode_code) DO UPDATE SET 
    mode_description = EXCLUDED.mode_description,
    edit_instructions = EXCLUDED.edit_instructions;
INSERT INTO mode_code_edit (mode_code, mode_description, edit_instructions) 
VALUES ('D', '1', 'SELECT REPLY CODE') 
ON CONFLICT (mode_code) DO UPDATE SET 
    mode_description = EXCLUDED.mode_description,
    edit_instructions = EXCLUDED.edit_instructions;
INSERT INTO mode_code_edit (mode_code, mode_description, edit_instructions) 
VALUES ('F', '0', '1F MODE REPLY') 
ON CONFLICT (mode_code) DO UPDATE SET 
    mode_description = EXCLUDED.mode_description,
    edit_instructions = EXCLUDED.edit_instructions;
INSERT INTO mode_code_edit (mode_code, mode_description, edit_instructions) 
VALUES ('G', '0', 'FULL TEXT WRITE-IN') 
ON CONFLICT (mode_code) DO UPDATE SET 
    mode_description = EXCLUDED.mode_description,
    edit_instructions = EXCLUDED.edit_instructions;
INSERT INTO mode_code_edit (mode_code, mode_description, edit_instructions) 
VALUES ('H', '2', '2D MODE REPLY') 
ON CONFLICT (mode_code) DO UPDATE SET 
    mode_description = EXCLUDED.mode_description,
    edit_instructions = EXCLUDED.edit_instructions;
INSERT INTO mode_code_edit (mode_code, mode_description, edit_instructions) 
VALUES ('J', '1', '1D AND 1A MODE REPLY') 
ON CONFLICT (mode_code) DO UPDATE SET 
    mode_description = EXCLUDED.mode_description,
    edit_instructions = EXCLUDED.edit_instructions;
INSERT INTO mode_code_edit (mode_code, mode_description, edit_instructions) 
VALUES ('L', '0', '1L MODE REPLY') 
ON CONFLICT (mode_code) DO UPDATE SET 
    mode_description = EXCLUDED.mode_description,
    edit_instructions = EXCLUDED.edit_instructions;

COMMIT;

-- 統計: 成功匯入 8 筆Mode Code Edit資料
