# 申編單模板系統設計文件

> **建立日期**: 2025-01-XX
> **版本**: 1.0
> **狀態**: Phase 1 已實作（前端 localStorage）

---

## 📋 目錄

1. [功能概述](#功能概述)
2. [目前實作（Phase 1）](#目前實作phase-1)
3. [資料結構](#資料結構)
4. [前端實作細節](#前端實作細節)
5. [後端整合規劃（Phase 2）](#後端整合規劃phase-2)
6. [未來擴充功能](#未來擴充功能)
7. [升級路徑](#升級路徑)
8. [常見問題](#常見問題)

---

## 功能概述

### 需求背景

在填寫海軍料號申編單時，許多欄位（例如：單位會計編號、系統代號、艦型等）在同一單位或同一專案中通常是固定的。為了提升使用者填寫效率，設計了**模板系統**，讓使用者能夠：

1. **快速套用預設值** - 一鍵填入常用欄位
2. **儲存常用設定** - 將常填的欄位組合儲存為模板（未來實作）
3. **管理多個模板** - 支援不同專案/單位的多組設定（未來實作）

### 核心功能（Phase 1）

- ✅ **模板套用** - 點擊「套用」按鈕，自動填入 17 個欄位
- ✅ **預設模板** - 系統預設提供「模板1」
- ✅ **模板選擇彈窗** - 卡片式設計，支援 hover 顯示操作按鈕
- ✅ **localStorage 儲存** - 資料存在使用者瀏覽器（無需後端）

### 預留功能（Phase 2+）

- 🔄 儲存新模板（從目前表單收集資料）
- 🔄 編輯模板名稱
- 🔄 刪除模板
- 🔄 設定預設模板（開啟表單時自動套用）
- 🔄 後端 API 整合（跨裝置同步）
- 🔄 模板分享（管理員功能）

---

## 目前實作（Phase 1）

### UI 設計

#### 1. 標題區域

```
┌────────────────────────────────────────────────────┐
│                                                     │
│       海軍料號申編單 (3rem 大標題)        [選擇模板] │
│       ─────────────────                             │
│                                                     │
└────────────────────────────────────────────────────┘
```

- 標題字體放大到 `3rem`
- 右側新增「選擇模板」按鈕
- 使用 `position: relative` + `absolute` 佈局

#### 2. 模板選擇彈窗

```
┌─────────────────────────────────────────────┐
│  選擇模板                              [×]   │
│─────────────────────────────────────────────│
│                                              │
│  ┌──────────────┐  ┌──────────────┐        │
│  │ 📄 模板1      │  │ 📄 模板2      │        │
│  │ 2025/01/15   │  │ (未來擴充)    │        │
│  │ 包含 17 欄位 │  │               │        │
│  │              │  │               │        │
│  │ [Hover顯示]  │  │               │        │
│  │ ┌─────────┐ │  │               │        │
│  │ │ ✓ 套用  │ │  │               │        │
│  │ │ 💾 儲存 │ │  │               │        │
│  │ │ 🗑️ 刪除 │ │  │               │        │
│  │ └─────────┘ │  │               │        │
│  └──────────────┘  └──────────────┘        │
│                                              │
└─────────────────────────────────────────────┘
```

### 使用流程

1. 使用者點擊「選擇模板」按鈕
2. 開啟模板選擇彈窗，顯示「模板1」卡片
3. 滑鼠移到卡片上，顯示「套用」按鈕（儲存/刪除按鈕已預留但註解掉）
4. 點擊「套用」
5. 自動填入 17 個表單欄位
6. 彈窗關閉，顯示成功訊息

---

## 資料結構

### 模板物件格式

```javascript
{
  id: 'template_1',              // 唯一識別碼
  name: '模板1',                  // 模板名稱
  created_at: '2025-01-15T10:30:00.000Z',  // 建立時間（ISO 8601）
  updated_at: '2025-01-15T14:20:00.000Z',  // 更新時間（可選）
  data: {                         // 表單欄位資料
    accounting_unit_code: 'B21317',
    issue_unit: 'EA',
    unit_price: '20000.00',
    spec_indicator: 'E',
    unit_pack_quantity: '1',
    storage_life_months: '0',
    storage_life_action_code: '00',
    storage_type_code: 'R',
    secrecy_code: 'U',
    expendability_code: 'N',
    repairability_code: '9',
    manufacturability_code: 'E',
    source_code: '5',
    system_code: 'C35',
    category_code: 'E',
    pn_acquisition_level: '2',
    pn_acquisition_source: '3'
  }
}
```

### 欄位說明

| 欄位名稱 | 中文名稱 | 資料型態 | 說明 |
|---------|---------|---------|------|
| `accounting_unit_code` | 單位會計編號 | String | 例如：B21317 |
| `issue_unit` | 撥發單位 | String | 選單值：EA |
| `unit_price` | 美金單價 | String | 數字，例如：20000.00 |
| `spec_indicator` | 規格指示 | String | 選單值：E |
| `unit_pack_quantity` | 單位包裝量 | String | 選單值：1 |
| `storage_life_months` | 存儲壽限 | String | 選單值：0 |
| `storage_life_action_code` | 壽限處理 | String | 選單值：00 |
| `storage_type_code` | 儲存型式 | String | 選單值：R |
| `secrecy_code` | 機密性代號 | String | 選單值：U |
| `expendability_code` | 消耗性代號 | String | 選單值：N |
| `repairability_code` | 修理能量 | String | 選單值：9 |
| `manufacturability_code` | 製造能量 | String | 選單值：E |
| `source_code` | 來源代號 | String | 選單值：5 |
| `system_code` | 系統代號 | String | 例如：C35 |
| `category_code` | 檔別代號 | String | 選單值：E |
| `pn_acquisition_level` | P/N獲得程度 | String | 例如：2 |
| `pn_acquisition_source` | P/N獲得來源 | String | 例如：3 |

### localStorage 儲存格式

**儲存鍵**: `application_form_templates`

**值**: JSON 字串（模板陣列）

```json
[
  {
    "id": "template_1",
    "name": "模板1",
    "created_at": "2025-01-15T10:30:00.000Z",
    "data": { ... }
  },
  {
    "id": "template_2",
    "name": "艦用電機系統",
    "created_at": "2025-01-16T09:00:00.000Z",
    "data": { ... }
  }
]
```

---

## 前端實作細節

### 檔案位置

- **HTML/CSS/JS**: `app/templates/application/application_form.html`
  - 行 1240-1256: 標題區域
  - 行 1689-1720: 模板選擇彈窗 HTML
  - 行 1218-1375: CSS 樣式
  - 行 4240-4586: JavaScript 模板管理器

### JavaScript 模組：TemplateManager

#### 主要方法

| 方法名稱 | 功能 | 實作狀態 |
|---------|------|---------|
| `init()` | 初始化模板管理器 | ✅ |
| `ensureDefaultTemplate()` | 確保預設模板存在 | ✅ |
| `bindEvents()` | 綁定按鈕事件 | ✅ |
| `openTemplateModal()` | 開啟模板選擇彈窗 | ✅ |
| `renderTemplateList()` | 渲染模板卡片列表 | ✅ |
| `createTemplateCard(template)` | 建立單一模板卡片 HTML | ✅ |
| `bindCardEvents()` | 綁定卡片按鈕事件 | ✅ |
| `applyTemplate(templateId)` | 套用模板到表單 | ✅ |
| `getTemplates()` | 從 localStorage 讀取模板 | ✅ |
| `saveTemplate(template)` | 儲存模板到 localStorage | ✅ |
| `deleteTemplate(templateId)` | 刪除模板（已實作但未啟用） | 🔄 |
| `saveCurrentFormAsTemplate(name)` | 儲存目前表單為模板 | 🔄 預留 |
| `editTemplateName(id, name)` | 編輯模板名稱 | 🔄 預留 |
| `setDefaultTemplate(id)` | 設定預設模板 | 🔄 預留 |
| `syncWithBackend()` | 與後端同步 | 🔄 預留 |

#### 套用邏輯

```javascript
applyTemplate(templateId) {
  // 1. 從 localStorage 取得模板
  const template = this.getTemplates().find(t => t.id === templateId);

  // 2. 遍歷所有欄位
  Object.entries(template.data).forEach(([fieldName, value]) => {
    const input = document.getElementById(fieldName);

    // 3. 根據元素類型設定值
    if (input.tagName === 'SELECT') {
      // 下拉選單：檢查選項是否存在
      const option = Array.from(input.options).find(opt => opt.value === value);
      if (option) {
        input.value = value;
      }
    } else {
      // 一般 input：直接設定
      input.value = value;
    }
  });

  // 4. 關閉彈窗
  modal.hide();

  // 5. 顯示成功訊息
  toastManager.showToast('success', '已套用模板');
}
```

### CSS 重點樣式

#### 模板卡片

```css
.template-card {
  background: linear-gradient(135deg, rgba(0, 212, 255, 0.08), rgba(0, 150, 200, 0.05));
  border: 2px solid rgba(0, 212, 255, 0.3);
  border-radius: 12px;
  min-height: 180px;
  transition: all 0.3s ease;
}

.template-card:hover {
  border-color: #00d4ff;
  box-shadow: 0 8px 24px rgba(0, 212, 255, 0.3);
  transform: translateY(-5px);
}
```

#### Hover 操作按鈕

```css
.template-card-actions {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.85);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.template-card:hover .template-card-actions {
  opacity: 1;
}
```

---

## 後端整合規劃（Phase 2）

### API 端點設計

#### 1. 取得使用者的所有模板

```
GET /api/application/templates
```

**Response:**
```json
{
  "success": true,
  "templates": [
    {
      "id": "uuid-1",
      "name": "模板1",
      "created_at": "2025-01-15T10:30:00Z",
      "updated_at": "2025-01-15T14:20:00Z",
      "data": { ... }
    }
  ]
}
```

#### 2. 儲存新模板

```
POST /api/application/templates
Content-Type: application/json

{
  "name": "新模板",
  "data": {
    "accounting_unit_code": "B21317",
    ...
  }
}
```

**Response:**
```json
{
  "success": true,
  "template_id": "uuid-new",
  "message": "模板已儲存"
}
```

#### 3. 更新模板

```
PUT /api/application/templates/<template_id>
Content-Type: application/json

{
  "name": "更新的名稱",
  "data": { ... }
}
```

#### 4. 刪除模板

```
DELETE /api/application/templates/<template_id>
```

**Response:**
```json
{
  "success": true,
  "message": "模板已刪除"
}
```

### 資料表設計

使用現有的 `web_app.user_settings` 表：

| 欄位 | 類型 | 說明 |
|-----|------|------|
| `setting_id` | UUID | 主鍵 |
| `user_id` | UUID | 外鍵 (users.id) |
| `setting_key` | String(100) | 例如：`application_form_template_<uuid>` |
| `setting_value` | Text | JSON 格式的模板資料 |
| `created_at` | DateTime | 建立時間 |
| `updated_at` | DateTime | 更新時間 |

**範例資料:**

```sql
INSERT INTO web_app.user_settings (setting_id, user_id, setting_key, setting_value)
VALUES (
  gen_random_uuid(),
  'user-uuid',
  'application_form_template_abc123',
  '{"template_name": "模板1", "template_data": {...}}'
);
```

### 前端升級步驟

當後端 API 完成後，只需修改以下 3 處：

**1. `getTemplates()` 方法**

```javascript
// 原本：
getTemplates() {
  const data = localStorage.getItem(this.STORAGE_KEY);
  return data ? JSON.parse(data) : [];
}

// 改為：
async getTemplates() {
  const response = await fetch('/api/application/templates');
  const data = await response.json();
  return data.success ? data.templates : [];
}
```

**2. `saveTemplate()` 方法**

```javascript
// 原本：
saveTemplate(template) {
  const templates = this.getTemplates();
  templates.push(template);
  localStorage.setItem(this.STORAGE_KEY, JSON.stringify(templates));
}

// 改為：
async saveTemplate(template) {
  const response = await fetch('/api/application/templates', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(template)
  });
  return await response.json();
}
```

**3. `deleteTemplate()` 方法**

```javascript
// 原本：
deleteTemplate(templateId) {
  let templates = this.getTemplates();
  templates = templates.filter(t => t.id !== templateId);
  localStorage.setItem(this.STORAGE_KEY, JSON.stringify(templates));
}

// 改為：
async deleteTemplate(templateId) {
  const response = await fetch(`/api/application/templates/${templateId}`, {
    method: 'DELETE'
  });
  return await response.json();
}
```

---

## 未來擴充功能

### Phase 2：完整模板管理

- [ ] 新增「儲存為模板」按鈕（在表單底部）
- [ ] 啟用「刪除」按鈕（需確認對話框）
- [ ] 啟用「編輯名稱」功能（inline 編輯或彈窗）

### Phase 3：進階功能

- [ ] 設定「預設模板」（開啟表單時自動套用）
- [ ] 模板標籤/分類（例如：艦型、系統）
- [ ] 模板使用統計（最常用的模板）
- [ ] 模板預覽（不套用，只查看內容）

### Phase 4：協作功能

- [ ] 模板匯出/匯入（JSON 檔案）
- [ ] 模板分享（管理員建立公用模板）
- [ ] 模板版本控制（追蹤修改歷史）

---

## 升級路徑

### 從 Phase 1 升級到 Phase 2（後端整合）

**步驟：**

1. **建立後端 API**
   - 新增 `app/application/api.py`（或在 `routes.py` 中新增）
   - 實作 4 個端點（GET, POST, PUT, DELETE）

2. **修改前端 JavaScript**
   - 將 `localStorage` 呼叫改為 `fetch()` API 呼叫
   - 處理非同步（async/await）
   - 加上錯誤處理

3. **資料遷移（可選）**
   - 提供工具讓使用者將 localStorage 資料匯出
   - 匯入到資料庫

4. **測試**
   - 確保新增/刪除/套用功能正常
   - 測試跨裝置同步

**預計工作量**: 4-6 小時

---

## 常見問題

### Q1: 為什麼先用 localStorage 而不直接做後端？

**A**:
- **快速驗證** - 先讓功能運作，確認使用者需求
- **降低複雜度** - 不需資料庫遷移，不需後端開發
- **漸進式升級** - 程式碼已預留 API 介面，升級只需改 3 行

### Q2: localStorage 的資料會遺失嗎？

**A**:
- 是的，清除瀏覽器資料會遺失
- 但目前階段只有 1 個預設模板，即使遺失也會自動重建
- Phase 2 升級後會同步到後端，不會遺失

### Q3: 如何新增更多預設模板？

**A**:
修改 `DEFAULT_TEMPLATE` 物件，或在 `ensureDefaultTemplate()` 中新增多個模板：

```javascript
ensureDefaultTemplate() {
  const templates = this.getTemplates();

  if (templates.length === 0) {
    this.saveTemplate(this.DEFAULT_TEMPLATE);
    this.saveTemplate({
      id: 'template_2',
      name: '模板2',
      created_at: new Date().toISOString(),
      data: { ... }
    });
  }
}
```

### Q4: 可以跨瀏覽器使用嗎？

**A**:
- **Phase 1**: 不行，localStorage 是瀏覽器獨立的
- **Phase 2**: 可以，資料存在後端伺服器

### Q5: 如何測試刪除/編輯功能？

**A**:
在瀏覽器 Console 中執行：

```javascript
// 取得 TemplateManager 實例（假設已初始化）
const tm = TemplateManager;

// 測試刪除
tm.deleteTemplate('template_1');
tm.renderTemplateList();

// 測試編輯（未來實作）
// tm.editTemplateName('template_1', '新名稱');
```

---

## 技術筆記

### 為何使用 `data-template-id` 而不是 `id`？

使用 `data-*` 屬性而非 HTML `id` 是因為：
- HTML `id` 必須唯一，但模板 ID 可能重複（例如在多個地方顯示）
- `data-*` 更語意化，清楚表達「這是資料屬性」
- 方便 JavaScript 選擇器：`querySelector('[data-template-id="..."]')`

### 為何使用箭頭函數而非 `function`？

```javascript
// 使用箭頭函數
openBtn.addEventListener('click', () => {
  this.openTemplateModal();
});

// 而非
openBtn.addEventListener('click', function() {
  this.openTemplateModal();  // ❌ this 會指向 openBtn
});
```

箭頭函數保留 `this` 綁定到 `TemplateManager` 物件。

### 安全性考量

1. **XSS 防護** - 使用 `textContent` 而非 `innerHTML` 顯示使用者輸入
2. **CSRF 保護** - 後端 API 需要加上 CSRF token
3. **權限控制** - 只能存取自己的模板（user_id 驗證）

---

## 結語

本文件記錄了申編單模板系統的完整設計與實作細節。隨著系統演進，請持續更新此文件。

**最後更新**: 2025-01-XX
**維護者**: Claude Code Assistant
**參考資料**:
- `app/templates/application/application_form.html`
- 使用者需求討論記錄
