# Reference: Business Rule Ownership Guideline

補充 [SKILL.md](SKILL.md)。**分工：** SKILL 只保留前提、定義、Rule Type 摘要、決策樹、Q1／Q2、Q3 一行摘要、撰寫範本與流程；**本檔**是名詞解釋、Rule Type 細節、Ownership Pros／Cons／Examples、Responsibility Matrix、與 **Q3①②③ 完整判準** 的唯一詳細來源（勿再把判準抄回 SKILL）。

## 要解決的問題

- 前端專案中常存在大量 **hard-coded 的 domain knowledge**（商業規則、狀態推算、權限裁決等）。
- 相同或相近的 domain knowledge 可能在 **web-be** 也有對應實作，但前後端是否一致往往未被系統性追蹤。
- 前後端實作細節不一致時，容易產生 **維護成本與 bug**（例如前端判斷可操作，後端 API 卻拒絕寫入）。
- 每次 spec change，RD 需重新從 code 審查現況才能修改，**開發效率低落**。
- 缺乏客觀的「**誰該實作**」判定標準，導致技術債累積（如前端對 **Reference Data** 做 **Reverse Lookup** 自行推算 **Entity State**、跨 **Domain Entity** 組合推算、跨多筆 **Domain Entity Instance** 聚合在 browser 端迴圈計算）。

**目標**：建立可重複使用的審查與決策框架，讓 FE／BE／各 client 對「一條 Business Rule 的職責歸屬（Ownership）」有客觀共識。

## 名詞解釋

| 類別 | 名詞 | 解釋 |
|---|---|---|
| 核心概念 | Domain Entity | 具獨立身分、可被 API 讀寫、其資料可能寫入 **SSOT** 的領域物件（本專案常見：Device、License、Organization、Site）。 |
| 核心概念 | Entity State | 一條 Business Rule 要回答的、關於某 Domain Entity 的業務狀態／可操作性語意（如 License 是否 Expired、可否 Assign；Device 是否 Online）。 |
| 核心概念 | Entity Attribute | API response 中表達 Entity 性質的具名欄位（如 `display_status`、`applicability.transferable`、`model_name`）。 |
| 核心概念 | Domain Entity Instance | 某 **Domain Entity** 的一筆具體、可個別識別的實際資料紀錄（如某張 License、某台 Device）；與 **Reference Data** 的共用定義不同。 |
| 核心概念 | SSOT（Single Source of Truth） | 系統中權威的狀態來源（通常為 web-be／database / MZC / EMS）；顯示與推算應以其為準，前端不可自稱唯一權威。 |
| Ownership | Reference Data | 後端刻意發布、供各 client 查詢消費的共用參考資料 API（如 `model-property`、`license-catalog`）；SSOT 仍在後端，與具體、可個別識別的 **Domain Entity Instance** 資料不同。 |
| Ownership | Keyed Lookup | 對 **Reference Data** 以已知且唯一 key 直接取得對應屬性／定義，不遍歷整表；資料來源可為 API response、**Reference Data**，或後端程式內靜態定義。允許 FE。 |
| Ownership | Reverse Lookup | 已知條件需遍歷整表反查 entity 清單或衍生 per-entity **Entity State**；預設屬 Q3①，由後端下發，但符合特定條件（低變動頻率 Reference Data 等）時可例外允許 FE 自行推算。 |
| Ownership | Full Scope Instance Data | 判定規則時所需的**完整** **Domain Entity Instance** 資料（含前端未載入的紀錄；非 **Reference Data** 可取代）。前端通常只有 subset，故常導向 Q3②（Data Aggregation）。跨 **Domain Entity** 推算亦屬 Q3②。 |
| Ownership | Consume（消費） | 直接讀取 API 已下發的 **Entity Attribute** 以取得 **Entity State**（含 `applicability.*` 對其他屬性的 includes／boolean 比對），不自行推導。 |
| Ownership | Consumer | 須獨立實作或驗證同一 **Entity State**、且須得相同答案的下游單位。包含 **client 型態**（WEB、APP、**API Consumer**）、**product scope** 路徑（ORG、MSP 等）、或 **FE／BE** 各自須產出／驗證相同結果時。 |
| Ownership | API Consumer | 以 API 呼叫消費 **Entity State** 或觸發寫入的 **Consumer**（非 WEB／APP UI client）。分兩類：**External** — 對外 **Open API** 的下游整合方；**Internal** — 對內 **Cron Job API** 的排程／批次呼叫方。 |
| Ownership | Mapping Table | 解讀單一 API 欄位多義字面值的映射知識（硬編碼常數／enum map，如 `LICENSE_PLAN_MAPPING`，或散落的隱性規則）。須查 **Mapping Table** 才能唯一解讀欄位以得出 **Entity State** 者 → Q3③（Conditional Mapping），一律 BE-only。 |

