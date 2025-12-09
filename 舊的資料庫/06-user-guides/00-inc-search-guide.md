# INC 搜尋功能使用指南

## 📖 系統簡介

智動料號申編暨查詢系統提供強大的 INC (Item Name Code，物品名稱代碼) 搜尋功能，支援多種查詢方式和智能容錯，讓您輕鬆找到所需的物料品項。

### 🎯 核心能力

- ✅ **精確查詢**: 支援 5 位數 INC 代碼直接查詢
- ✅ **關鍵字搜尋**: 輸入任意關鍵詞即可找到相關品項
- ✅ **完整名稱查詢**: 支援各種格式的完整品名輸入
- ✅ **智能容錯**: 自動處理標點符號、空格、大小寫差異
- ✅ **俗名解析**: 自動將俗稱對應到正式品項
- ✅ **組合查詢**: FSC 分類 + INC 品名組合搜尋

---

## 🔍 基礎搜尋方式

### 1️⃣ 精確 INC 代碼查詢

**適用情境**: 已知確切的 INC 代碼

#### 使用方法
```
在「INC 品名」欄位輸入 5 位數字代碼
```

#### 範例 1: 查詢 TIMER
```
輸入: 04879

結果:
✅ INC 04879: TIMER, ELECTRONIC, INTERVAL
   FSC: 6645 - TIME MEASURING INSTRUMENTS
```

#### 範例 2: 查詢 EJECTOR
```
輸入: 17566

結果:
✅ INC 17566: EJECTOR, JET
   FSC: 4320 - POWER AND HAND PUMPS
```

#### 特點
- ⚡ 查詢速度最快 (< 5 毫秒)
- ✅ 精確匹配，只返回一筆結果
- 🎯 適合已知代碼的情況

---

### 2️⃣ 單一詞彙查詢

**適用情境**: 只記得品項名稱的某個詞彙

#### 使用方法
```
在「INC 品名」欄位輸入單一關鍵字
```

#### 範例 1: 查詢包含 "timer" 的品項
```
輸入: timer

結果:
✅ 找到 3 筆結果
   - INC 04879: TIMER, ELECTRONIC, INTERVAL
   - INC 04880: TIMER, MECHANICAL
   - INC 04881: TIMER, PNEUMATIC
```

#### 範例 2: 查詢包含 "pump" 的品項
```
輸入: pump

結果:
✅ 找到 15 筆結果
   - INC 12345: PUMP, CENTRIFUGAL
   - INC 12346: PUMP, HAND
   - ... (其他包含 pump 的品項)
```

#### 特點
- 🔍 部分匹配，可能返回多筆結果
- 💡 適合探索性搜尋
- ⚠️ 關鍵字越具體，結果越精確

---

### 3️⃣ 完整名稱查詢

**適用情境**: 知道完整品項名稱

#### 支援的輸入格式

| 格式 | 範例 | 是否支援 |
|-----|------|---------|
| 標準格式（逗號+空格） | `TIMER, ELECTRONIC, INTERVAL` | ✅ |
| 空格分隔 | `TIMER ELECTRONIC INTERVAL` | ✅ |
| 無空格逗號 | `TIMER,ELECTRONIC,INTERVAL` | ✅ |
| 無任何分隔 | `TIMERELECTRONICINTERVAL` | ✅ |
| 多餘空格 | `TIMER  ,  ELECTRONIC` | ✅ |
| 小寫 | `timer, electronic, interval` | ✅ |
| 混合大小寫 | `Timer, Electronic` | ✅ |

#### 範例: 查詢 TIMER, ELECTRONIC, INTERVAL

**輸入任一格式**:
```
✅ TIMER, ELECTRONIC, INTERVAL
✅ TIMER ELECTRONIC INTERVAL
✅ TIMER,ELECTRONIC,INTERVAL  ← 🆕 新支援
✅ timer electronic interval
✅ timerelectronicinterval
```

**統一結果**:
```
✅ INC 04879: TIMER, ELECTRONIC, INTERVAL
   FSC: 6645 - TIME MEASURING INSTRUMENTS
```

#### 特點
- 🎯 最精確的查詢方式
- 🔧 自動處理各種格式差異
- ✨ 容錯能力極強

---

## 🚀 進階搜尋方式

### 4️⃣ FSC + INC 組合查詢

**適用情境**: 想在特定分類下查詢品項

#### 使用方法
```
FSC 欄位: 輸入 FSC 分類代碼或關鍵字
INC 欄位: 輸入 INC 品名關鍵字
```

#### 範例 1: 在 TIME MEASURING 分類下查詢 clock
```
FSC 輸入: 6645
INC 輸入: clock

結果:
✅ FSC 6645: TIME MEASURING INSTRUMENTS
   - INC 04878: CLOCK, ELECTRIC
   - INC 04879: TIMER, ELECTRONIC, INTERVAL
   - INC 04920: CLOCK, MECHANICAL
```

