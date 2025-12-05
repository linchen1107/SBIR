# 資料庫組態管理 (Database Configuration Management, DCM) 完整指南

**目的：讓資料庫的 Schema、參數、版本、資料模型變更可以像程式碼一樣被管理、被追蹤、可回滾、可審核、可自動化部署。**

---

## 一、什麼是資料庫組態管理？（定義）

資料庫組態管理指的是：

> **以系統化方式管理資料庫的：Schema、Migration、Stored Procedures、Functions、初始參數、環境配置、版本、Metadata、樣板資料（Seed），並確保所有環境都能一致與可回溯。**

換句話說，是給 **資料庫** 建立一套跟 Git 一樣的版本控制系統。

---

## 二、為什麼你需要資料庫組態管理？（核心價值）

1. **避免多人同時修改 DB 造成混亂**
   * 避免 A 換欄位、B 加索引、C 刪 Foreign Key → 最後不上線會出事。
2. **所有 DB 變更都有版本、有描述、有回滾 Script**
   * 每一次 Migration 都像：`V2025.12.04__add_analysis_runs_table.sql`
3. **CI/CD 可自動部署資料庫變更**
   * 當 Backend 部署時，Schema 也應該同步自動升級。
4. **Test / Staging / Prod 多環境保持一致**
   * 不會再出現：「為什麼 Production 少一張表？」的狀況。
5. **系統生命週期管理**
   * 系統會演進 (Evolution)，因此資料庫 Schema 也需要版本化 (Versioning)。

---

## 三、資料庫組態管理的標準內容

完整組態管理應該納入以下項目：

### A. 結構（Schema）

* Tables
* Columns
* Indexes
* Constraints
* Views

### B. 程式物件（DB Code）

* Stored Procedures
* Functions
* Triggers

### C. 初始資料 & 參考資料 (Reference Data)

* 權限角色列表
* 系統參數表

### D. 組態參數（Database Config）

例如 PostgreSQL / SQL Server 的設定：

* `max_connections`
* `shared_buffers`
* `work_mem`
* *註：這些值需要記錄版本與環境差異。*

### E. Metadata（非常重要！）

資料庫本身應包含自身的版本資訊：

| Key                        | 說明                           |
| :------------------------- | :----------------------------- |
| `schema_version`         | 目前 DB 的版本，例如 `1.3.2` |
| `migration_history`      | 所有 Migration 的紀錄          |
| `pipeline_version`       | Pipeline 版本                  |
| `analysis_model_version` | 模型版本與 DB 的一致性         |

---

## 四、資料庫組態管理的工具建議

### PostgreSQL / MySQL

* **Flyway（推薦）**
  * SQL Script-based
  * 最容易整合 CI/CD
  * 支援 Baseline / Repair / Repeatable Migrations
  * 與 GitFlow 完美整合

### SQL Server

* **Flyway** 或 **Liquibase**
* **Microsoft DACPAC**（大型專案適用）

### MongoDB (NoSQL)

雖然 NoSQL 沒有 Schema，但仍需要 Migration Framework 來管理資料結構變更：

* **Mongock（推薦）**
  * 支援 Transaction
  * 可與 Spring / Node 整合
  * 可記錄版本

---

## 五、建議的資料庫組態架構

針對多系統環境（MongoDB、PostgreSQL、SQL Server），建議的 Git 版控目錄結構如下：

### A. 目錄結構

```text
db/
 ├── postgres/
 │    ├── migrations/
 │    │     ├── V1__init_tables.sql
 │    │     ├── V2__add_analysis_runs.sql
 │    │     └── V3__add_pipeline_version.sql
 │    ├── seed/
 │    └── README.md
 ├── mongodb/
 │    ├── migrations/
 │    │     ├── V1__init.js
 │    │     ├── V2__add_configs.js
 │    │     └── V3__analysis_runs_refactor.js
 │    ├── seed/
 │    └── README.md
 ├── sqlserver/
 │    ├── migrations/
 │    └── seed/
```

### B. schema_version Table

所有資料庫都應包含版本控制表。

**PostgreSQL / SQL Server:**

```sql
CREATE TABLE schema_version (
    id SERIAL PRIMARY KEY,
    version VARCHAR(50),
    description TEXT,
    applied_at TIMESTAMP DEFAULT now(),
    success BOOLEAN
);
```

**MongoDB:**

```javascript
db.schema_version.insert({
    version: "1.0.0",
    description: "init",
    applied_at: ISODate(),
    success: true
})
```

### C. CI/CD 自動部署流程

1. **Code Push**: 程式碼推送到 Git。
2. **Trigger**: GitHub Actions / GitLab CI 觸發。
3. **Migrate**: Runner 自動執行 Flyway 或其他工具。
   * `flyway -configFiles=flyway.conf migrate`
4. **Deploy**: 資料庫升級成功後，才部署 Backend 應用程式。

---

## 六、資料庫組態管理 SOP

1. **所有變更必須產生一支 Migration Script**
   * 例如：`V2025.12.04__add_analysis_runs.sql`
2. **禁止直接操作 DB**
   * 嚴禁使用 GUI 工具直接修改 Schema（Migration-First）。
3. **每次部署前必須跑 Migration**
   * 在 CI/CD 流程中自動執行。
4. **每個 Migration 必須可回滾 (Rollback)**
   * Up: `ALTER TABLE analysis ADD COLUMN pipeline_version TEXT;`
   * Down: `ALTER TABLE analysis DROP COLUMN pipeline_version;`
5. **資料庫設定需被版本控管**
   * 設定檔（如 `postgresql.conf`）應納入 Git 管理，並標註環境差異（Dev vs Prod）。
