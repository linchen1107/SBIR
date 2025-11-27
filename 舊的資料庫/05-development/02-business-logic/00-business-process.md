# 核心業務流程圖 (As-Is vs. To-Be)

本文件使用 Mermaid 語法，描繪導入本平台前後的核心業務流程，以呈現系統的核心價值。

## 1. 現行工作流程 (As-Is): 手動搭配 ChatGPT

本圖描繪在導入本平台前，使用者接收到申編需求後，利用外部 ChatGPT 輔助判斷的現行手動處理流程。

```mermaid
graph TD
    subgraph "現行工作流程 (As-Is)"
        A[開始: 收到廠商BOM表] --> B[取得產品中英文品名<br/>與廠家代號];
        B --> C{使用廠家代號<br/>至外部網站查詢現有料號};
        C --> D{查詢結果};
        D -- "找到符合的現有料號" --> E[流程結束];
        D -- "未找到符合料號" --> F[進入手動料號申編程序];
        F --> G{使用 ChatGPT 輔助判斷};
        G --> H["將產品品名與國軍FSC規格<br/>手動貼入 ChatGPT"];
        H --> I["ChatGPT 推薦最可能的 FSC 分類"];
        I --> J["人員根據推薦的 FSC<br/>從H6撈取所有 INC 列表"];
        J --> K["將 INC 列表與產品品名<br/>再次手動貼入 ChatGPT"];
        K --> L["ChatGPT 推薦最匹配的 INC"];
        L --> M{人員最終驗證};
        M -- "驗證通過" --> N[手動填寫 Word / Excel<br/>申編單];
        M -- "驗證失敗" --> O[返回步驟 G 或<br/>依賴純人工經驗判斷];
        N --> P[完成申編作業];
    end
```

---

## 2. 導入本平台後的工作流程 (To-Be)

本圖描繪導入本平台後，預期的全新工作流程。從收到資料開始，所有查詢與申編作業都將在本平台內一站式完成。

```mermaid
graph TD
    subgraph "導入本平台後的工作流程 (To-Be)"
        A[開始: 收到廠商BOM表] --> B[登入本平台];
        B --> C["使用平台「現有料號查詢」功能<br/>(可依廠家代號、關鍵字等搜尋)"];
        C --> D{平台回傳查詢結果};
        D -- "找到符合的現有料號" --> E[流程結束];
        D -- "未找到符合料號" --> F["接續執行平台「料號申編」程序<br/>(詳見下方詳細流程)"];
        F --> G[系統引導使用者完成申編單<br/>並根據搜尋結果預填資料];
        G --> H[使用者確認後提交<br/>系統存檔並產出制式 Word 檔案];
        H --> I[完成申編作業];
    end
```

---

## 2.1. 平台申編詳細流程

此流程是使用者在本平台內透過關鍵字或代碼，交叉查詢資料庫，最終找到目標品名 (INC) 以進行申編的標準作業程序。

```mermaid
graph TD
    subgraph "平台整合搜尋與申編詳細流程"
        Start["開始<br/>進入料號搜尋頁面"] --> SearchPage["統一搜尋頁面<br/>(提供一般與進階搜尋)"];
        SearchPage --> UserSearches{使用者輸入關鍵字<br/>執行搜尋};
        UserSearches --> ShowMixedResults["顯示混合結果列表<br/>(FSC, INC, NATO H6)"];
        
        ShowMixedResults --> UserSelectsItem{"使用者點擊任一結果"};
        
        UserSelectsItem -- "點擊 FSC" --> ShowFSCRelations["顯示 FSC 細節<br/>及其關聯的 INC 與 H6"];
        UserSelectsItem -- "點擊 INC" --> ShowINCRelations["顯示 INC 細節<br/>及其關聯的 FSC 與 H6"];
        UserSelectsItem -- "點擊 NATO H6" --> ShowH6Relations["顯示 H6 細節<br/>及其關聯的 INC"];
        
        ShowFSCRelations --> UserFindsINC["使用者從關聯列表中<br/>找到並選擇目標 INC"];
        ShowINCRelations --> UserSelectsINC["使用者確認此 INC"];
        ShowH6Relations --> UserFindsINC;
    
        UserFindsINC --> FillForm["填寫申編單"];
        UserSelectsINC --> FillForm;
    
        FillForm --> AutoFill["系統預填欄位<br/>(品名, INC, FIIG...)"];
        AutoFill --> AutoSerial["系統自動產生建議表單編號<br/>(e.g., A0001)"];
        AutoSerial --> UserEdit["使用者確認或修改表單內容<br/>(包含可選填的表單編號)"];
        UserEdit --> SubmitForm{"提交申編單"};
    
        SubmitForm --> SaveData["儲存申編單資料至<br/>web_app.applications"];
        
        SaveData -- "包含: unique_key(不再唯一), form_serial(使用者版), official_nsn(預留)" --> GenerateWord["完成頁面<br/>提供 Word 檔案下載"];
        GenerateWord --> EndProcess["結束"];
    end
```
