---
name: td-detail-fillin
description: Fill or rewrite the 給 BE RD Detail block of an Inventory tech-debt entry.
disable-model-invocation: true
---

# TD Detail 填寫指南（給 BE RD）

> **範圍**：只規範各 TD 條目底下「給 BE RD」的 **Detail** 區塊（整段 Detail 一律適用）。  
> Ownership／Epic／Unlocks with 等 **metadata** 不在此規範（另見 `inventory-knowledge/tech-debt-log.md`、ownership 相關 SSOT）。  
> **來源模式**：自 E03 篩選類 TD（以 TD-004 為 canonical）提煉；原則可複用到其他「現況 FE 推算 → 期望 BE 提供可 Consume 結果」的 TD。

## Trigger

Apply when the user asks to write, rewrite, review, or align a TD **Detail** for BE RD (e.g.「寫 TD-006 Detail」「依 fillin guideline 補 Detail」).

## Workflow

1. **Identify the TD** — open the target entry (often under `inventory-knowledge/`, e.g. `E03-E04_related_td.md` or `tech-debt-log.md`). Do **not** invent metadata; only write／rewrite the Detail block.
2. **Gather evidence** — read the **real** Inventory（or related）API docs／types and the **real** FE filter／row logic. Do not write from the log title or FE comments alone.
3. **Draft Detail** — follow「建議章節骨架」in order; omit inapplicable sections, but keep **這條在做什麼／現行 API／期望結果**.
4. **Self-check** — run「交件前 Checklist」before presenting.
5. **Output** — write Detail in Traditional Chinese 畫面用詞 ([`CONTEXT.md`](CONTEXT.md)). API field paths stay; **去實作化** does not strip them from a TD Detail. Evidence (file paths, line numbers, function names) stays in scratch; never put FE paths, line numbers, or function/variable names in the Detail body.

Canonical example to mirror structure and tone:

- `inventory-knowledge/E03-E04_related_td.md` → **TD-004 — GSP 授權狀態同步至 NCC／PRO／RAP 篩選集合**

Internal vocabulary: [`CONTEXT.md`](CONTEXT.md). In Detail, use the left column of the terminology table below. Full human-readable rules (including易曲解詞彙) live in the consuming repo at `inventory-knowledge/td_fillin_guideline.md` — not shipped with this skill.

---

## 寫作用語對照

Detail **對 BE 用中文產品語**。寫 Detail 時用下表左側用語，避免把右側 `_Avoid_`／FE 實作名寫進正文。

| Detail 用語 | 意思 | 內部對應詞（若有） | 避免寫入 Detail |
|-------------|------|---------------------------|-----------------|
| 組織 Inventory 裝置列表上的授權狀態篩選 | 產品 UI 上裝置表的授權篩選語意（**不是**後端 Device List API／資源名） | Device list（UI surface） | 裸寫 `Device List` |
| 篩選狀態 | 單一可被列表篩選命中的狀態標籤（如 `ACTIVE`、`UNLICENSE`） | Device License Filter State 的成員；部分亦屬 Filter Bucket | `licState`、side bag、加性… |
| （某 type 的）篩選集合 | 某授權 type（如 NCC／PRO／RAP）上，該裝置累積的篩選狀態集合（供列表篩選命中） | Compound Filter State | `licenseStateByTypeFromGsp`、`unlicenseByType`、覆蓋集合、最終／中間篩選集合 |
| 授權 key | API 上單一 license key 實例＝`devices[].licenses[].details[].details[]` | — | 「授權列」；與 UI「一台裝置多行 License」混用 |
| 一筆授權 | API 上一筆 `devices[].licenses[]` 元素 | — | 與授權 key／UI License 行混用 |
| UI License 行 | 產品 UI 上一台裝置展開的多行 License 呈現 | — | 「授權列」 |
| 該筆授權經 FE 規則後的篩選狀態 | 套用 TD-008／009 等之後；**不是**直接把 `devices[].licenses[].status` 字面值當最終篩選狀態 | post-aggregation filter state | 「聚合狀態」「裸 status」 |
| Security License 篩選 | 裝置列表上的 Security License chip／聯集結果 | Security License Union | 單獨大寫 `Security` 當主詞 |
| 直通 API | 篩選狀態＝某個 response 欄位的原值（常見 `devices[].licenses[].status`） | 接近 Consume 的現況片段 | 「mirror」「recompute」當敘事主詞 |
| FE 推算 | 篩選狀態不是欄位字面複製，而是 FE 依其他欄位條件寫入 | （收斂後應改為 Consume） | 具體函式名、變數名 |
| Consume | （僅在期望結果）FE 讀 API 提供的結果，不再自行推導同一語意 | Consume | 代定 BE 欄位名／payload 形狀 |

### 易曲解詞彙（Detail 禁用／改寫）

