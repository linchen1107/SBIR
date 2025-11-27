# SmartCodexAI 日誌系統使用指南

## 📋 概覽

SmartCodexAI 使用多目標日誌系統，同時將日誌寫入：
- **PostgreSQL**：快速查詢（保留最近 30 天）
- **Redis**：快取最新 1000 筆（即時查看）
- **檔案系統**：長期歸檔（按月分資料夾 + 每日檔案，自動壓縮）
- **stdout**：Docker logs 即時輸出

---

## 🚀 快速開始

### 1. 執行資料庫遷移

首先，應用新的資料庫 schema：

```bash
# 在容器內執行
docker exec -it smartcodex-web flask db upgrade

# 或在本機執行
flask db upgrade
```

### 2. 訪問 Web 介面

啟動應用後，使用管理員帳號登入：

```
URL: http://localhost:7112/admin/logs
```

**功能**：
- 🔍 **搜尋日誌**：關鍵字、時間範圍、日誌級別
- 🔗 **request_id 追蹤**：追蹤單一請求的完整生命週期
- 📊 **統計儀表板**：錯誤趨勢、效能分析、用戶活躍度

---

## 📂 日誌檔案結構

```
logs/
├── 2025-01/                        # 按月分資料夾
│   ├── app_2025-01-27.json.log    # 活躍日誌（未壓縮）
│   ├── app_2025-01-20.json.log.gz # 舊日誌（7天後自動壓縮）
│   └── app_2025-01-19.json.log.gz
└── archive/                        # 歸檔（超過 30 天）
    └── 2024-12/
        ├── app_2024-12-01.json.log.gz
        └── app_2024-12-02.json.log.gz
```

---

## 🔍 日誌查詢方式

### 方式 1：Web 介面（推薦）

訪問 `/admin/logs`，提供：
- 關鍵字搜尋
- 時間範圍篩選
- 日誌級別篩選
- request_id 追蹤
- 用戶 ID 篩選
- 分頁顯示

### 方式 2：Docker Logs（即時）

```bash
# 查看即時日誌
docker logs -f smartcodex-web

# 查看最近 100 行
docker logs --tail 100 smartcodex-web

# 篩選錯誤
docker logs smartcodex-web | grep ERROR
```

### 方式 3：直接讀取檔案

```bash
# 讀取今天的日誌
cat logs/2025-01/app_2025-01-27.json.log | jq .

# 搜尋關鍵字
cat logs/2025-01/app_2025-01-27.json.log | jq 'select(.message | contains("error"))'

# 讀取壓縮檔案
zcat logs/2025-01/app_2025-01-20.json.log.gz | jq .
```

### 方式 4：PostgreSQL 查詢

```sql
-- 查詢最近 1 小時的錯誤
SELECT timestamp, level, message
FROM web_app.application_logs
WHERE timestamp > NOW() - INTERVAL '1 hour'
  AND level IN ('ERROR', 'CRITICAL')
ORDER BY timestamp DESC;

-- 追蹤特定 request_id
SELECT timestamp, level, module, function, message
FROM web_app.application_logs
WHERE request_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
ORDER BY timestamp;

-- 最慢的 API 端點
SELECT path, AVG(elapsed_time_ms) as avg_time, COUNT(*) as count
FROM web_app.application_logs
WHERE elapsed_time_ms IS NOT NULL
  AND timestamp > NOW() - INTERVAL '24 hours'
GROUP BY path
ORDER BY avg_time DESC
LIMIT 10;
```

---

## 🗂️ 日誌歸檔與清理

### 自動歸檔（建議每天執行）

```bash
# 歸檔超過 30 天的日誌（預設）
docker exec smartcodex-web python /app/scripts/archive_logs.py --archive

# 自訂保留天數
docker exec smartcodex-web python /app/scripts/archive_logs.py --archive --days 60

# 測試模式（不實際刪除）
docker exec smartcodex-web python /app/scripts/archive_logs.py --archive --dry-run
```

**執行結果**：
1. 從 PostgreSQL 匯出舊日誌到檔案（gzip 壓縮）
2. 刪除資料庫中的舊日誌
3. 按月分資料夾儲存

### 清理超過 1 年的歸檔

```bash
# 刪除超過 365 天的歸檔檔案
docker exec smartcodex-web python /app/scripts/archive_logs.py --cleanup

# 自訂保留天數
docker exec smartcodex-web python /app/scripts/archive_logs.py --cleanup --archive-days 180
```