## Rule Type 細節

### Presentation Formatting

將後端或資料層已算定的 **literal** 值轉成使用者可讀文案或格式，**不重新推算 Entity State**、不改變 SSOT。典型範圍：i18n 文案、日期／時區格式化、空值或特殊型別的顯示規則（如空字串、`—`、固定 placeholder）。**Ownership 傾向：幾乎必為 FE-only。**

Examples:

- 依 enum／subtype 決定欄位顯示文字
- 日期欄的時區格式化與「X days」「Limited lifetime」文案
- 提示訊息（iNote／tooltip）的**文字內容**（是否顯示圖示屬 Display / Calculation）

### Local UI State

純前端互動，**不影響 database／web-be 的任何狀態**；離開畫面即失效。**Ownership 傾向：必為 FE-only。**

Examples:

- 使用者在搜尋框或篩選器選條件後，只過濾表格裡**已經載入**的列（不另送 API 查詢）
- 點選圖表後跳轉另一 Tab 並帶入過濾條件
- 展開／收合、勾選、排序（未送出寫入 API 前）

### Display / Calculation（顯示／推算）

顯示、推算或條件判斷（含按鈕可否點、數量、旗標），但**不呼叫寫入 API、不改 SSOT**。在 SSOT 未改變時，每次進入畫面應看到相同結果。**Ownership 傾向：需完整跑 Q3 才知道 FE-only 或 BE-only。**

Examples:

- **Entity State** 推算（Active／Expiring 等；API 無對應 **Entity Attribute** 時）
- Action 可否（選單項目是否啟用；跨 **Domain Entity** 推算者見 Q3②）
- 透過 `applicability` 等 **Entity Attribute** 消費（Consume）**Entity State**（旗標本身若需 Full Scope Instance Data 推算，屬 BE-only Ownership）
- 可購類型與到期日**業務取值**（數值由後端算定，前端 Consume）

### Write Action（寫入操作）

觸發時會**呼叫寫入 API**，直接或間接改變 **SSOT**；**後端必須實作**，且可能因 UX 需要而前後端並存（dry-run）。**Ownership 傾向：需另跑 Q2 才知道是 Shared 還是 BE-only。**

Examples:

- 執行 Assign／Transfer／Activate 等寫入（含 dry-run）
- 表單提交前的合法性驗證（dry-run）
- 停用／升級等會改變 **SSOT** 的 action

### 常見歧義

- **先算出數值 vs 再用數值篩選**：「剩餘天數怎麼算」是 Display / Calculation（常由後端算好下發）；「使用者選 ≤90 天後表格只顯示符合的列」是 Local UI State。兩者常相鄰，但須拆成兩條。
- **Display / Calculation vs Write Action**：「按鈕能不能點」「顯示某數量／旗標」屬 Display / Calculation；「按下去送出的 action」才屬 Write Action。
- **Literal → Presentation Formatting**：後端下發 enum／代碼／日期 literal，前端僅做格式化與 i18n，不重新推算 Entity State——屬 Presentation Formatting，非 Display / Calculation。
- **旗標判定 vs 旗標呈現**：後端依 Full Scope Instance Data 判定並下發旗標（BE-only）；前端依旗標決定是否顯示圖示或文案（Consume，FE-only）——應分條。
- **圖表計算 vs 點選跳轉過濾**：聚合計算、跨實體統計屬 Display / Calculation（常 BE-only／Q3②）；點選後跳轉並 client-side 過濾屬 Local UI State——不可混寫。

## Code-level Ownership

### FE-only Ownership

**Pros**

- 即時性較佳，使用者體感回應速度最快
- 不需後端配合，前端可自行迭代規則，發布週期較短

**Cons**

- 前端無法取得 **Full Scope Instance Data**（僅能存取畫面已載入的 subset）
- 複雜運算時，會受限於 browser 效能
- 規則散落在前端 code，後端 API 若相信前端傳來的結果則有安全風險
- 前後端規則不一致時，易產生 bug（例如 FE 判斷可操作，但寫入 API 被後端擋回）

