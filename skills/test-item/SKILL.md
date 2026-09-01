---
name: test-item
description: Write a Traditional Chinese 測試項目 from a specified branch's 畫面改動 for the testing department.
disable-model-invocation: true
---

# 測試項目

把指定分支的畫面改動，寫成**測試部門拿去走畫面的測試項目**。

讀 [`CONTEXT.md`](CONTEXT.md)：確認文件種類是 **測試項目**，並套用 **去實作化**、**畫面用詞**、**清單寫完整**、**畫面動詞**、**畫面名不是所有格**、**畫面位置**。事實只來自指定分支的畫面改動。

每條指定分支產出一篇，固定兩塊：

> 使用者操作目的
> 使用者操作流程

若使用者要的是畫面操作說明 → 讀 [ui-operation-desc](../ui-operation-desc/SKILL.md)。
若使用者要的是需求規格（給後端）→ 讀 [fe-code-to-api-requirement](../fe-code-to-api-requirement/SKILL.md)。
若使用者要的是 TD Detail → 讀 [td-detail-fillin](../td-detail-fillin/SKILL.md)。

## Trigger

沒有指定分支就用目前分支。不是 git repo、base 對不到、或沒有畫面改動：停下來說，不要寫。

## 本文件獨有的硬規則（違反即重寫）

1. **事實只來自畫面改動**（CONTEXT.md **畫面改動**）。commit、PR、註解與 diff 衝突時，以畫面改動為準。
2. **目的是畫面後置條件**（CONTEXT.md **測試項目**）。
3. **獨立路徑 1:1**（CONTEXT.md **獨立路徑**）。同一畫面結果出現在兩個入口，仍是兩組。
4. **結果要標畫面位置**（CONTEXT.md **畫面位置**）。後置條件與流程結果步沒有畫面位置 → 重寫。看不出畫面位置：停下來問。

`##` 是一句畫面摘要（CONTEXT.md **畫面摘要**）。

## Workflow

複製並勾進度：

```
- [ ] 1. 圈定指定分支
- [ ] 2. 取 diff，抽出畫面改動
- [ ] 3. 切獨立路徑
- [ ] 4. 對畫面文案／i18n 核對用詞
- [ ] 5. 去實作化後寫畫面摘要與兩區塊
- [ ] 6. 輸出
```

### 1. 圈定指定分支

使用者點名的分支；沒點名就用目前分支。base 預設 `main`。

確認 `git rev-parse` 對得到指定分支與 base。對不到就停。

### 2. 取 diff，抽出畫面改動

一次定好指令：`git diff <base>...HEAD`。

diff 為空：停，說沒有測試項目。

打開 diff 裡真正改到畫面的檔（template、i18n、會顯示／隱藏／可點的畫面）。抽進草稿（草稿可含實作名，正文不行）：

- 使用者能點什麼、選什麼、送出什麼
- 畫面上會出現或不再出現什麼文字／數字／清單／空狀態
- 什麼條件下清單或狀態會變
- 這段畫面改動掛在哪個畫面／分頁
- 文案掛在哪塊畫面位置

看不出使用者操作的片段：不要寫進標題與兩區塊。看不出畫面位置：停下來問。

### 3. 切獨立路徑

套用 CONTEXT.md **獨立路徑**。同一結果在兩個入口都要驗（例如 Organization-wide 與 MSP 各有一條），切成兩條。

寫不成任何獨立路徑：停，說沒有畫面改動。

### 4. 對畫面文案／i18n 核對用詞

標題與正文出現的每個產品詞，必須能在畫面或該畫面改動實際引用的 i18n 找到對應文案（CONTEXT.md **畫面用詞**）。

中文標題與正文用繁中畫面文案。對不到畫面詞：停下來問，不要自創，也不要從 commit／PR 借詞。

### 5. 去實作化後寫畫面摘要與兩區塊

套用 CONTEXT.md **去實作化**。每條草稿問：使用者在哪個畫面、做了什麼、在哪個畫面位置看到或不看到什麼？寫不出畫面位置：停下來問。

`##` 用一句畫面摘要（CONTEXT.md **畫面摘要**）。兩區塊套用 **獨立路徑**。

### 6. 輸出

- 指定路徑 → 寫入該 markdown（覆蓋）。
- 未指定 → 寫入 repo 根目錄 `TEST_ITEM.md`（覆蓋）。
- 一條指定分支一篇；不要自行切成多個檔。

完成條件：已寫入，且交件前 Checklist 全勾。

## 輸出格式

每篇 **只准**這兩個內容區塊（區塊標題用詞固定）。段前 `##` 用一句畫面摘要。

