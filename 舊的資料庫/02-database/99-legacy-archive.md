# 附件三：原始30張資料表規格 (歷史存檔)

> **⚠️警告：此文件為歷史存檔**
>
> 本文檔所描述的30張資料表架構為**系統初期的完整設計**，目前已被**棄用**。
>
> 當前系統採用了更精簡的**15張核心資料表**，並運行在「雙 Schema」架構下。如需了解目前的系統設計，請查閱：
> - **`docs/01_當前SQL架構與建置指南.md`**: 了解最新的資料庫架構與 Docker 建置流程。
> - **`docs/02_當前資料表欄位詳細說明.md`**: 查看當前 `public` schema 中15張核心表的詳細欄位定義。
>
> ---

## 📋 文檔說明

本文檔記錄最初設計的30張完整資料表規格，包含所有DLA原始檔案的完整對應關係。這些資料表為系統未來擴展提供完整的參考架構。

**重要說明**: 當前系統已優化為15張核心表，本文檔僅供未來擴展時參考。

---

## 🗄️ 完整30張資料表清單與DLA對應

| 編號 | 分類 | 表格名稱 | 對應DLA檔案 | 狀態 | 主要功能 |
|---|---|---|---|---|---|
| **基礎分類系統** |
| 1 | 基礎分類 | `fsg` | Tabl316.TXT | ✅ 已實作 | 聯邦供應組別 |
| 2 | 基礎分類 | `fsc` | Tabl076.TXT | ✅ 已實作 | 聯邦供應分類 |
| **物品名稱系統** |
| 3 | 物品名稱 | `inc` | Tabl098.TXT | ✅ 已實作 | 物品名稱代碼 |
| 4 | 物品名稱 | `colloquial_inc_xref` | Tabl091.TXT | ✅ 已實作 | 俗稱INC對照 |
| 5 | 物品名稱 | `inc_fsc_xref` | Tabl099.TXT | ✅ 已實作 | INC-FSC交叉參照 |
| 6 | 物品名稱 | `replacement_inc` | Tabl990.TXT | 🔄 未來擴展 | INC替換追蹤 |
| **識別指南系統** |
| 7 | 識別指南 | `fiig` | 編輯指南提取 | ✅ 已實作 | 聯邦物品識別指南 |
| 8 | 識別指南 | `fiig_inc_xref` | Tabl122.TXT | ✅ 已實作 | FIIG-INC關聯 |
| 9 | 識別指南 | `fiig_inc_mrc_xref` | Tabl120.TXT | ✅ 已實作 | FIIG-INC-MRC關聯 |
| **需求代碼系統** |
| 10 | 需求代碼 | `mrc_key_group` | Tabl391.TXT | ✅ 已實作 | MRC分組 |
| 11 | 需求代碼 | `mrc` | Tabl127.TXT + Tabl347.TXT | ✅ 已實作 | 主需求代碼 |
| **回應表系統** |
| 12 | 回應表 | `reply_table` | Tabl128.TXT | ✅ 已實作 | 標準回應表 |
| 13 | 回應表 | `mrc_reply_table_xref` | Tabl126.TXT | ✅ 已實作 | MRC回應表關聯 |
| 14 | 回應表 | `isac_table` | Tabl124.TXT | 🔄 未來擴展 | ISAC表 |
| 15 | 回應表 | `isac_reply_table_xref` | Tabl125.TXT | 🔄 未來擴展 | ISAC回應表關聯 |
| **樣式系統** |
| 16 | 樣式系統 | `style_table` | Tabl131.TXT | 🔄 未來擴展 | 樣式定義 |
| 17 | 樣式系統 | `style_reply_table_xref` | 計算產生 | 🔄 未來擴展 | 樣式回應表關聯 |
| **編輯指南系統** |
| 18 | 編輯指南 | `edit_guide_2` | Tabl121.TXT | 🔄 未來擴展 | 編輯指南主表 |
| 19 | 編輯指南 | `edit_guide_2_technical` | Tabl121.TXT (LGA) | 🔄 未來擴展 | 技術編輯規則 |
| 20 | 編輯指南 | `edit_guide_2_relationship` | Tabl121.TXT (LGB) | 🔄 未來擴展 | 關係編輯規則 |
| 21 | 編輯指南 | `edit_guide_2_proportion` | Tabl121.TXT (LGC) | 🔄 未來擴展 | 比例編輯規則 |
| 22 | 編輯指南 | `mode_code_edit` | Tabl390.TXT | ✅ 已實作 | 模式代碼編輯 |
| **輔助功能系統** |
| 23 | 輔助功能 | `keyword_index` | Tabl364.TXT | 🔄 未來擴展 | 關鍵字索引 |
| 24 | 輔助功能 | `unapproved_item_name` | Tabl363.TXT | 🔄 未來擴展 | 未核准物品名稱 |
| 25 | 輔助功能 | `approved_words` | TBL557.TXT | 🔄 未來擴展 | 核准詞彙 |
| **國際標準系統** |
| 26 | 國際標準 | `nato_h6_item_name` | NATO-H6.TXT | ✅ 已實作 | NATO H6物品名稱 |
| 27 | 國際標準 | `nato_h6_inc_xref` | NATO-H6.TXT | ✅ 已實作 | NATO H6 INC對照 |
| **分類法系統** |
| 28 | 分類法 | `taxonomy_category` | TAXONOMY_TABLES | 🔄 未來擴展 | 分類法類別 |
| 29 | 分類法 | `taxonomy_fsc_xref` | TAXONOMY_TABLES | 🔄 未來擴展 | 分類法與FSC交叉參照 |
| **主檔系統** |
| 30 | 主檔 | `nsn` | 計算產生 | 🔄 未來擴展 | NSN主檔 |
