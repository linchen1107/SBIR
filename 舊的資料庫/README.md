# 專案技術文檔

本目錄是 NSN 料號申編系統的統一技術文件入口。所有文件都已根據最新的 **Docker 開發環境**和**雙 Schema 資料庫架構**進行了更新，並已重新組織為清晰的目錄結構。

---

## ⭐ 快速開始

**最常用的指令和文檔**:

- 📖 [快速指令參考手冊](QUICK_REFERENCE.md) - **強烈推薦！** 包含日常開發、部署、Git、資料庫等所有常用指令，每個指令都可跳轉到原始文檔

---

## 📂 文件結構導覽

本專案文檔採用模組化架構，按功能分類為以下目錄：

| 資料夾 | 內容摘要 | 主要使用者 |
|--------|----------|------------|
| **[00-getting-started/](00-getting-started/)** | 新手入門、開發工作流程與快速啟動指南 | 全體開發團隊 |
| **[01-architecture/](01-architecture/)** | 系統架構設計、資料流、UML 圖表與使用者故事 | 系統設計師、架構師 |
| **[02-database/](02-database/)** | 資料庫架構、Schema 定義、關係圖表 | 後端開發者、DBA |
| **[03-features/](03-features/)** | 功能模組說明（INC 搜尋、NSN/BOM、模板系統、管理員功能） | 全端開發者 |
| **[04-deployment/](04-deployment/)** | Git 工作流程、伺服器部署、資料庫備份還原 | 維運人員、DevOps |
| **[05-development/](05-development/)** | 測試策略、日誌系統、業務邏輯開發指南 | 全體開發團隊 |
| **[06-user-guides/](06-user-guides/)** | 使用者操作手冊 | 終端使用者、測試人員 |
| **[99-planning/](99-planning/)** | 開發路線圖、系統改善計劃 | 產品經理、專案經理 |

---

## 📚 詳細文檔索引

### 00-getting-started/ - 新手入門

| 檔案名稱 | 內容摘要 | 建議讀者 |
|----------|----------|----------|
| [01-development-workflows.md](00-getting-started/01-development-workflows.md) | **【必讀】** 四種開發模式：日常開發、徹底重置、正式部署、備份還原完整流程 | 全體開發團隊 |

---

### 01-architecture/ - 系統架構

| 檔案名稱 | 內容摘要 | 建議讀者 |
|----------|----------|----------|
| [00-data-flow.md](01-architecture/00-data-flow.md) | 系統的資料流程圖 (DFD)，描述資料如何在不同模組間傳遞 | 系統分析師 |
| [01-uml-diagrams.md](01-architecture/01-uml-diagrams.md) | 包含使用案例圖、類別圖、時序圖等 UML 設計文件 | 系統設計師 |
| [02-service-architecture.md](01-architecture/02-service-architecture.md) | 模組化服務架構設計 | 後端架構師 |
| [03-user-stories.md](01-architecture/03-user-stories.md) | 從使用者角度描述系統應具備的功能與需求 | 產品經理、開發者 |

---

### 02-database/ - 資料庫

| 檔案名稱 | 內容摘要 | 建議讀者 |
|----------|----------|----------|
| [00-architecture.md](02-database/00-architecture.md) | **【核心】** 雙 Schema 架構、ERD 圖表、Docker 建置流程、INC 俗名關係詳細圖解 | 全體開發團隊 |
| [01-schema-public.md](02-database/01-schema-public.md) | `public` schema 中 15 張核心資料表的詳細欄位定義 | 後端開發者、DBA |
| [02-schema-webapp.md](02-database/02-schema-webapp.md) | `web_app` schema 中 10 張應用程式表格的詳細欄位定義與關聯圖 | 全端開發者、DBA |
| [03-dla-original-format.md](02-database/03-dla-original-format.md) | **【技術參考】** DLA 原始 `.txt` 檔的欄位定義 | 資料分析師 |
| [99-legacy-archive.md](02-database/99-legacy-archive.md) | **【歷史存檔】** 原始的 30 表結構設計，僅供歷史參考 | 系統架構師 |

---

### 03-features/ - 功能模組

#### INC 搜尋功能

| 檔案名稱 | 內容摘要 | 建議讀者 |
|----------|----------|----------|
| [00-inc-search/00-design-flow.md](03-features/00-inc-search/00-design-flow.md) | 俗名（Colloquial Name）搜尋的詳細設計，包含後端邏輯與前端呈現 | 後端、前端開發者 |
| [00-inc-search/01-inc-colloquial-names.md](03-features/00-inc-search/01-inc-colloquial-names.md) | 詳細解釋了「正式INC」與「俗名INC」之間的資料庫關聯，並附上搜尋流程圖 | 後端、前端開發者 |
| [00-inc-search/02-full-name-search.md](03-features/00-inc-search/02-full-name-search.md) | INC 完整名稱查詢功能實作說明 | 後端開發者 |
| [00-inc-search/03-search-text-implementation.md](03-features/00-inc-search/03-search-text-implementation.md) | Search_Text 欄位實作與部署指南 | 後端開發者、DBA |

#### 其他功能模組