### 設定 Cron 定期任務

在主機上設定 cron（每天凌晨 2 點執行）：

```bash
crontab -e

# 新增以下行
0 2 * * * docker exec smartcodex-web python /app/scripts/archive_logs.py --archive
0 3 * * 0 docker exec smartcodex-web python /app/scripts/archive_logs.py --cleanup
```

---

## 📊 統計與分析

### Web 儀表板

訪問 `/admin/logs/stats` 查看：
- **錯誤統計**：錯誤類型分布、錯誤趨勢
- **效能分析**：平均響應時間、最慢的 API
- **用戶活躍度**：最活躍的用戶

### API 端點

```bash
# 取得錯誤統計（最近 24 小時）
curl -X GET "http://localhost:7112/admin/logs/api/stats/errors?hours=24"

# 取得效能統計
curl -X GET "http://localhost:7112/admin/logs/api/stats/performance?hours=24"

# 取得用戶活躍度
curl -X GET "http://localhost:7112/admin/logs/api/stats/users?hours=24"

# 取得統計概覽
curl -X GET "http://localhost:7112/admin/logs/api/stats/overview?hours=24"
```

---

## 🔧 進階配置

### 環境變數

在 `docker-compose.yml` 或 `.env` 中設定：

```yaml
environment:
  - LOG_DIR=/app/logs                 # 日誌目錄
  - LOG_RETENTION_DAYS=30             # PostgreSQL 保留天數
```

### 應用程式內部使用

```python
from flask import current_app

# 記錄資訊
current_app.logger.info("使用者登入", extra={
    'extra_fields': {
        'user_id': user.id,
        'event': 'user_login'
    }
})

# 記錄錯誤（自動捕捉 exception）
try:
    risky_operation()
except Exception as e:
    current_app.logger.error(f"操作失敗: {str(e)}", exc_info=True)
```

---

## 📈 效能考量

### 資料庫大小控制

- **PostgreSQL**：保留 30 天，自動刪除舊資料
- **Redis**：只保留最新 1000 筆
- **檔案**：壓縮後節省 70-80% 空間

### 查詢效能優化

1. **使用索引**：timestamp、level、request_id、user_id 都有索引
2. **全文搜尋**：使用 PostgreSQL FTS（GIN 索引）
3. **Redis 快取**：熱門查詢快取 10 分鐘
4. **分頁查詢**：每頁 100 筆，避免記憶體爆炸

### 容量估算

假設：
- 每秒 10 個請求
- 每筆日誌 1KB

**30 天容量**：
```
10 req/s × 86400 s × 30 days × 1KB = ~25 GB
```

**1 年歸檔**（壓縮後）：
```
25 GB × 12 months × 0.2 (壓縮率) = ~60 GB
```

---

## 🐛 故障排除

### 問題 1：日誌沒有寫入 PostgreSQL

**檢查**：
```bash
# 檢查資料庫連線
docker exec smartcodex-web flask shell
>>> from app import db
>>> db.engine.execute('SELECT 1').scalar()
```

**解決**：
- 確認資料庫遷移已執行
- 檢查 `APPLICATION_LOG` 權限
- 查看應用啟動日誌

### 問題 2：檔案日誌沒有產生

**檢查**：
```bash
# 檢查 logs 目錄權限
docker exec smartcodex-web ls -la /app/logs

# 檢查配置
docker exec smartcodex-web printenv | grep LOG
```

**解決**：
- 確認 `LOG_DIR` 環境變數
- 檢查目錄寫入權限
- 查看 `app/__init__.py:97` 的 `output_to_file=True`

### 問題 3：Web 介面無法訪問

**檢查**：
- 確認用戶有管理員權限（`is_admin=True`）
- 檢查路由是否正確註冊
- 查看瀏覽器 Console 錯誤

---

## 📝 最佳實踐

1. **定期歸檔**：每天執行歸檔腳本
2. **監控磁碟空間**：確保有足夠空間儲存日誌
3. **設定告警**：當錯誤數超過閾值時發送通知（未來功能）
4. **定期備份**：歸檔檔案可移至雲端儲存
5. **效能監控**：定期查看統計儀表板

---

## 🔗 相關文件

- [資料庫 Schema](./database/04_Schema_WebApp_Tables.md)
- [JSON Logger 設計](../app/utils/json_logger.py)
- [Middleware 說明](../app/middleware/logging_middleware.py)

---

## 📞 支援

如有問題，請聯繫系統管理員或提交 Issue。
