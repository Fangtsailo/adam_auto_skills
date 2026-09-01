# Adam Auto Skill

This repo's skills produce different kinds of handoff documents. These terms name the documents, their readers, and the shared writing rules those documents use, not the install tooling.

This file is the SSOT. `ui-operation-desc`, `test-item`, `fe-code-to-api-requirement`, `td-detail-fillin`, and `ask-adam` each ship a sibling `CONTEXT.md` (symlink to here) so the glossary still resolves after install.

## Language

**畫面操作說明**:
A document for people who do not write the code in scope. It uses only words visible on screen to say what the user is trying to finish, the steps they take, and which screens those steps land on.
_Avoid_: 需求規格, API spec, TD 描述, Epic 描述, 用途說明, 測試項目

**測試項目**:
A document the testing department executes against a 指定分支's 畫面改動. It uses only 畫面用詞. The `##` heading is one 畫面摘要. Body is grouped by 獨立路徑. 使用者操作目的 is the 畫面後置條件: what must hold on screen after that 獨立路徑 finishes. Each 畫面後置條件 names its **畫面位置**.
_Avoid_: 畫面操作說明, UI 測試, 測試案例

**需求規格（給後端）**:
A document for discussing how an API should be designed. It states observable user needs and must not mention current endpoints, fields, or frontend names.
_Avoid_: 畫面操作說明, TD Detail

**TD Detail**:
A document for backend RD aligning with an existing API. It uses product language and real API field paths, and separates Consume from frontend-derived values.
_Avoid_: 畫面操作說明, 需求規格（給後端）

**對口讀者**:
A person who does not implement the code in scope (PM, QA, or RD in another unit). They can follow product screens; they are not assumed to know internals.
_Avoid_: 後端 API 設計者, 實作者

**指定範圍**:
The files and/or code the user points at. Documents only mark which code to read. What actually happens on screen is evidenced only by that code. Used by 畫面操作說明, not by 測試項目.
_Avoid_: TD 條目, Epic, 技術債 log, 指定分支

**指定分支**:
The git branch the user names (current branch if unnamed). Compared to its merge-base with the base branch (default `main`) via three-dot diff.
_Avoid_: 指定範圍, 單檔路徑

**畫面改動**:
The subset of a 指定分支 diff that changes what the user can do or see on screen. The only evidence a 測試項目 may use. If none, do not write a 測試項目.
_Avoid_: 整包 diff, 常數, 純重構, 測試碼

**獨立路徑**:
A sequence the tester can start from one screen entry and finish without first completing another sequence. One 獨立路徑 is one 使用者操作目的 bullet and one 使用者操作流程 group. The group's `####` heading is that bullet's text, copied verbatim.
_Avoid_: 測試案例, 測試情境

**畫面摘要**:
The `##` heading of 畫面操作說明 or 測試項目. One sentence in 畫面用詞, written from the 實際 evidence, not from a filename, function name, commit, or another document's original title.
_Avoid_: 第一筆 commit subject, 檔名, 函數名, 指定文件原標題

**實際**:
What the user can do and see on screen. Evidence is the 指定範圍's code, or a 指定分支's 畫面改動.
_Avoid_: 規格, 需求文件, 標題, 註解

**畫面用詞**:
Words the user can see on the product UI: tab labels, buttons, field titles, filter options, status text. Taken from UI copy and i18n that the 實際 evidence actually references. Keep those words. Do not replace them with a more "professional" coinage.
_Avoid_: 規格文件裡的內部詞, 自創專有名詞

**清單寫完整**:
In 畫面操作說明 and 測試項目, every list names each item. Incomplete → reread the 實際 evidence and its i18n.
_Avoid_: 等等, 等, 同上, 同上所述, 類似, 之類, 以上, 前述, 其他

**畫面動詞**:
In 畫面操作說明 and 測試項目, actions are 接受、使用、選擇、篩選、顯示、進入、點選.
_Avoid_: 用得上, 搞, 弄

**畫面名不是所有格**:
A screen name is the screen; objects on it are objects. Locate a screen as「{名稱} 分頁」or「{名稱} 畫面」. A list on that screen is「{畫面} 分頁的表格」; a column is「{畫面} 分頁的表格，{欄位} 欄」. Used by 畫面操作說明 and 測試項目.

| 草稿 | 正文 |
|---|---|
| 在 {畫面} 的 {欄位} | 在 {畫面} 分頁的表格，{欄位} 欄 |
| 在 {畫面 A} 與 {畫面 B} 篩選 | 在 {畫面 A} 分頁與 {畫面 B} 分頁篩選 |
| {畫面} 顯示一列 | {畫面} 分頁的表格顯示一列 |

_Avoid_: {畫面} 的

**畫面位置**:
Used by 測試項目. The named chrome a tester inspects to confirm a 畫面後置條件, taken from how the 畫面改動 actually renders. Copy without chrome is incomplete: testers cannot tell which control to inspect.

| 草稿 | 正文 |
|---|---|
| 畫面不顯示 Limited-Time CNP/CNP+ Promotion | 不顯示標題為 Limited-Time CNP/CNP+ Promotion 的對話框 |
| 不顯示警告 | banner 不顯示該警告文案 |

_Avoid_: 畫面不顯示 {文案}

**相關聯的畫面**:
The screens or tabs the operations actually land on, observed from the specified code. There is no predefined closed list. Used by 畫面操作說明, not by 測試項目.
_Avoid_: Inventory 分頁閉合集合, 元件名, 路由名

**去實作化**:
For 畫面操作說明, 測試項目, and 需求規格（給後端）: write 畫面用詞 and observable results. Delivered text has no current API endpoints, methods, fields, payloads, function names, variables, components, file paths, or enum literals.

Does **not** strip API field paths from a TD Detail — that document requires them. TD Detail still uses 畫面用詞 for product language and still omits FE names.

Test: after stripping API / function / field names, what does the user see or do? If you cannot say it, the line is implementation — delete it.

Evidence (paths, line numbers, function names) stays in scratch. It does not appear in delivered text.

| 草稿 | 正文 |
|---|---|
| 欄位／enum 等於 `ACTIVE` | 沿用畫面狀態文案（如「授權有效」） |
| 前端過濾；UI filter 對到 API 條件 | 使用者選定條件後，清單只留下符合的項目 |
| 回傳結構裡一個裝置底下有多筆授權陣列 | 一台裝置可能同時擁有多筆授權 |
| 前端用對照表反查機型名稱 | 使用者需要看到機型的完整名稱，不是型號代碼 |
| 目前 API 沒給到期日，所以前端自己算 | 使用者需要在清單上直接看到距離到期還有幾天 |
| 送出前先呼叫試算 API | 使用者按下送出前，需要先知道這次操作會造成什麼結果 |
| 把畫面「授權有效」改成「許可憑證生命週期」 | 沿用畫面上的「授權有效」 |

_Avoid_: 重構目的, Consume, 映射, 收斂

## Which document

| Need | Document | Skill |
|---|---|---|
| 對口讀者要看使用者在畫面上做什麼 | 畫面操作說明 | `ui-operation-desc` |
| 測試部門要驗證指定分支的畫面改動 | 測試項目 | `test-item` |
| 跟後端討論 API 該怎麼設計 | 需求規格（給後端） | `fe-code-to-api-requirement` |
| 對齊既有 API、寫給 BE RD | TD Detail | `td-detail-fillin` |

現行 API 欄位路徑：畫面操作說明、測試項目與需求規格禁止；TD Detail 必寫。