#### 範例 2: 在 pump 相關分類下查詢 centrifugal
```
FSC 輸入: pump
INC 輸入: centrifugal

結果:
✅ FSC 4320: POWER AND HAND PUMPS
   - INC 12345: PUMP, CENTRIFUGAL
   - INC 12350: PUMP, CENTRIFUGAL, SUBMERSIBLE
```

#### 特點
- 🎯 縮小搜尋範圍，結果更精確
- 💡 適合探索某個分類下的品項
- ⚡ 同樣支援所有容錯格式

---

### 5️⃣ 俗名自動解析

**適用情境**: 使用常用俗稱查詢品項

#### 什麼是俗名？

在實務中，同一個物料可能有多種不同的稱呼方式。系統會自動將俗稱對應到正式的 INC 品項。

#### 範例 1: 使用 "eductor" 查詢

```
輸入: eductor

查詢過程:
1. 系統找到 2 筆包含 "eductor" 的俗名
   - J5907: EDUCTOR
   - J9679: EDUCTOR OIL/WATER,UNION,BRAZED

2. 自動解析為正式 INC
   - 17566: EJECTOR, JET

結果顯示:
✅ INC 17566: EJECTOR, JET
   FSC: 4320 - POWER AND HAND PUMPS

   [ℹ️ 透過 eductor 找到 2 種相關說法]  ← 點擊查看詳情
```

#### 點擊「相關說法」後的 Modal 顯示:

```
╔════════════════════════════════════════╗
║ 相關說法 (INC: 17566)                  ║
╠════════════════════════════════════════╣
║                                        ║
║ 關鍵字 eductor 符合了以下 2 種說法：   ║
║                                        ║
║ • EDUCTOR                              ║
║ • EDUCTOR OIL/WATER,UNION,BRAZED       ║
║                                        ║
╚════════════════════════════════════════╝
```

#### 範例 2: FSC + 俗名組合

```
FSC 輸入: 4320
INC 輸入: eductor

結果:
✅ 在 FSC 4320 範圍內找到
   - INC 17566: EJECTOR, JET
   - [ℹ️ 透過 eductor 找到 2 種相關說法]
```

#### 特點
- 🔍 自動找到正式品項名稱
- 💡 提示所有匹配的俗稱
- ✨ 提升查詢準確度

---

### 6️⃣ 容錯查詢（無空格逗號）🆕

**適用情境**: 快速輸入，不想顧慮格式

#### 問題場景

以前您可能遇到：
```
❌ 輸入: TRAP,MOISTURE      → 找不到結果
✅ 輸入: TRAP, MOISTURE     → 可以找到
```

#### 現在全部支援！

```
✅ TRAP,MOISTURE            ← 無空格
✅ TRAP, MOISTURE           ← 標準格式
✅ TRAP  ,  MOISTURE        ← 多餘空格
✅ trap,moisture            ← 小寫
✅ TRAP.,MOISTURE           ← 其他標點
✅ trapmoisture             ← 完全無分隔
```

**統一結果**:
```
✅ INC 12345: TRAP, MOISTURE
   FSC: 4930 - LUBRICATION AND FUEL DISPENSING EQUIPMENT
```

#### 特點
- 🎯 100% 容錯
- ⚡ 查詢速度極快（索引優化）
- ✨ 使用者體驗最佳

---

## 💡 搜尋技巧與最佳實踐

### ✅ 提高搜尋準確度

#### 技巧 1: 使用多個關鍵詞
```
❌ 不佳: pump
✅ 較好: centrifugal pump
✅ 最佳: centrifugal pump submersible
```

#### 技巧 2: 善用 FSC 篩選
```
❌ 不佳: 直接搜尋 "valve" (可能有數百筆)
✅ 較好: FSC 4810 + "valve" (只在該分類下搜尋)
```

#### 技巧 3: 利用俗名提示
```
💡 如果看到「透過 XXX 找到 N 種相關說法」
   → 點擊查看，了解其他常用說法
   → 下次可以用這些說法查詢
```

---

### ⚠️ 常見問題排除

#### Q1: 輸入關鍵字後沒有結果

**可能原因**:
- ❌ 關鍵字拼寫錯誤
- ❌ 使用了系統中不存在的詞彙

**解決方法**:
- ✅ 檢查拼寫
- ✅ 嘗試使用更通用的詞彙
- ✅ 使用俗名或常見說法

#### Q2: 結果太多，無法找到想要的

**解決方法**:
- ✅ 增加更多關鍵詞
- ✅ 使用 FSC 分類篩選
- ✅ 輸入更完整的品名

#### Q3: 不確定品項的正確名稱

**解決方法**:
- ✅ 先用單一關鍵詞探索
- ✅ 查看俗名提示
- ✅ 從 FSC 分類瀏覽

---

## 📊 查詢組合速查表

### 所有支援的查詢方式