**Examples**

- Literal → Presentation Formatting 類轉換
- Filter／篩選（對已載入資料的 client-side 過濾，與寫入無關）
- 純 Local UI State 推算（跳轉前 cross-check、對話框內表單啟用）；按鈕 disabled 判斷僅限 Consume 後端已下發欄位或單一 entity 資料，**不含**跨 **Domain Entity** 推算（見 Q3②）
- Consume 後端已下發的 **Entity Attribute** 以呈現 **Entity State**

### BE-only Ownership

**Pros**

- 擁有 **Full Scope Instance Data**，計算結果正確且完整
- 規則集中在一處維護，spec 變動只需改後端
- 前端直接消費結果欄位，不需自行實作判斷邏輯，降低前端複雜度
- 可跨多個 **Consumer**（WEB / APP / API Consumer）共用同一套規則

**Cons**

- 每次 UI 互動若需即時 Validate，需額外時間等待後端回應
- 後端需為「純顯示」的知識也建立 API 欄位，增加 response 體積（例如跨欄位疊加計算的結果）

**Examples**

- 以 **Entity Attribute** 下發 **Entity State**（`display_status`、`applicability.*`、`migration_eligible` 等）
- Reference Data **Reverse Lookup** 衍生的 per-entity 清單或 **Entity State**（預設由後端算好下發，不符合例外條件時皆屬此類）
- 需 **Full Scope Instance Data** 的對照與清單（由後端依 **Entity State** 計算並下發）
- 跨多筆 **Domain Entity Instance** 聚合後的統計或合併結果
- 跨 **Domain Entity** 組合推算 **Entity State**（細節見 Q3②）
- **Conditional Mapping** 須查 **Mapping Table** 以得出 **Entity State**（細節見 Q3③）

### Shared Ownership

**Pros**

- 同時兼顧前端使用者體驗（即時 Validate）與後端取得 Full Scope Instance Data 的正確性
- 前端可做 dry-run 提示，後端做最終驗證

**Cons**

- 兩邊 RD 均需實作，開發成本較高
- 需要花時間確認兩邊的驗證規則與 Responsibility Matrix（溝通成本）
- 無論如何，後端均需實作完整計算（驗證與檢查規則）
- 規則若不同步，容易造成前端放行但後端擋回的矛盾體驗
- spec 變動時兩側 code 需同步更新（維護成本）

**Examples**

- 執行 Assign／Transfer 等寫入（前端 dry-run 即時預覽，後端寫入 API 最終驗證與寫入）
- 金鑰／配對驗證（前端先比對已載入資料排除明顯重複，後端 dry-run 驗證合法性）
- 停用前是否需確認 Auto-Upgrade（前端依已下發欄位顯示 acknowledge，後端執行實際寫入）

## Responsibility Matrix（RACI）

| 面向 | 前端 | 後端 |
|---|---|---|
| 目的 | 即時 UX、減少 round-trip | 安全、正確性、寫入 SSOT |
| 資料視野 | 畫面已載入資料 + 使用者當下操作 | 後端完整 DB／catalog（含前端未載入的紀錄） |
| 可做 | • 基於 API-docs 定義的即時 Schema validation（min / max / length / pattern；required / optional；unique checks）<br>• 呼叫 dry-run API 前，使用者輸入及預覽<br>• 呼叫 dry-run API 後，UI 顯示後端驗證結果<br>• 呼叫 execute API 後，UI 顯示後端驗證/執行結果 | • 提供 dry-run API（驗證並模擬執行完成後狀態，不實際變動 database 或外部系統狀態）<br>• 提供 execute API（驗證並更新 database 及外部系統狀態）<br>• 無論前端是否使用 dry-run 驗證，execute 時一律完整驗證<br>• 全貌下聚合／配對／狀態機裁決<br>• dry-run 與 execute 驗證邏輯一致 |
| 不可做 | • 作為 SSOT 唯一權威（因前端沒有全貌）<br>• 不可在前端自行推算需 DB 全貌、catalog 或跨多筆資料的完整規則，應消費後端結果（若前端嘗試取得全貌，會有 performance 及資安議題）<br>• 因 dry-run 通過而省略 execute 失敗處理 | • 因前端已 Validate 而省略 Schema validation（caller 可能是惡意攻擊者，不是自家前端/APP）<br>• 信任前端推論（可 assign／transfer／金鑰合法等；前端檢查通過當下，可能同時有另一個 request 變動 database 狀態） |
| 分歧時 | 以後端 API-docs 描述為準；若發現後端有錯，先通知後端更新，再修改前端驗證規則 | 後端 API-docs 為 Schema validation rule 的 SSOT；spec 變動後端先更新（API-docs），再同步前端守備 |