| 禁用／避免 | 改寫為 |
|------------|--------|
| `Device List` | 組織 Inventory 裝置列表上的授權狀態篩選（必要時括註：產品 UI，非後端資源名） |
| 建列（業務節） | 可觀察篩選行為；僅「現況 FE 處理順序」可談流程並標非要求 BE 照做 |
| 覆蓋用篩選集合／覆蓋集合 | 涵蓋／一併算進／納入（某 type）篩選集合 |
| 授權列 | 授權 key／一筆授權／UI License 行 |
| 聚合狀態／聚合篩選狀態 | 該筆授權經 FE 規則後的篩選狀態（不是直接採用 `devices[].licenses[].status` 字面值） |
| 裸 status | **文件禁用** |
| 單獨 `Security` | Security License 篩選 |
| 閉合映射 | 列固定額外目標 Plus／Pro／UTM_CF |
| 預設未授權標記 | 不因缺獨立授權就補 `UNLICENSE` |
| 最終／中間篩選集合 | （某 type 的）篩選集合 |

**名詞邊界（必守）**

- UI License 行 **≠** API「授權 key」（`devices[].licenses[].details[].details[]`）。
- 單一篩選狀態 **≠** 整台裝置列。
- 同名狀態字串可能 API 直通與 FE 推算異源；必須分開寫清。
- 談可觀察結果，不談 FE 中間結構（標記、覆蓋集合、建列管線）。

---

## API 路徑寫法（必守）

1. 一律自 `devices[]` 寫滿；禁止省略前綴。
2. 授權 key 寫到 `devices[].licenses[].details[].details[]`。
3. 每次寫完整；禁用「同上」。
4. 非本 inventory API 必須點名來源。

---

## 建議章節骨架

依序撰寫。某節若本條不適用可省略，但 **「這條在做什麼」「現行 API」「期望結果」** 建議必有。

### 1. 這條在做什麼（業務語意）

- 用產品／篩選語意說明；不是 FE 實作導覽（無函式名、建列管線）。
- 開頭建議「組織 Inventory 裝置列表上的授權狀態篩選…」，不要裸寫 `Device List`。

### 2. 現行 API（FE 消費來源）

| 項目 | 要寫什麼 |
|------|----------|
| API 名稱 | 如 `QueryOrgInventoryV15` |
| Method / Path | 如 `POST /nebula/v15/organization/{org_id}/inventory` |
| Response 根路徑 | 如 `devices[]` |
| 實際讀到的欄位 | **完整路徑（自 `devices[]` 起）** |

非本 API 依賴單獨點名。

### 3–7

同 `inventory-knowledge/td_fillin_guideline.md`（觸發條件、狀態語意、直通 vs 推算、現況 FE 處理順序、期望結果）。

---

## 寫作原則（方針）

1. 讀真實程式／真實 API 再寫；Detail 正文無 FE 路徑／行號／函式名。
2. 寫業務語意，不是 FE 導覽。
3. API 欄位自 `devices[]` 寫滿；禁用「同上」與省略前綴。
4. 區分 API 直通 vs FE 推算。
5. 每個篩選狀態有語意說明。
6. 狀態關係寫清；禁止自創暱稱。
7. 處理順序＝現況脈絡，非 BE 必做。
8. 不替 BE 定案實作。
9. 範圍對齊本條；跨 TD 僅短引用。
10. 遵守易曲解詞彙表。

### 跨 TD 引用

- 允許短引用＋ TD 編號。
- 禁止整段搬運被引用 TD 規則。

---

## 交件前 Checklist

Copy and tick before delivering Detail:

```
- [ ] 已對照真實 Inventory（或相關）API／現況 FE 篩選邏輯，而非只抄 log 標題
- [ ] 「這條在做什麼」讀起來是產品語意，不是 FE 導覽
- [ ] 已標 method／path、response 根路徑、相關欄位完整路徑（自 devices[] 起；無省略前綴）
- [ ] 非本 inventory API 的依賴已點名來源
- [ ] 已區分 API 直通 vs FE 推算；同名異源有分開說明
- [ ] 本條出現的每個篩選狀態都有語意說明（可附 UI 文案）
- [ ] 狀態關係寫清（互斥／同時／覆寫／略過）；無自創暱稱
- [ ] 無「同上」；條件與欄位皆寫完整
- [ ] 若有處理順序：已標「現況 FE 脈絡，非要求 BE 照做」
- [ ] 正文無 FE 函式名／變數名／檔案路徑
- [ ] 期望結果未代定 BE 欄位名或 payload 形狀
- [ ] 範圍對齊本條；跨 TD 僅短引用
- [ ] 名詞未混淆：授權 key／一筆授權／篩選狀態／裝置列／UI License 行
- [ ] 無易曲解詞：裸 Device List、建列（業務節）、覆蓋集合、授權列、聚合狀態、裸 status、閉合映射、未授權標記、最終／中間篩選集合、單獨 Security 主詞
```

---

## Related sources

- Human-readable guideline (consuming repo): `inventory-knowledge/td_fillin_guideline.md`
- Canonical Detail (consuming repo): `inventory-knowledge/E03-E04_related_td.md`（TD-004）
- Domain vocabulary: [`CONTEXT.md`](CONTEXT.md)