| # | 查詢類型 | FSC 輸入 | INC 輸入 | 範例 | 結果筆數 |
|---|---------|---------|---------|------|---------|
| 1 | 精確代碼 | - | `04879` | 5位數字 | 1 筆 |
| 2 | 單一詞彙 | - | `timer` | 關鍵字 | 多筆 |
| 3 | 完整名稱 | - | `TIMER, ELECTRONIC` | 標準格式 | 1-數筆 |
| 4 | 無空格逗號 | - | `TRAP,MOISTURE` | 🆕 | 1-數筆 |
| 5 | FSC 精確 | `6645` | - | 4位代碼 | 該 FSC 所有 INC |
| 6 | FSC 模糊 | `time` | - | 關鍵字 | 多個 FSC |
| 7 | FSC + INC | `6645` | `clock` | 組合 | 該 FSC 下符合的 INC |
| 8 | 俗名查詢 | - | `eductor` | 俗稱 | 正式 INC + 提示 |
| 9 | FSC + 俗名 | `4320` | `eductor` | 組合 | 該 FSC 下正式 INC |

---

### 查詢效能參考

| 查詢類型 | 平均查詢時間 | 效能等級 |
|---------|-------------|---------|
| 精確 INC 代碼 | < 5 ms | ⚡⚡⚡ 極快 |
| 單一詞彙 | 10-30 ms | ⚡⚡ 很快 |
| 完整名稱 | 10-50 ms | ⚡⚡ 很快 |
| FSC + INC | 30-100 ms | ⚡ 快 |
| 俗名查詢 | 20-80 ms | ⚡⚡ 很快 |

---

### 容錯能力對照表

| 輸入格式 | 舊版本 | 新版本 | 改進 |
|---------|-------|-------|------|
| `TIMER, ELECTRONIC` | ✅ | ✅ | - |
| `TIMER ELECTRONIC` | ✅ | ✅ | - |
| `TIMER,ELECTRONIC` | ❌ | ✅ | 🆕 |
| `TIMER  ,  ELECTRONIC` | ❌ | ✅ | 🆕 |
| `timer,electronic` | ❌ | ✅ | 🆕 |
| `timerelectronic` | ❌ | ✅ | 🆕 |

---

## 🎓 實戰範例

### 範例 1: 尋找電子計時器

**步驟 1**: 嘗試單一關鍵字
```
輸入: timer
結果: 找到 10 筆結果（太多）
```

**步驟 2**: 增加關鍵詞
```
輸入: timer electronic
結果: 找到 3 筆結果
   - INC 04879: TIMER, ELECTRONIC, INTERVAL
   - INC 04880: TIMER, ELECTRONIC, DIGITAL
   - INC 04881: TIMER, ELECTRONIC, ANALOG
```

**步驟 3**: 進一步精確
```
輸入: timer electronic interval
結果: 找到 1 筆結果
   ✅ INC 04879: TIMER, ELECTRONIC, INTERVAL
```

---

### 範例 2: 使用 FSC 分類查詢

**情境**: 想找泵浦相關的離心式設備

**步驟 1**: 查詢 FSC 分類
```
FSC 輸入: pump
結果: 找到 2 個 FSC
   - FSC 4320: POWER AND HAND PUMPS
   - FSC 4330: CENTRIFUGAL AND PUMPS
```

**步驟 2**: 在 FSC 範圍內查詢
```
FSC 輸入: 4320
INC 輸入: centrifugal
結果:
   ✅ FSC 4320 下找到 5 筆結果
      - INC 12345: PUMP, CENTRIFUGAL
      - INC 12346: PUMP, CENTRIFUGAL, SUBMERSIBLE
      ...
```

---

### 範例 3: 使用俗名查詢

**情境**: 只知道俗稱 "eductor"

**步驟 1**: 直接輸入俗稱
```
輸入: eductor
結果:
   ✅ INC 17566: EJECTOR, JET
      [ℹ️ 透過 eductor 找到 2 種相關說法]
```

**步驟 2**: 查看相關說法
```
點擊提示 → 顯示 Modal:
   - EDUCTOR
   - EDUCTOR OIL/WATER,UNION,BRAZED
```

**學到的知識**:
- 💡 正式名稱是 "EJECTOR, JET"
- 💡 可以用 "eductor" 或 "ejector" 查詢
- 💡 還有其他變體說法

---

## 🔗 相關資源

### 系統文件
- 📘 [資料庫架構說明](../database/00_Database_Architecture.md)
- 📘 [INC 與俗名關係](../data_relations/00_INC_Colloquial_Names.md)
- 📘 [搜尋流程設計](../design/04_Colloquial_INC_Search_Flow.md)

### 技術文件（開發者）
- 🔧 [Search_Text 實作指南](../features/search_text_implementation_guide.md)
- 🔧 [完整名稱搜尋功能](../features/inc_full_name_search.md)

---

## 📞 需要協助？

如果您在使用搜尋功能時遇到問題：

1. ✅ 先查看本指南的「常見問題排除」章節
2. ✅ 嘗試不同的關鍵字組合
3. ✅ 使用 FSC 分類縮小範圍
4. ✅ 聯繫系統管理員尋求協助

---

## 📅 更新記錄

- **2025-11-03**: 新增無空格逗號查詢支援
- **2025-11-03**: 新增 search_text 索引優化
- **2025-11-03**: 完善俗名解析功能
- **版本**: v2.0

---

**感謝您使用智動料號申編暨查詢系統！** 🎉
