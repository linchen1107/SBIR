# 開發指南

本目錄包含開發過程中需要的技術指南，包括測試策略、日誌系統和業務邏輯說明。

## 📚 文檔列表

| 檔案名稱 | 內容摘要 |
|----------|----------|
| [00-testing-strategy.md](00-testing-strategy.md) | 從整合測試演進至 Mocked 單元測試的核心策略與優勢 |
| [01-logging-system.md](01-logging-system.md) | 日誌系統架構與使用指南 |
| [02-business-logic/00-business-process.md](02-business-logic/00-business-process.md) | 系統核心業務流程圖，包含 NSN 查詢與料號申編流程 |
| [02-business-logic/01-approval-workflow.md](02-business-logic/01-approval-workflow.md) | 審批流程說明 |

## 🎯 開發工具

### 查看日誌
```bash
# 即時查看應用程式日誌
docker-compose logs -f web

# 查看資料庫日誌
docker-compose logs -f db
```
📖 [詳細說明](01-logging-system.md)

### 執行測試
```bash
# 執行單元測試
docker-compose exec web pytest tests/
```
📖 [詳細說明](00-testing-strategy.md)

## 📖 閱讀建議

- **新加入的開發者**: 先閱讀 [02-business-logic/00-business-process.md](02-business-logic/00-business-process.md) 了解業務流程
- **撰寫測試**: 參考 [00-testing-strategy.md](00-testing-strategy.md)
- **調試問題**: 參考 [01-logging-system.md](01-logging-system.md) 查看日誌

---

[返回文檔首頁](../README.md)