```markdown
## （一句畫面摘要）

### 使用者操作目的
- （獨立路徑 1 走完後，在哪個畫面位置要成立的事）
- （獨立路徑 2 走完後，在哪個畫面位置要成立的事）

### 使用者操作流程
#### （獨立路徑 1 的目的原文）
1. （單一動作：進入哪個畫面或打開哪個畫面）
2. （單一動作：點選、篩選、或送出）
3. （單一動作：在哪個畫面位置出現或不出現什麼結果）

#### （獨立路徑 2 的目的原文）
1. （單一動作：進入哪個畫面或打開哪個畫面）
2. （單一動作：點選、篩選、或送出）
3. （單一動作：在哪個畫面位置出現或不出現什麼結果）
```

流程規則：

- 每組用編號步驟；一步一個動作；各組從 1 重編。
- 只寫畫面改動實際覆蓋的路徑；不要為了「完整」補沒讀到的步驟。
- 多條獨立路徑時，各組寫清楚自己的入口；不要假裝只有一條路。
- 結果步寫畫面位置。

缺證據就不要寫那句。

## Example

**不合格**（多條獨立路徑編成一串編號；帶實作詞；沒標畫面位置）：

```
## remove CnpPromoDialog

### 使用者操作目的
使用者從 Choose organization 畫面選擇 Organization 後，要查看裝置與授權，畫面不再跳出 Limited-Time CNP/CNP+ Promotion。

### 使用者操作流程
1. 進入 Choose organization 畫面
2. 選擇一個 Organization
3. 畫面不顯示 Limited-Time CNP/CNP+ Promotion
4. 進入 Organization-wide 畫面
5. 點選 License & inventory
6. 點選 Devices 分頁
7. Devices 分頁的表格，License info 欄不顯示 Claim
8. 進入 MSP 畫面
9. 點選 Device & license inventories
```

**合格**（一句畫面摘要；目的條列；流程按獨立路徑分組；小標 = 目的原文；結果標畫面位置）：

```
## 選擇 Organization 後不顯示標題為 Limited-Time CNP/CNP+ Promotion 的對話框，Devices 分頁的表格不顯示 Claim

### 使用者操作目的
- 選擇 Organization 後，不顯示標題為 Limited-Time CNP/CNP+ Promotion 的對話框
- 在 License & inventory 畫面點選 Devices 分頁後，表格的 License info 欄不顯示 Claim
- 在 Device & license inventories 畫面點選 Devices 分頁後，表格的 License info 欄不顯示 Claim

### 使用者操作流程
#### 選擇 Organization 後，不顯示標題為 Limited-Time CNP/CNP+ Promotion 的對話框
1. 進入 Choose organization 畫面
2. 選擇一個 Organization
3. 不顯示標題為 Limited-Time CNP/CNP+ Promotion 的對話框

#### 在 License & inventory 畫面點選 Devices 分頁後，表格的 License info 欄不顯示 Claim
1. 進入 Organization-wide 畫面
2. 點選 License & inventory
3. 點選 Devices 分頁
4. Devices 分頁的表格，License info 欄不顯示 Claim

#### 在 Device & license inventories 畫面點選 Devices 分頁後，表格的 License info 欄不顯示 Claim
1. 進入 MSP 畫面
2. 點選 MSP cross-org manage
3. 點選 Device & license inventories
4. 點選 Devices 分頁
5. 點選 Placed
6. Devices 分頁的表格，License info 欄不顯示 Claim
```

畫面上寫 Limited-Time CNP/CNP+ Promotion、Claim 就用那些詞。畫面改動沒覆蓋到的行為不要寫。

## 交件前 Checklist

```
- [ ] 已讀 CONTEXT.md；標題與兩區塊通過 去實作化、畫面用詞、清單寫完整、畫面動詞、畫面名不是所有格、畫面位置
- [ ] 證據鏈完整：指定分支 → git diff <base>...HEAD → 已讀畫面改動
- [ ] 沒有只根據 commit、PR、標題或註解寫用途
- [ ] 沒有把非整包 diff 裡的兄弟行為寫進來
- [ ] 沒有畫面改動時已停筆，沒有空的測試項目
- [ ] ## 是一句畫面摘要，不是檔名、函數名、commit
- [ ] 「使用者操作目的」是條列；一條獨立路徑一條畫面後置條件
- [ ] 只有兩個區塊：使用者操作目的、使用者操作流程
- [ ] 每個流程組 #### 小標 = 對應目的原文
- [ ] 各組步驟從 1 重編；沒有把多條獨立路徑混成一串編號
- [ ] 流程每步都是使用者動作或可觀察結果
- [ ] 每條後置條件與流程結果步都標了畫面位置
- [ ] 已寫入指定路徑，或 repo 根目錄 TEST_ITEM.md
```