| 檔案名稱 | 內容摘要 | 建議讀者 |
|----------|----------|----------|
| [01-nsn-bom/00-nsn-final-number-and-bom.md](03-features/01-nsn-bom/00-nsn-final-number-and-bom.md) | NSN 回填與 BOM 管理功能規格 | 全端開發者 |
| [02-template-system/00-template-system-design.md](03-features/02-template-system/00-template-system-design.md) | 模板系統設計與 Phase 規劃 | 全端開發者 |
| [03-admin-management/00-admin-user-management.md](03-features/03-admin-management/00-admin-user-management.md) | 後台使用者管理功能的詳細規格與實作說明 | 全端開發者 |

---

### 04-deployment/ - 部署維運

| 檔案名稱 | 內容摘要 | 建議讀者 |
|----------|----------|----------|
| [00-git-workflow.md](04-deployment/00-git-workflow.md) | Git 標準推送流程、GitHub/Gitea 雙遠端設定 | 全體開發團隊 |
| [01-gunicorn-deployment.md](04-deployment/01-gunicorn-deployment.md) | Gunicorn 伺服器部署設定與 WSGI 進入點的詳細說明 | 後端開發者、維運人員 |
| [02-database-backup-restore.md](04-deployment/02-database-backup-restore.md) | **【重要】** 資料庫備份與還原完整指南，包含互動式/參數式匯出 | 維運人員、DBA |

---

### 05-development/ - 開發指南

| 檔案名稱 | 內容摘要 | 建議讀者 |
|----------|----------|----------|
| [00-testing-strategy.md](05-development/00-testing-strategy.md) | 從整合測試演進至 Mocked 單元測試的核心策略與優勢 | 全體開發團隊 |
| [01-logging-system.md](05-development/01-logging-system.md) | 日誌系統架構與使用指南 | 後端開發者 |
| [02-business-logic/00-business-process.md](05-development/02-business-logic/00-business-process.md) | 系統核心業務流程圖，包含 NSN 查詢與料號申編流程 | 產品經理、分析師 |
| [02-business-logic/01-approval-workflow.md](05-development/02-business-logic/01-approval-workflow.md) | 審批流程說明 | 產品經理、開發者 |

---

### 06-user-guides/ - 使用者手冊

| 檔案名稱 | 內容摘要 | 建議讀者 |
|----------|----------|----------|
| [00-inc-search-guide.md](06-user-guides/00-inc-search-guide.md) | **【極詳細】** INC 搜尋使用指南，含豐富範例 | 終端使用者、測試人員 |

---

### 99-planning/ - 規劃文件

| 檔案名稱 | 內容摘要 | 建議讀者 |
|----------|----------|----------|
| [00-q4-2025-roadmap.md](99-planning/00-q4-2025-roadmap.md) | Q4 2025 開發計畫、任務與查核點 | 全體開發團隊 |
| [01-system-improvement-plan.md](99-planning/01-system-improvement-plan.md) | 根據使用者回饋整理的系統待辦議題與優化建議 | 產品經理、開發者 |

---

## 🎯 使用指南

### 新手入門 (建議閱讀順序)

1. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - 快速了解最常用的指令
2. **[00-getting-started/01-development-workflows.md](00-getting-started/01-development-workflows.md)** - 了解四種開發模式
3. **[02-database/00-architecture.md](02-database/00-architecture.md)** - 理解系統的基礎架構和如何在本地使用 Docker 建立開發環境
4. **[01-architecture/02-service-architecture.md](01-architecture/02-service-architecture.md)** 和 **[01-architecture/03-user-stories.md](01-architecture/03-user-stories.md)** - 了解系統的業務流程、目標功能與設計理念
5. **[02-database/01-schema-public.md](02-database/01-schema-public.md)** - 在開始撰寫任何資料庫相關的程式碼之前，請先熟悉 `public` schema 的資料表結構

### 日常開發參考

- **快速查指令**: 直接開啟 **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)**，複製貼上即可使用
- **開發查詢**: 使用 [02-database/01-schema-public.md](02-database/01-schema-public.md) 來查找 `public` schema 的欄位定義。對於 `web_app` schema，請參考 `app/models.py` 中的 SQLAlchemy 模型
- **建置部署**: 嚴格遵循 [00-getting-started/01-development-workflows.md](00-getting-started/01-development-workflows.md) 中描述的 Docker 指令
- **Git 操作**: 參考 [04-deployment/00-git-workflow.md](04-deployment/00-git-workflow.md) 進行 GitHub/Gitea 推送
- **備份還原**: 參考 [04-deployment/02-database-backup-restore.md](04-deployment/02-database-backup-restore.md) 進行資料庫備份與還原

### 功能開發參考

- **INC 搜尋相關**: 查閱 [03-features/00-inc-search/](03-features/00-inc-search/) 目錄下的所有文檔
- **模板系統**: 參考 [03-features/02-template-system/00-template-system-design.md](03-features/02-template-system/00-template-system-design.md)
- **管理員功能**: 參考 [03-features/03-admin-management/00-admin-user-management.md](03-features/03-admin-management/00-admin-user-management.md)

---

## 📌 文檔維護原則

1. **統一命名**: 所有文件使用 `kebab-case` 英文檔名（如 `database-architecture.md`）
2. **兩位數編號**: 重要文件從 `00` 開始編號，歸檔文件使用 `99`
3. **模組化組織**: 相關文件集中在同一目錄下
4. **交叉引用**: 文件間使用相對路徑連結
5. **版本追蹤**: 每個文件底部包含版本號和更新日期

---

**文檔版本**: v6.0 (Complete restructure with QUICK_REFERENCE)
**架構類型**: 模組化分類架構
**更新日期**: 2025-01-10
**狀態**: 生產就緒 ✅
