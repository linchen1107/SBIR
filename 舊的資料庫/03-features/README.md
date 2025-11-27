# 功能模組文檔

本目錄包含系統各功能模組的詳細說明，按功能分類為子目錄。

## 📂 子目錄列表

| 目錄 | 內容摘要 |
|------|----------|
| [00-inc-search/](00-inc-search/) | INC 搜尋相關功能（俗名搜尋、完整名稱搜尋、Search_Text 實作） |
| [01-nsn-bom/](01-nsn-bom/) | NSN 回填與 BOM 管理功能 |
| [02-template-system/](02-template-system/) | 模板系統設計與實作 |
| [03-admin-management/](03-admin-management/) | 後台管理員功能 |

## 📚 詳細文檔列表

### INC 搜尋功能

| 檔案名稱 | 內容摘要 |
|----------|----------|
| [00-inc-search/00-design-flow.md](00-inc-search/00-design-flow.md) | 俗名（Colloquial Name）搜尋的詳細設計，包含後端邏輯與前端呈現 |
| [00-inc-search/01-inc-colloquial-names.md](00-inc-search/01-inc-colloquial-names.md) | 詳細解釋了「正式INC」與「俗名INC」之間的資料庫關聯，並附上搜尋流程圖 |
| [00-inc-search/02-full-name-search.md](00-inc-search/02-full-name-search.md) | INC 完整名稱查詢功能實作說明 |
| [00-inc-search/03-search-text-implementation.md](00-inc-search/03-search-text-implementation.md) | Search_Text 欄位實作與部署指南 |

### 其他功能模組

| 檔案名稱 | 內容摘要 |
|----------|----------|
| [01-nsn-bom/00-nsn-final-number-and-bom.md](01-nsn-bom/00-nsn-final-number-and-bom.md) | NSN 回填與 BOM 管理功能規格 |
| [02-template-system/00-template-system-design.md](02-template-system/00-template-system-design.md) | 模板系統設計與 Phase 規劃 |
| [03-admin-management/00-admin-user-management.md](03-admin-management/00-admin-user-management.md) | 後台使用者管理功能的詳細規格與實作說明 |

## 🎯 使用建議

- **開發新功能**: 參考相關功能模組的文檔了解設計思路
- **維護現有功能**: 查閱對應模組的文檔確認業務邏輯
- **INC 搜尋問題**: 優先查閱 [00-inc-search/](00-inc-search/) 目錄下的所有文檔

---

[返回文檔首頁](../README.md)
