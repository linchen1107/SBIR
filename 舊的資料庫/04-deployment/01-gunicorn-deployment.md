# Gunicorn 部署指南

本文件說明如何使用 **Gunicorn** 作為 WSGI (Web Server Gateway Interface) 伺服器來部署 SmartCodexAI 應用程式。Gunicorn 是一個成熟、高效能的 Python WSGI HTTP 伺服器，專為生產環境設計。

---

## 核心組件

我們的部署架構主要依賴以下三個核心檔案：

1.  **`Dockerfile`**: 定義應用程式的容器化環境，並指定 Gunicorn 作為啟動指令。
2.  **`gunicorn.conf.py`**: Gunicorn 的設定檔，用於調整伺服器行為，例如綁定 IP、工作進程數量等。
3.  **`wsgi.py`**: 應用程式的 WSGI 進入點，負責建立並提供 Flask `app` 實例給 Gunicorn 使用。

---

## 1. `Dockerfile` - 啟動指令

在 `Dockerfile` 中，我們使用 `CMD` 指令來啟動 Gunicorn 伺服器。這是容器運行時的預設指令。

```dockerfile
# ... (其他 Dockerfile 設定)

# 開放容器的 5000 埠
EXPOSE 5000

# 容器啟動時的預設指令
# 使用 Gunicorn 作為正式環境的 WSGI 伺服器
# -c: 指定 Gunicorn 的設定檔
# wsgi:app: 執行 wsgi.py 檔案中的 app 實例
CMD ["gunicorn", "-c", "gunicorn.conf.py", "wsgi:app"]
```

**指令解析**:
-   `gunicorn`: 執行 Gunicorn 伺服器。
-   `-c gunicorn.conf.py`: 告訴 Gunicorn 使用 `gunicorn.conf.py` 這個檔案作為其設定來源。
-   `wsgi:app`: 指示 Gunicorn 從 `wsgi.py` 模組中找到名為 `app` 的變數作為 WSGI 應用程式。

---

## 2. `gunicorn.conf.py` - 伺服器設定

這個檔案讓我們可以集中管理 Gunicorn 的所有設定，而不需要將它們寫死在 `Dockerfile` 中。

```python
# gunicorn.conf.py
import multiprocessing

# -- Server Socket --
# '0.0.0.0' 使應用程式可以從容器外部存取
bind = "0.0.0.0:5000"

# -- Worker Processes --
# 動態設定工作進程數量，公式為 (2 * CPU 核心數) + 1
workers = multiprocessing.cpu_count() * 2 + 1
# 使用同步工作模式 (sync)，適用於 Flask 等 WSGI 應用
worker_class = "sync"
# 工作進程處理請求的超時時間（秒）
timeout = 300

# -- Logging --
# 日誌等級
loglevel = "info"
# 將日誌導向標準輸出，方便 Docker 收集
accesslog = "-"
errorlog = "-"
```

**主要設定**:
-   `bind`: 設定 Gunicorn 監聽所有網路介面的 `5000` 埠。
-   `workers`: 動態設定工作進程數量，使用 `(2 * CPU 核心數) + 1` 公式以獲得最佳效能。
-   `worker_class`: 指定使用 `sync` 同步工作模式，這是執行 Flask (WSGI) 應用的標準選擇。
-   `timeout`: 設定工作進程的超時時間為 300 秒。這對於處理如網路爬蟲等長時間執行的請求至關重要，可防止 Gunicorn 因超時而中斷它們。
-   `accesslog` / `errorlog`: 將存取日誌和錯誤日誌都導向標準輸出 (`-`)，這是容器化環境的最佳實踐，可以透過 `docker logs` 指令查看。

---

## 3. `wsgi.py` - 應用程式進入點

`wsgi.py` 是一個簡單的 Python 腳本，其唯一目的是建立一個可供 Gunicorn 使用的 Flask 應用程式實例。

```python
"""
WSGI entry point for Gunicorn
"""
import os
from app import create_app

# The Gunicorn server will import this 'app' variable
app = create_app(os.getenv('FLASK_ENV') or 'development')
```

**運作方式**:
1.  Gunicorn 啟動時，會匯入這個 `wsgi.py` 檔案。
2.  它會尋找一個名為 `app` 的變數。
3.  `create_app()` 工廠函式會被呼叫，並根據環境變數 (`FLASK_ENV`) 建立一個設定好的 Flask `app` 實例。
4.  Gunicorn 接收這個 `app` 物件，並開始處理傳入的 HTTP 請求。

---

## 總結

透過這三個檔案的協同工作，我們實現了一個標準化且易於管理的生產環境部署流程：

-   `Dockerfile` 負責**啟動**。
-   `gunicorn.conf.py` 負責**設定伺服器**。
-   `wsgi.py` 負責**提供應用程式實例**。

這種分離的架構讓我們的部署流程更加清晰、靈活且易於維護。
