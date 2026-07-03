# Reference: Knowledge 條目與前後端實作歸屬指南

補充 [SKILL.md](SKILL.md) 的完整名詞解釋、屬性常見歧義、Pros／Cons／Examples、與守備範圍對照表。

## 要解決的問題

- 前端專案中常存在大量 hard-coded 的 domain knowledge（商業規則、狀態推算、權限裁決等）。
- 相同或相近的 domain knowledge 可能在 web-be 也有對應實作，但前後端是否一致往往未被系統性追蹤。
- 前後端實作細節不一致時，容易產生維護成本與 bug（例如前端判斷可操作，後端 API 卻拒絕寫入）。
- 每次 spec change，RD 需重新從 code 盤點現況才能修改，開發效率低落。
- 缺乏客觀的「誰該實作」判定標準，導致技術債累積（如前端拉取 catalog 全貌自行推算、跨實體聚合在 browser 端迴圈計算）。

目標：建立可重複使用的盤點與決策框架，讓 FE／BE／各 client 對「一條 knowledge 的職責與實作歸屬」有客觀共識。

## 名詞解釋

| 類別 | 名詞 | 解釋 |
|---|---|---|
| API / 介面 | dry-run | 寫入路徑上的試跑（概念層）：不（或尚未）改變 SSOT，用於合法性預覽、衝突檢查；驗證邏輯應與 execute API 一致。 |
| API / 介面 | execute API | 後端提供的正式寫入介面（實作層）：驗證後實際更新 database／外部系統狀態，會改變 SSOT。與 dry-run API 相對；承載 mutating request。無論前端是否先走 dry-run，execute 時須完整驗證。 |
| API / 介面 | mutating request | 會改變 SSOT 的正式寫入請求（概念層）；與 dry-run 相對。實作上通常經 execute API 送出；後端必須完整驗證，不可信任前端。 |
| 核心概念 | Knowledge 條目 | 盤點與判定實作歸屬的最小單位：具業務語意、單一職責，且可獨立跑決策樹的一條規則／知識點記載。 |
| 核心概念 | entity（業務實體） | 具獨立身分、可被 API 讀寫、且其狀態可能進入 SSOT 的領域物件。常見 entity：Device、License、Organization、Site。 |
| 核心概念 | SSOT（Single Source of Truth） | 系統中權威的狀態來源（通常為後端 database／web-be）；mutating request 會改變 SSOT；顯示與推算應以 SSOT 為準，前端不可自稱唯一權威。 |
| 實作歸屬 | 全貌 / catalog 全貌 | 指需存取完整 database 或業務 catalog 才能正確判斷的脈絡；前端通常只有 org／scope 範圍內已下發的 subset，故 Q3① 常導向後端實作。 |
| 實作歸屬 | 消費（consume） | 指前端不再自行推算規則，而是直接使用後端 API 已算好的欄位或結果（如 `applicability.transferable`、`status`、`effective_state`）。 |
| 實作歸屬 | 運算量龐大 vs payload 過大（Q3③） | 兩者皆屬「前端取得結果成本過高」：前者指 browser 算不動；後者指需拉取過多原始資料才能算，即使單筆計算很簡單也應由後端算好下發結果欄位。 |
| 實作歸屬 | 集中維護 / 跨 client | 同一套業務規則需在 WEB、APP、API consumer 間一致；為避免 FE／BE 或各 client 規則分歧，傾向由後端 SSOT 計算並下發（Q3④）。 |
| 撰寫與盤點 | 分開盤點、後續對齊 | 文件標示某些 knowledge 現階段 intentionally 分條記載，待後續 consolidation；不代表規則 intentionally 不一致，而是盤點粒度選擇。 |
| 撰寫與盤點 | 單一職責 | 撰寫 knowledge 時應拆乾淨：資料提供、UI 互動、寫入 action 不混在同一條；例如點選圖表後跳轉並套用過濾（UI 操作）與群組定義（狀態顯示）應分開。 |

## Knowledge 屬性常見歧義

