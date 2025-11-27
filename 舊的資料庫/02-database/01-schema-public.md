# 附件二：`public` Schema 資料表欄位詳細說明 (v2.0)

---

## 📋 文檔說明

本文檔詳細描述當前 `public` schema 中 **15張核心資料表** 的欄位定義、資料類型、約束條件。此結構基於 `database_schema.sql` v2.0 版本，專注於優化北約料號 (NSN) 的申編流程。

- **表格架構**: 15張核心表格，取代舊有的30張表格。
- **核心流程**: H2 (FSG/FSC) → H6 (NATO) → INC → FIIG → MRC。
- **更新狀態**: 與當前SQL稿 `database_schema.sql` (版本2.0) 完全一致。

---

## 🔹 FSG/FSC 分類系統 (3張表格)

此系統為申編流程的最高層級分類，對應於H2階層。

### 1. `public.fsg` - 聯邦補給群組
**功能**: 定義聯邦政府的主要物料分類群組。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `fsg_code` | VARCHAR(2) | PK | FSG代碼 (主鍵) |
| `fsg_title` | TEXT | NOT NULL | FSG完整標題 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | 更新時間 |

### 2. `public.fsc` - 聯邦補給分類
**功能**: 在FSG下提供更詳細的物料分類。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `fsc_code` | VARCHAR(4) | PK | 完整FSC代碼 (主鍵) |
| `fsg_code` | VARCHAR(2) | NOT NULL, FK | 所屬FSG代碼 |
| `fsc_title` | VARCHAR(255)| NOT NULL | FSC標題 |
| `fsc_includes`| TEXT | - | 包含項目說明 |
| `fsc_excludes`| TEXT | - | 排除項目說明 |
| `fsc_notes` | TEXT | - | 備註 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | 更新時間 |

### 3. `public.inc_fsc_xref` - INC與FSC對應關係
**功能**: 建立物品名稱代碼(INC)與聯邦補給分類(FSC)的關聯。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `inc_code` | VARCHAR(15)| NOT NULL, PK | INC編號 |
| `fsc_code` | VARCHAR(4) | NOT NULL, PK, FK | FSC代碼 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |

---

## 🔹 NATO H6 物品名稱系統 (2張表格)

此系統為申編流程的第二層，提供基於北約標準的物品名稱，對應於H6階層。

### 4. `public.nato_h6_item_name` - NATO H6物品名稱主檔
**功能**: 儲存北約H6標準的物品名稱資料。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `h6_record_id` | VARCHAR(20) | PK | H6紀錄ID (主鍵) |
| `nato_item_name`| VARCHAR(255)| NOT NULL | 北約標準物品名稱 |
| `english_description` | TEXT | - | 英文描述 |
| `country_code` | VARCHAR(3) | - | 國家代碼 |
| `status_code` | VARCHAR(1) | CHECK('A','I','P') | 狀態碼 (A:Active, I:Inactive, P:Proposed) |
| `h6_number` | VARCHAR(20) | - | H6編號 |
| `created_date` | DATE | - | 建立日期 |
| `modified_date` | DATE | - | 修改日期 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 系統建立時間 |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | 系統更新時間 |

### 5. `public.nato_h6_inc_xref` - H6與INC對應關係
**功能**: 橋接H6物品名稱與更具體的INC代碼。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `h6_record_id` | VARCHAR(20) | NOT NULL, PK, FK | H6紀錄ID |
| `inc_code` | VARCHAR(15)| NOT NULL, PK | 對應的INC代碼 |
| `relationship_type`| VARCHAR(10)| DEFAULT 'EXACT'| 關係類型 |
| `confidence_level`| INTEGER | CHECK(0-100) | 可信度等級 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |

---

## 🔹 INC 物品名稱代碼系統 (2張表格)

INC是整個申編流程的核心，用於精確定義物品。

### 6. `public.inc` - 物品名稱代碼主檔
**功能**: 儲存物品名稱代碼(INC)的詳細定義。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `inc_code` | VARCHAR(15) | PK | INC編號 (主鍵) |
| `short_name` | TEXT | - | 短名稱 |
| `name_prefix` | TEXT | - | 名稱前綴 |
| `name_root_remainder`| TEXT | - | 名稱根餘 |
| `item_name_definition`| TEXT | - | 完整定義說明 |
| `status_code` | VARCHAR(1) | CHECK('A','I','P','S') | 狀態碼 |
| `is_official` | BOOLEAN | DEFAULT TRUE | 是否官方INC |
| `effective_date`| DATE | - | 生效日期 |
| `obsolete_date` | DATE | - | 廢止日期 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | 更新時間 |

### 7. `public.colloquial_inc_xref` - 俗稱INC對應正式INC
**功能**: 管理正式INC與其俗稱或同義詞之間的關係。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `primary_inc_code` | VARCHAR(15)| NOT NULL, PK, FK | 主要(正式)INC代碼 |
| `colloquial_inc_code`| VARCHAR(15)| NOT NULL, PK, FK | 俗稱INC代碼 |
| `relationship_type`| VARCHAR(20)| DEFAULT 'SYNONYM'| 關係類型 (如同義詞) |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |

---

## 🔹 FIIG 識別指南系統 (2張表格)

