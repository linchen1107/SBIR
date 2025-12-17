# MVC 架構導入指南 - SBIR 裝備管理系統

**文件編號**: 40-00  
**版本**: 2.0  
**最後更新**: 2025-12-17  
**作者**: SBIR 專案團隊  
**對象**: 工程團隊

---

## 📋 目錄

- [1. 為什麼要導入 MVC](#1-為什麼要導入-mvc)
- [2. MVC 是什麼](#2-mvc-是什麼)
- [3. 系統架構設計](#3-系統架構設計)
- [4. 實施流程](#4-實施流程)
- [5. 技術堆疊選擇](#5-技術堆疊選擇)
- [6. 部署策略](#6-部署策略)

---

## 1. 為什麼要導入 MVC

### 1.1 當前問題

系統面臨資料邏輯、業務處理、介面呈現混雜的狀況，導致維護困難、測試複雜、團隊協作效率低落。

### 1.2 MVC 帶來的價值

**關注點分離**：資料、邏輯、介面各司其職，降低耦合度。  
**平行開發**：前後端團隊可獨立作業，加速開發週期。  
**易於維護**：修改單一層級不影響其他層，降低迴歸風險。  
**可測試性**：各層可獨立進行單元測試與整合測試。  
**可擴展性**：新增功能時遵循既有架構模式，減少技術債。

---

## 2. MVC 是什麼

### 2.1 核心概念

MVC 將系統分為三個獨立但協作的層級，各自負責不同職責，透過明確介面溝通。

```mermaid
graph LR
    U[使用者] -->|請求| C[Controller<br/>控制器]
    C -->|查詢/更新| M[Model<br/>模型]
    M -->|資料| C
    C -->|資料| V[View<br/>視圖]
    V -->|畫面| U
    
    style C fill:#fff3cd
    style M fill:#f8d7da
    style V fill:#d1ecf1
    style U fill:#e3f2fd
```

### 2.2 三層職責

**Model（模型層）**：負責資料存取與業務邏輯，直接與資料庫溝通，提供乾淨的資料介面給 Controller。

**View（視圖層）**：負責呈現資料給使用者，接收 Controller 傳來的資料進行畫面渲染，不包含業務邏輯。

**Controller（控制器層）**：負責接收使用者請求、協調 Model 與 View，處理輸入驗證與流程控制。

### 2.3 與資料庫架構對應

```mermaid
graph TD
    subgraph MVC["MVC 架構"]
        C1[User Controller]
        C2[Equipment Controller]
        C3[NSN Controller]
        M1[web_app Models]
        M2[public Models]
    end
    
    subgraph DB["PostgreSQL"]
        S1[(web_app schema<br/>19 tables)]
        S2[(public schema<br/>15 tables + 5 views)]
    end
    
    C1 --> M1
    C2 --> M1
    C3 --> M2
    M1 --> S1
    M2 --> S2
    
    style MVC fill:#fff4e1
    style DB fill:#e8f5e9
```

SBIR 系統的雙 schema 架構（web_app 管理裝備、public 管理 NSN）對應到不同的 Model 群組，Controller 依功能選擇對應 Model。

---

## 3. 系統架構設計

### 3.1 整體架構圖

```mermaid
graph TB
    subgraph Client["🌐 Client 瀏覽器"]
        Browser["HTML + CSS + JavaScript"]
    end
    
    subgraph FlaskApp["🚀 Flask Application"]
        subgraph Controller["📋 Controller Layer"]
            BP["Flask Blueprints<br/>路由模組"]
            UserBP["user_bp<br/>使用者管理"]
            EquipBP["equipment_bp<br/>裝備管理"]
            NSNBP["nsn_bp<br/>NSN 搜尋"]
            AppBP["application_bp<br/>申編單管理"]
            ApiBP["api_bp<br/>RESTful API"]
        end
        
        subgraph Model["📦 Model Layer"]
            ORM["SQLAlchemy ORM"]
            subgraph WebAppModels["web_app Schema Models"]
                WA1["User, Application"]
                WA2["Item, Supplier"]
                WA3["BOM, MRC, Document"]
            end
            subgraph PublicModels["public Schema Models"]
                PB1["INC, FIIG, MRC"]
                PB2["NATO_H6, FSG, FSC"]
                PB3["ReplyTable"]
            end
        end
        
        subgraph View["🎨 View Layer"]
            Jinja["Jinja2 Templates"]
            Static["Static Files<br/>CSS, JS, Images"]
        end
    end
    
    subgraph Database["🗄️ PostgreSQL 16: sbir_equipment_db_v3"]
        WebAppSchema[("web_app schema<br/>19 tables")]
        PublicSchema[("public schema<br/>15 tables + 5 views")]
    end
    
    Browser <--->|HTTP| BP
    BP --> UserBP
    BP --> EquipBP
    BP --> NSNBP
    BP --> AppBP
    BP --> ApiBP
    
    UserBP <--> ORM
    EquipBP <--> ORM
    NSNBP <--> ORM
    AppBP <--> ORM
    ApiBP <--> ORM
    
    ORM --> WebAppModels
    ORM --> PublicModels
    
    UserBP --> Jinja
    EquipBP --> Jinja
    NSNBP --> Jinja
    AppBP --> Jinja
    
    Jinja --> Static
    Jinja -.->|Render| Browser
    
    WebAppModels <-->|SQL| WebAppSchema
    PublicModels <-->|SQL| PublicSchema
    
    style Client fill:#e1f5ff
    style FlaskApp fill:#fff4e1
    style Database fill:#e8f5e9
    style Controller fill:#fff3cd
    style Model fill:#f8d7da
    style View fill:#d1ecf1
```

### 3.2 資料流程

```mermaid
flowchart TD
    A[👤 使用者請求] --> B[🔀 路由 Controller]
    B --> C{✓ 驗證輸入}
    C -->|有效| D[📞 呼叫 Model]
    C -->|無效| L[❌ 錯誤回應]
    D --> E[🔧 業務邏輯處理]
    E --> F[💾 資料庫操作<br/>SQLAlchemy ORM]
    F --> G[(🗄️ PostgreSQL<br/>web_app / public schemas)]
    G --> H[📤 返回資料]
    H --> I[🔄 Model 處理與封裝]
    I --> J[🎯 Controller 選擇 View]
    J --> K[🎨 Jinja2 渲染 HTML]
    K --> M[📨 回應使用者]
    L --> M
    
    style A fill:#e3f2fd
    style B fill:#fff3e0
    style C fill:#fce4ec
    style D fill:#f3e5f5
    style E fill:#e8f5e9
    style F fill:#fff9c4
    style G fill:#e0f2f1
    style H fill:#e8eaf6
    style I fill:#fce4ec
    style J fill:#fff3e0
    style K fill:#f3e5f5
    style M fill:#c8e6c9
    style L fill:#ffcdd2
```

### 3.3 模組分工

**Controller 模組**：每個業務功能獨立為一個 Blueprint（使用者、裝備、NSN、申編單、API），降低路由複雜度。

**Model 模組**：依資料庫 schema 分組（web_app 裝備管理、public NSN 搜尋），每個表對應一個 Model 類別。

**View 模組**：模板繼承結構（base → 功能模板），靜態資源集中管理（CSS/JS/Images）。

---

## 4. 實施流程

### 4.1 開發階段劃分

```mermaid
gantt
    title MVC 導入時程規劃
    dateFormat  YYYY-MM-DD
    section 準備階段
    環境建置與套件安裝    :a1, 2025-01-01, 7d
    資料庫連接配置        :a2, after a1, 3d
    
    section Model 層
    web_app Models      :b1, after a2, 10d
    public Models       :b2, after b1, 7d
    Model 單元測試      :b3, after b2, 3d
    
    section Controller 層
    核心 Controllers    :c1, after b3, 10d
    進階 Controllers    :c2, after c1, 7d
    路由整合測試        :c3, after c2, 3d
    
    section View 層
    基礎模板設計        :d1, after c3, 7d
    功能頁面開發        :d2, after d1, 10d
    前端互動整合        :d3, after d2, 3d
    
    section 測試與部署
    整合測試            :e1, after d3, 5d
    效能調校            :e2, after e1, 3d
    上線部署            :e3, after e2, 2d
```
---

**文件版本**: 2.0  
**最後更新**: 2025-12-17  
**維護單位**: SBIR 專案團隊
