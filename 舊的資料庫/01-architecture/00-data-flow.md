# 附件五：系統資料流設計

## 1. 系統資料流概述

SmartCodexAI 系統的資料流設計旨在高效處理料件查詢請求，整合多個資料來源，並提供快速回應。系統採用分層架構，並基於「單一資料庫、雙 Schema」的原則，確保資料的一致性和安全性。

## 2. 系統層級資料流圖 (Level 0 DFD)

```mermaid
graph TB
    %% 外部實體
    User["使用者"]
    Admin["系統管理員"]
    DLA[("DLA 原始資料")]
    
    %% 主系統
    subgraph "SmartCodexAI 系統"
        MainSystem["智慧料件查詢系統"]
    end
    
    %% 資料流
    User -- "搜尋請求 / 登入註冊" --> MainSystem
    MainSystem -- "查詢結果 / 頁面" --> User
    User -- "匯出請求" --> MainSystem
    MainSystem -- "Word 檔案" --> User
    
    Admin -- "管理指令" --> MainSystem
    MainSystem -- "系統狀態" --> Admin
    
    DLA -- "TXT 檔案" --> MainSystem
```

## 3. 第一層資料流圖 (Level 1 DFD)

```mermaid
graph TD
    %% 外部實體
    User["使用者"]
    Admin["系統管理員"]
    
    %% 系統處理程序
    P1["P1<br/>Web 應用"]
    P2["P2<br/>資料庫管理"]
    P3["P3<br/>使用者認證"]
    P4["P4<br/>資料匯入/轉換"]
    
    %% 資料儲存
    D1[("D1: nsn_database<br/>public schema")]
    D2[("D2: nsn_database<br/>web_app schema")]
    D3[("D3: 系統日誌")]
    
    %% 資料流
    User -- "HTTP 請求" --> P1
    P1 -- "HTML 頁面" --> User
    
    User -- "登入/註冊" --> P3
    P3 -- "認證結果" --> User
    
    Admin -- "管理指令" --> P2
    P2 -- "管理結果" --> Admin
    
    Admin -- "觸發匯入" --> P4
    
    P1 -- "查詢 public schema" --> D1
    D1 -- "料件資料" --> P1
    
    P1 -- "申編單資料" --> D2
    P1 -- "讀寫使用者資料" --> D2
    D2 -- "使用者會話" --> P1
    
    P3 -- "驗證使用者" --> D2
    
    P2 -- "管理資料庫" --> D1
    P2 -- "管理資料庫" --> D2
    
    P4 -- "寫入資料" --> D1
    
    P1 -- "記錄日誌" --> D3
    P2 -- "記錄日誌" --> D3
    P3 -- "記錄日誌" --> D3
```

## 4. 資料字典 (Data Dictionary)

| 資料儲存 | 描述 | 主要內容 |
|---|---|---|
| D1: `public` schema | 核心料件資料庫 | `fsc`, `inc`, `nato_h6_item_name` 等15張核心資料表 |
| D2: `web_app` schema | 網頁應用程式資料庫 | `users`, `user_sessions`, `applications` 等使用者與申編單相關資料表 |
| D3: 系統日誌 | 操作與錯誤記錄 | 時間戳、操作類型、使用者、結果等 |

| 資料流 | 描述 | 主要內容 |
|---|---|---|
| 申编单资料 | 使用者提交的料號申編表單內容 | `id` (系統唯一主鍵), `form_serial_number` (使用者自訂流水號), `official_nsn` (預留欄位), 以及其他表單欄位 |

## 5. 資料處理流程

本節展示系統核心的搜尋資料處理流程，特別是如何整合「俗名」查詢邏輯。

```mermaid
sequenceDiagram
    participant User as "使用者"
    participant Browser as "瀏覽器 (前端)"
    participant Flask as "Flask應用 (後端)"
    participant Database as "資料庫"

    User->>Browser: 在 INC 搜尋框輸入關鍵字 (可能是俗名)
    Browser->>Flask: 提交表單至 /application/start
    
    Flask->>Database: 執行整合了俗名邏輯的 SQL 查詢
    Note over Database: 1. <b>聯合搜尋</b>: 在 `inc` 表中用 `LIKE` 搜尋關鍵字<br/>2. <b>關聯對照表</b>: `LEFT JOIN` `colloquial_inc_xref` 表<br/>3. <b>回溯正式INC</b>: 將俗名對應到 `primary_inc_code`<br/>4. <b>查詢正式資料</b>: 根據「正式INC代碼」查詢完整資訊<br/>5. <b>標示搜尋來源</b>: 附加 `matched_colloquial_name` 欄位

    Database-->>Flask: 回傳搜尋結果列表 (正式 INC)

    Flask->>Browser: 渲染 start.html 模板並回傳頁面

    Browser->>User: 顯示統一的卡片式結果列表
    Note over Browser: 若 `matched_colloquial_name` 有值，<br/>則顯示 "(透過俗名 [xxx] 找到)"
```

## 6. 資料安全與備份

### 6.1 資料庫備份 (Docker)

推薦使用 `pg_dump` 在 Docker 環境中進行備份。

**手動備份指令範例:**
```bash
# 對整個 nsn_database 進行備份
docker-compose exec postgres pg_dump -U postgres -d nsn_database > backup.sql

# 只備份 public schema
docker-compose exec postgres pg_dump -U postgres -d nsn_database -n public > backup_public.sql

# 只備份 web_app schema
docker-compose exec postgres pg_dump -U postgres -d nsn_database -n web_app > backup_webapp.sql
```

### 6.2 資料庫恢復 (Docker)

```bash
# 恢復整個資料庫
cat backup.sql | docker-compose exec -T postgres psql -U postgres -d nsn_database
```

## 7. 資料一致性保證

- **應用層**: 使用 `Flask-SQLAlchemy` 管理資料庫會話，確保交易的原子性。
- **資料庫層**:
  - **`public` schema**: 透過 SQL 腳本建立的嚴格外鍵約束來保證資料的參照完整性。
  - **`web_app` schema**: 使用 `Flask-Migrate` 進行結構遷移，確保資料在變更過程中的一致性。

---
**文檔版本**: v4.0 (Docker-based)  
**更新日期**: 2025年8月7日