- **先算出數值 vs 再用數值篩選**：「剩餘天數怎麼算」是**狀態顯示**（常由後端算好下發）；「使用者選 ≤90 天後表格只顯示符合的列」是 **UI 操作**（前端對已載入列過濾）。兩者常相鄰，但須拆成兩條 Knowledge 條目。
- **狀態顯示 vs 狀態遷移與轉換**：「按鈕能不能點」「顯示某數量／旗標」屬狀態顯示；「按下去送出的 action」才屬狀態遷移與轉換。不可因涉及「狀態」二字就歸類為後者。
- **Literal → Wording**：後端下發 enum／代碼／日期 literal，前端僅做格式化與 i18n，不重新推算業務狀態——屬 Wording 顯示，非狀態顯示。
- **旗標判定 vs 旗標呈現**：後端依全貌判定並下發旗標（狀態顯示／後端）；前端依旗標決定是否顯示圖示或文案（狀態顯示或 Wording，前端）——應分條。
- **圖表計算 vs 點選跳轉過濾**：聚合計算、跨實體統計屬狀態顯示（常後端）；點選後跳轉並 client-side 過濾屬 UI 操作（前端）——不可混寫。

### 屬性範例

| 屬性 | Examples |
|---|---|
| Wording 顯示 | 依 enum／subtype 決定欄位顯示文字；日期欄的時區格式化與「X days」「Limited lifetime」文案；提示訊息（iNote／tooltip）的文字內容（是否顯示圖示屬狀態顯示） |
| UI 操作 | 使用者在搜尋框或篩選器選條件後，只過濾表格裡已經載入的列（不另送 API 查詢）；點選圖表後跳轉另一 Tab 並帶入過濾條件；展開／收合、勾選、排序（未送寫入前） |
| 狀態顯示 | 業務狀態推算（Active／Expiring 等）；Action 可否（選單項目是否啟用）；型號適用性、`applicability` 等旗標的消費（旗標本身若需全貌推算，屬後端 knowledge）；可購類型與到期日業務取值（數值由後端算定，前端消費） |
| 狀態遷移與轉換 | 執行 Assign／Transfer／Activate 等寫入（含 dry-run）；表單提交前的合法性驗證（dry-run）；停用／升級等會改變 org 或實體狀態的 action |

## Code-level 實作 Knowledge

### 只有前端實作

**Pros**

- 即時性較佳，使用者體感回應速度最快
- 不需後端配合，前端可自行迭代規則，發布週期較短

**Cons**

- 前端不會有 database 內的全貌
- 複雜運算時，會受限於 browser 效能
- 規則散落在前端 code，後端 API 若相信前端傳來的結果則有安全風險
- 前後端規則不一致時，易產生 bug（例如 FE 判斷可操作，但 mutating request 被後端擋回）

**Examples**

- Literal → Wording 類轉換
- Filter／篩選（對已載入資料的 client-side 過濾，與寫入無關）
- 純 UI 狀態推算（跳轉前 cross-check、按鈕 disabled 判斷、對話框內表單啟用）
- 消費後端已下發的簡單旗標做條件顯示

### 只有後端實作

**Pros**

- 擁有 database 全貌，計算結果正確且完整
- 規則集中在一處維護，spec 變動只需改後端
- 前端直接消費結果欄位，不需自行實作判斷邏輯，降低前端複雜度
- 可跨多個 client（WEB / APP / API consumer）共用同一套規則

**Cons**

- 每次 UI 互動若需即時 Validate，需額外時間等待後端回應
- 後端需為「純顯示」的知識也建立 API 欄位，增加 response 體積（例如跨欄位疊加計算的結果）

**Examples**

- 業務狀態推算結果下發（`status`、衍生狀態欄位）
- 可操作性旗標（`applicability.*`、`migration_eligible` 等）
- 需 catalog 全貌的對照與清單（由後端依全貌計算並下發，或 per-entity 可選項欄位）
- 跨多筆實體聚合後的統計或合併狀態

### 前後端均須實作

**Pros**

- 同時兼顧前端使用者體驗（即時 Validate）與後端取得全貌的正確性
- 前端可做 dry-run 提示，後端做最終驗證

**Cons**

