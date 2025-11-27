# 附件六：UML 設計

## 1. 用例圖 (Use Case Diagram)

```mermaid
graph TB
    %% 參與者
    User[使用者]
    Admin[系統管理員]
    
    %% 系統邊界
    subgraph "SmartCodexAI 系統"
        UC1[搜尋料件]
        UC2[查看料件詳情]
        UC3[使用者註冊/登入]
        UC4[匯出資料為 Word]
        UC5[管理資料庫]
        UC6[使用者管理]
        UC7[資料匯入]
    end
    
    %% 關聯關係
    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    
    Admin --> UC5
    Admin --> UC6
    Admin --> UC7
```

## 2. 類圖 (Class Diagram)

此類圖展示了基於「雙 Schema」架構的核心模型，並區分了不同的應用功能模組。

```mermaid
classDiagram
    namespace web_app {
        class User {
            +user_id: Integer
            +username: String
            +email: String
            +english_code: String
            +password_hash: String
            +set_password(password)
            +check_password(password)
        }
        class Application {
            +id: Integer
            +user_id: Integer
            +inc_code: String
            +status: String
            +created_at: DateTime
        }
        class ApplicationAttachment {
            +id: Integer
            +application_id: Integer
            +filename: String
        }
        class AuditLog {
            +log_id: Integer
            +user_id: Integer
            +action: String
            +created_at: DateTime
        }
    }

    namespace public {
        class FSC {
            +fsc_code: String
            +fsc_title: String
        }
        class INC {
            +inc_code: String
            +full_name: String
        }
        class Colloquial_INC_Xref {
             +primary_inc_code: String
             +colloquial_inc_code: String
        }
    }

    namespace application_layer {
        class SearchBlueprint {
            +general_search()
            +web_scrape_nsn()
        }
        class ApplicationBlueprint {
            +start_application_search()
            +submit_application_form()
            +download_word_document()
        }
        class AuthBlueprint {
            +login()
            +register()
            +profile()
        }
        class AdminBlueprint {
            +dashboard()
            +manage_users()
        }
    }

    User "1" -- "0..*" Application : "creates"
    User "1" -- "0..*" AuditLog : "generates"
    Application "1" -- "0..*" ApplicationAttachment : "has"
    AuthBlueprint ..> User : "manages"
    AdminBlueprint ..> User : "manages"
    AdminBlueprint ..> AuditLog : "records"
    
    ApplicationBlueprint ..> public.FSC : "queries"
    ApplicationBlueprint ..> public.INC : "queries"
    ApplicationBlueprint ..> public.Colloquial_INC_Xref : "queries"
    ApplicationBlueprint ..> Application : "creates"

    SearchBlueprint ..> public.FSC : "queries"
    SearchBlueprint ..> public.INC : "queries"
```

## 3. 時序圖 (Sequence Diagram)

### 料件搜尋與申編流程

```mermaid
sequenceDiagram
    participant User as "使用者"
    participant Browser as "瀏覽器"
    participant Flask as "Flask App (application)"
    participant DBEngine as "Database Engine (SQLAlchemy)"
    participant DB as "Database (nsn_database)"
    
    User->>Browser: 填寫 FSC/INC 表單並提交
    Browser->>Flask: POST /application/start
    
    Flask->>Flask: 判斷搜尋類型 (關鍵字 vs. 代碼)
    Flask->>DBEngine: 構建並執行原生 SQL 查詢 (含俗名解析邏輯)
    
    DBEngine->>DB: 執行複雜 SQL (含 CTE 與 JOIN)
    DB-->>DBEngine: 返回查詢結果
    
    DBEngine-->>Flask: 回傳結果列表
    
    Flask->>Browser: 渲染 `application/start.html` 模板並回傳
    Browser-->>User: 顯示階層式搜尋結果
```

### 使用者登入流程

```mermaid
sequenceDiagram
    participant User as 使用者
    participant Browser as 瀏覽器
    participant Flask as Flask App (Auth)
    participant SQLAlchemy as SQLAlchemy Session
    participant DB as nsn_database
    
    User->>Browser: 填寫登入表單並提交
    Browser->>Flask: POST /auth/login
    Flask->>SQLAlchemy: 查詢使用者 (query(User).filter_by(username=...))
    SQLAlchemy->>DB: SELECT * FROM web_app.users WHERE username = ...
    DB-->>SQLAlchemy: 返回使用者資料
    SQLAlchemy-->>Flask: 返回 User 物件
    Flask->>Flask: 驗證密碼 (user.check_password(...))
    alt 驗證成功
        Flask->>Browser: 建立 Session 並設定 Cookie，重導向至首頁
    else 驗證失敗
        Flask->>Browser: 回傳登入頁面並顯示錯誤訊息
    end
```

## 4. 部署圖 (Deployment Diagram)

此部署圖反映了基於 `docker-compose.yml` 的實際部署架構。

```mermaid
graph TD
    subgraph "開發/使用者端"
        Browser[Web 瀏覽器]
    end
    
    subgraph "Docker 環境"
        subgraph "Web 服務 (Container)"
            direction LR
            Nginx[Nginx] --> Gunicorn[Gunicorn] --> FlaskApp[Flask App]
        end

        subgraph "資料庫服務 (Container)"
            Postgres[PostgreSQL 16]
        end
        
        subgraph "翻譯服務 (Container)"
            TranslationService[Translation API]
        end

        Network[Docker Network]
    end

    Browser -- "HTTP/HTTPS" --> Nginx
    FlaskApp -- "DB Connection" --> Postgres
    FlaskApp -- "API Call" --> TranslationService

    Nginx --- Network
    Postgres --- Network
    TranslationService --- Network
```

---
**文檔版本**: v4.1 (Synced with admin features)
**更新日期**: 2025年10月14日
