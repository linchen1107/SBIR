# INC 完整名稱查詢功能

## 📋 功能說明

支援使用者輸入「無逗號」的 INC 完整名稱進行查詢，提升搜尋的便利性和準確度。

---

## 🎯 問題背景

### 資料儲存格式

INC 名稱在資料庫中被拆分成三個欄位，並用**逗號+空格**連接：

```sql
short_name: TIMER
name_prefix: ELECTRONIC
name_root_remainder: INTERVAL

拼接結果: "TIMER, ELECTRONIC, INTERVAL"
```

### 原有問題

使用者習慣輸入**無逗號**的完整名稱（如：`timer electronic interval`），但系統只能匹配**有逗號**的格式，導致查詢失敗。

| 使用者輸入 | 資料庫格式 | 修改前 | 修改後 |
|-----------|-----------|-------|-------|
| `timer` | `TIMER, ELECTRONIC, INTERVAL` | ✅ | ✅ |
| `timer electronic interval` | `TIMER, ELECTRONIC, INTERVAL` | ❌ | ✅ |
| `timer, electronic, interval` | `TIMER, ELECTRONIC, INTERVAL` | ✅ | ✅ |
| `04879` (5碼) | - | ✅ | ✅ |

---

## 🔧 解決方案

### 修改檔案

`/app/search/unified_search_service.py`

### 實作方式

採用 **雙條件 OR 查詢** 方案：

1. **新增無逗號版本的 SQL 拼接變數**（第 47-48, 54-55 行）
   - SQLite: 使用 `||` 拼接，用 `REPLACE()` 去除多餘空格
   - PostgreSQL: 使用 `CONCAT_WS(' ', ...)` 以空格連接

2. **修改查詢條件** - 同時匹配「有逗號」和「無逗號」兩種格式
   - `inc_only` 查詢（第 127-128 行）
   - `fsc_and_inc` 查詢（第 190 行）

---

## 📝 程式碼範例

### SQLite 版本
```python
full_text_search_inc_no_comma = "TRIM(REPLACE(COALESCE(inc.short_name, '') || ' ' || COALESCE(inc.name_prefix, '') || ' ' || COALESCE(inc.name_root_remainder, ''), '  ', ' '))"
```

### PostgreSQL 版本
```python
full_text_search_inc_no_comma = "TRIM(CONCAT_WS(' ', inc.short_name, inc.name_prefix, inc.name_root_remainder))"
```

### SQL WHERE 條件
```sql
WHERE inc.status_code = 'A'
  AND (LOWER(CONCAT_WS(', ', ...)) LIKE :keyword    -- 原有：有逗號版本
    OR LOWER(CONCAT_WS(' ', ...)) LIKE :keyword)     -- 新增：無逗號版本
```

---

## ✅ 支援的查詢方式

修改後系統支援以下所有 INC 查詢方式：

### 1. 精確代碼查詢
- **輸入**: `04879`（5位數字）
- **比對**: `inc.inc_code = '04879'`
- **特性**: Bloom 過濾器快速檢查

### 2. 單一詞彙查詢
- **輸入**: `timer` 或 `electronic`
- **比對**: 部分匹配（LIKE `%timer%`）
- **結果**: 所有包含該詞彙的 INC

### 3. 有逗號完整名稱查詢
- **輸入**: `timer, electronic, interval`
- **比對**: 精確匹配逗號格式
- **結果**: 符合完整名稱的 INC

### 4. **無逗號完整名稱查詢**（🆕 新功能）
- **輸入**: `timer electronic interval`
- **比對**: 無逗號版本匹配
- **結果**: 符合完整名稱的 INC

### 5. FSC + INC 組合查詢
- **輸入**: FSC `6645` + INC `clock`
- **特性**: 在 FSC 範圍內查詢 INC，支援所有上述格式

### 6. 俗名解析查詢
- **特性**: 自動將俗名 INC 對應到正式 INC
- **支援**: 所有查詢方式都支援俗名解析

---

## 🚀 優點

1. ✅ **不修改資料庫結構** - 無需執行 migration
2. ✅ **完全向下相容** - 原有查詢方式完全正常
3. ✅ **效能影響最小** - 只增加一個 OR 條件
4. ✅ **使用者體驗提升** - 更符合自然輸入習慣
5. ✅ **維護成本低** - 程式碼邏輯清晰

---

## 🧪 測試方法

### 方法 1: 透過網頁介面測試

1. 啟動應用程式：
   ```bash
   docker-compose up -d
   ```

2. 開啟網頁 `/application/start`

3. 在「INC 品名」欄位測試以下輸入：
   - `timer` → 應找到所有包含 TIMER 的品項
   - `timer electronic` → 應找到名稱為 TIMER, ELECTRONIC 的品項
   - `timer, electronic` → 應找到相同的品項
   - `04879` → 應精確找到該 INC

### 方法 2: 透過 Python Shell 測試

```python
from app import create_app
from app.search.unified_search_service import perform_unified_search

app = create_app()
with app.app_context():
    # 測試無逗號查詢
    results, search_type = perform_unified_search(None, "timer electronic")
    print(f"找到 {len(results)} 筆結果")
    for item in results[:3]:
        print(f"INC {item['inc_code']}: {item['item_name']}")
```

### 預期結果

- **單一詞彙**: 返回所有包含該詞的 INC（可能很多筆）
- **完整名稱（無逗號）**: 返回精確匹配的 INC（通常較少）
- **完整名稱（有逗號）**: 返回相同的精確匹配結果

---

## 📊 效能影響分析

### SQL 查詢次數
- **修改前**: 1 次 SQL 查詢
- **修改後**: 1 次 SQL 查詢（相同）

### SQL 執行時間
- **額外成本**: 一個 OR 條件 + 一次字串拼接
- **預估影響**: < 5%（索引已存在於原欄位）

### 快取機制
- 快取鍵包含完整關鍵字，不同輸入會產生不同快取
- TTL: 600 秒 + 隨機 0-60 秒

---

## 🔍 相關檔案

- **主要修改**: `app/search/unified_search_service.py`
- **資料轉換**: `sql/txt_to_sql/05_convert_inc.py`（資料拆分邏輯）
- **資料表 Schema**: `docs/database/01_Schema_Public_Tables.md`
- **前端介面**: `app/templates/application/start.html`

---

## 📅 修改記錄

- **2025-11-03**: 實作無逗號完整名稱查詢功能
- **版本**: v1.0
- **影響範圍**: INC 查詢功能

---

## 💡 未來改進建議

1. **全文檢索 (FTS)**
   - 使用 PostgreSQL 的 `tsvector` 或 SQLite 的 FTS5
   - 支援更複雜的中英文混合查詢

2. **模糊匹配**
   - 實作 Levenshtein distance 或 Trigram similarity
   - 容忍拼字錯誤

3. **搜尋建議**
   - 輸入時提供自動完成建議
   - 使用 Elasticsearch 或 Meilisearch

4. **搜尋歷史**
   - 記錄使用者常用查詢
   - 提供熱門搜尋關鍵字
