-- =================================================================
-- 階段2: MRC Key Group (MRC關鍵字分組) 資料匯入
-- 對應檔案: Tabl391.TXT
-- 目標表格: mrc_key_group
-- 依賴: 無
-- =================================================================

BEGIN;

-- 清除現有資料
DELETE FROM mrc_key_group;

INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('01', 'Color');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('02', 'Design');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('03', 'Designator');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('04', 'Dimensions');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('05', 'Directional');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('06', 'Heat Treatment');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('07', 'Indicator');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('08', 'Location');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('09', 'Material');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('10', 'Measurement');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('11', 'Method');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('12', 'Quantity');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('13', 'Screw Thread');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('14', 'Shape');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('15', 'Standard');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('16', 'Style');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('17', 'Surface Treatment');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('18', 'Type');
INSERT INTO mrc_key_group (key_group_number, group_description) VALUES ('19', 'Miscellaneous');

COMMIT;

-- 統計: 成功匯入 19 筆MRC Key Group資料