FIIG提供一組標準化的問題(MRC)，用以描述和識別INC所定義的物品。

### 8. `public.fiig` - 物品識別指南主檔
**功能**: 儲存聯邦物品識別指南(FIIG)的資料。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `fiig_code` | VARCHAR(10) | PK | FIIG編號 (主鍵) |
| `fiig_description` | TEXT | NOT NULL | FIIG描述說明 |
| `status_code` | VARCHAR(1) | CHECK('A','I','S') | 狀態碼 |
| `effective_date`| DATE | - | 生效日期 |
| `obsolete_date` | DATE | - | 廢止日期 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | 更新時間 |

### 9. `public.fiig_inc_xref` - FIIG與INC對應關係
**功能**: 建立FIIG與INC之間的關聯。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `fiig_code` | VARCHAR(10) | NOT NULL, PK, FK | FIIG編號 |
| `inc_code` | VARCHAR(15)| NOT NULL, PK, FK | INC編號 |
| `relationship_type`| VARCHAR(20)| DEFAULT 'APPLIES_TO'| 關係類型 |
| `sort_order` | INTEGER | DEFAULT 1 | 排序順序 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |

---

## 🔹 MRC 需求代碼系統 (3張表格)

MRC是FIIG下的具體問題，用於填寫物品的詳細屬性。

### 10. `public.mrc_key_group` - MRC分組
**功能**: 對MRC進行邏輯分組，方便管理。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `key_group_number`| VARCHAR(5) | PK | 分組代碼 (主鍵) |
| `group_description`| TEXT | NOT NULL | 分組描述 |
| `notes` | TEXT | - | 備註 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | 更新時間 |

### 11. `public.mrc` - 主需求代碼主檔
**功能**: 儲存物料需求代碼(MRC)的詳細定義，即申編時需要回答的問題。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `mrc_code` | VARCHAR(10) | PK | MRC編號 (主鍵) |
| `requirement_statement`| TEXT | NOT NULL | 需求(問題)陳述 |
| `key_group_number`| VARCHAR(5) | FK | 所屬分組代碼 |
| `data_type` | VARCHAR(20)| DEFAULT 'TEXT' | 預期資料類型 |
| `max_length` | INTEGER | - | 最大長度 |
| `is_required` | BOOLEAN | DEFAULT FALSE | 是否必填 |
| `validation_pattern`| VARCHAR(255)| - | 驗證用的正規表達式 |
| `help_text` | TEXT | - | 輔助說明文字 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | 更新時間 |

### 12. `public.fiig_inc_mrc_xref` - FIIG-INC-MRC三元關聯
**功能**: 申編流程的核心，定義了「哪個FIIG下的哪個INC」需要回答「哪些MRC」。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `fiig_code` | VARCHAR(10) | NOT NULL, PK, FK | FIIG編號 |
| `inc_code` | VARCHAR(15)| NOT NULL, PK, FK | INC編號 |
| `mrc_code` | VARCHAR(10) | NOT NULL, PK, FK | MRC編號 |
| `sort_num` | INTEGER | NOT NULL, DEFAULT 1 | 排序號 |
| `mrc_writable_indicator`| SMALLINT | CHECK(1,9) | 可寫入指標 |
| `tech_requirement_indicator`| VARCHAR(1)| CHECK('M','O','X')| 技術需求指標 (M:強制, O:可選) |
| `multiple_value_indicator`| VARCHAR(1)| CHECK('Y','N') | 是否允許多值 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |

---

## 🔹 回應系統 (2張表格)

此系統提供MRC問題的標準化選項。

### 13. `public.reply_table` - 回應選項表
**功能**: 儲存MRC的標準化回答選項。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `reply_table_number`| VARCHAR(10)| NOT NULL, PK | 回應表編號 |
| `reply_code` | VARCHAR(10)| NOT NULL, PK | 回應代碼 |
| `reply_description`| TEXT | NOT NULL | 回應描述 |
| `sort_order` | INTEGER | DEFAULT 1 | 排序順序 |
| `status_code` | VARCHAR(1) | CHECK('A','I') | 狀態碼 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |

### 14. `public.mrc_reply_table_xref` - MRC與回應表對應
**功能**: 建立MRC與其可用回答選項表之間的關聯。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `mrc_code` | VARCHAR(10) | NOT NULL, PK, FK | MRC編號 |
| `reply_table_number`| VARCHAR(10)| NOT NULL, PK | 回應表編號 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |

---

## 🔹 格式驗證資料表 (1張)

### 15. `public.mode_code_edit` - 模式代碼編輯與驗證
**功能**: 提供特定模式下資料填寫的編輯與驗證規則。
| 欄位名稱 | 資料類型 | 約束 | 說明 |
|---|---|---|---|
| `mode_code` | VARCHAR(10) | PK | 模式代碼 (主鍵) |
| `mode_description`| TEXT | NOT NULL | 模式描述 |
| `edit_instructions`| TEXT | - | 編輯指令 |
| `examples` | TEXT | - | 範例 |
| `status_code` | VARCHAR(1) | CHECK('A','I') | 狀態碼 |
| `created_at` | TIMESTAMP | DEFAULT NOW() | 建立時間 |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | 更新時間 |

---
**文檔版本**: v5.0 (Schema v2.0)
**更新日期**: 自動生成