- 兩邊 RD 均需實作，開發成本較高
- 需要花時間確認兩邊的驗證規則與守備範圍（溝通成本）
- 無論如何，後端均需實作完整計算（驗證與檢查規則）
- 規則若不同步，容易造成前端放行但後端擋回的矛盾體驗
- spec 變動時兩側 code 需同步更新（維護成本）

**Examples**

- 執行 Assign／Transfer 等寫入（前端 dry-run 即時預覽，後端 mutating request 最終驗證與寫入）
- 金鑰／配對驗證（前端先比對已載入資料排除明顯重複，後端 dry-run 驗證合法性）
- 停用前是否需確認 Auto-Upgrade（前端依已下發欄位顯示 acknowledge，後端執行實際寫入）

### 守備範圍對照

#### 前端

- **目的**：即時 UX、減少 round-trip
- **資料視野**：畫面已載入資料 + 使用者當下操作
- **可做**：
  - 基於 API-docs 定義的即時 Schema validation（min/max/length/pattern、required/optional、unique checks）
  - 呼叫 dry-run API 前，使用者輸入及預覽
  - 呼叫 dry-run API 後，UI 顯示後端驗證結果
  - 呼叫 execute API 後，UI 顯示後端驗證/執行結果
- **不可做**：
  - 作為 SSOT 唯一權威（因前端沒有全貌）
  - 不可在前端自行推算需 DB 全貌、catalog 或跨多筆資料的完整規則，應消費後端結果（若前端嘗試取得全貌，會有 performance 及資安議題）
  - 因 dry-run 通過而省略 execute 失敗處理
- **分歧時**：以後端 API-docs 描述為準；若發現後端有錯，先通知後端更新，再修改前端驗證規則

#### 後端

- **目的**：安全、正確性、寫入 SSOT
- **資料視野**：後端完整 DB／catalog（含前端未載入的紀錄）
- **可做**：
  - 提供 dry-run API（驗證並模擬執行完成後狀態，不實際變動 database 或外部系統狀態）
  - 提供 execute API（驗證並更新 database 及外部系統狀態）
  - 無論前端是否使用 dry-run 驗證，execute 時一律完整驗證
  - 全貌下聚合／配對／狀態機裁決
  - dry-run 與 execute 驗證邏輯一致
- **不可做**：
  - 因前端已 Validate 而省略 Schema validation（caller 可能是惡意攻擊者，不是自家前端/APP）
  - 信任前端推論（可 assign／transfer／金鑰合法等），因為前端檢查通過當下，可能同時有另一個 request 變動 database 狀態
- **分歧時**：後端 API-docs 為 Schema validation rule 的 SSOT；spec 變動後端先更新（API-docs），再同步前端守備

## 撰寫一條 Knowledge 的建議欄位

屬性與實作歸屬回答不同問題，須分開填寫。建議至少包含：

| 欄位 | 說明 |
|---|---|
| 標題 | `[畫面／模組] 規則简述` |
| 屬性 | Wording 顯示 / UI 操作 / 狀態顯示 / 狀態遷移與轉換（四選一） |
| 實作歸屬 | 只有前端實作 / 只有後端實作 / 前後端均須實作 |
| 判定方式 | AI（依決策樹推導）/ 人工 |
| 判定理由 | 對應 Q1／Q2／Q3 的簡述 |
| 範圍備註 | 不含哪些相鄰規則、已知技術債、分開盤點說明 |
| Code／API 參照 | 選填，供盤點與重構追蹤 |

## 什麼是一條 Knowledge 條目？

一條 Knowledge 條目應滿足：

1. **具業務語意**：RD／PM 能讀懂「這條規則在產品上做什麼」，而非僅描述實作細節。
2. **單一職責**：只描述一種職責（提供資料、顯示／推算、純 UI、或寫入 action），不混寫。
3. **可獨立判定歸屬**：能單獨跑「實作歸屬決策樹」得出 FE only / BE only / FE+BE。
4. **找得到落點**：不只寫規則本身，還要能指出對應哪個畫面、哪支 API、或哪段 code，之後盤點或改 code 時才不用從頭搜。