## Q3 詳細判準與 Examples

### Reference Data Lookup（Q3①）

**判定軸**：對 **Reference Data** 的查詢是否須 Reverse Lookup 才能得出結果。

**客觀判準**（符合任一即觸發 Q3①）：

- **Keyed Lookup**：輸入含已知且唯一 entity key，輸出為該 key 的單一屬性／定義 → 不觸發 Q3①（允許 FE）。
- **Reverse Lookup**：輸入為條件／不含唯一 key，輸出為清單或需遍歷反查的衍生 **Entity State** → 觸發 Q3①（預設 BE-only）。

**FE-only 例外**（Reverse Lookup 須**同時符合**以下三點，可不觸發 Q3①）：

1. **低變動 Reference Data**：更新頻率低，client cache 輕微 staleness 不影響業務正確性。
2. **Reference Data 已因其他用途快取**：非為此反查才新拉整份 **Reference Data**。
3. **僅反查 Reference Data 欄位**：不涉及 **Full Scope Instance Data**。

**Example**：

- `getProperty(modelName)` → FE-only（Keyed Lookup）
- `findSupportedLicenses` → FE-only 或 BE-only（Reverse Lookup；視 FE-only 例外）

### Data Aggregation（Q3②）

**判定軸**：規則是否須依賴前端無法完整掌握的資料，或須跨 **Domain Entity** 組合推算 **Entity State**。

**客觀判準**（符合任一即觸發 Q3②）：

- **Full Scope Instance Data**：須完整 **Domain Entity Instance** 資料（含未載入紀錄）。
- **跨多筆 instance 聚合**：
  - 須對多筆 **Domain Entity Instance** 統計、合併或清單推算（可同 entity，可跨 entity），且同 SSOT 下**結果不因使用者當下 UI 互動**（勾選、client-side filter 可見範圍）而改變。
  - **不觸發**者：推算結果僅隨使用者 UI 互動而變，且僅 **Consume** 已下發 **Entity Attribute** → FE-only（勾選統計）。
- **跨 Domain Entity**：須組合兩個以上 **Domain Entity** 的 **Domain Entity Instance** 資料推導 **Entity State**（含單列、已載入資料；一律 BE-only）。

**Example**：

- 全部 Expired License 數量 → BE-only（Q3②，跨多筆 instance 聚合）
- Dashboard online device CPU 平均 → BE-only（Q3②，跨多筆 instance 聚合；與 UI 互動無關）
- 使用者勾選 N 台 Device，Consume `applicability.assign` 決定 bulk action 可否 → FE-only（Q3 全不成立，勾選統計）
- Device 單列依已載入 License 判斷 Assign 可否 → BE-only（Q3②，跨 Domain Entity）

### Conditional Mapping（Q3③）

**判定軸**：單一 API 欄位字面值是否須靠 **Mapping Table** 才能唯一解讀以得出 **Entity State**。

**客觀判準**：

- **Conditional Mapping**：同一欄位字面值因 context（如 `subtype`、product scope）須對照不同解讀方式或取值來源，須查 **Mapping Table** 方能唯一確定。

**Example**：

- `subtype === DEFERRED` 到期改讀 `remain_amount` → BE-only（Q3③）
- MSP `LICENSE_PLAN_MAPPING` → BE-only（Q3③）
  - `NCC_PRO` → 後端 `NPRO`
  - `CNP` → 後端 `CNP`、`CNPP`

## 撰寫一條 Business Rule 的建議欄位

Rule Type 與 Ownership 回答不同問題，須分開填寫。建議至少包含：

| 欄位 | 說明 |
|---|---|
| 標題 | `[畫面／模組] 規則简述` |
| Rule Type | Presentation Formatting / Local UI State / Display / Calculation / Write Action（四選一） |
| Ownership | FE-only / BE-only / Shared |
| 判定方式 | AI（依決策樹推導）/ 人工 |
| 判定理由 | 對應 Q1／Q2／Q3 的簡述 |
| 範圍備註 | 不含哪些相鄰規則、已知技術債 |
| Code／API 參照 | 選填，供審查與重構追蹤 |
