# Adam Auto Skill — 專案需求規格

> 個人 Cursor Agent Skills 的集中管理與跨專案安裝工具

---

## 0. 實作進度

**目前階段：Phase 1 完成 ✅ | Phase 2 待開始**

| 階段 | 狀態 | 說明 |
|------|------|------|
| Phase 1 — 基礎倉庫（MVP） | ✅ 完成 | Git 初始化、skills 倉庫、validate/install 腳本、README |
| Phase 2 — CLI 與狀態管理 | ⬜ 未開始 | `bin/skill`、install manifest、sync/uninstall |
| Phase 3 — 品質與自動化 | ⬜ 未開始 | CI、pre-commit、skill scaffold |
| Phase 4 — 進階 | ⬜ 未開始 | 第三方 skill、submodule、SDK 整合 |

### 已交付項目（Phase 1）

| 項目 | 路徑 / 指令 | 狀態 |
|------|-------------|------|
| Git 倉庫 | `.git/` | ✅ 已 init，檔案已 staged，**尚未 initial commit** |
| Skill 索引 | `skills/manifest.json` | ✅ |
| 範例 skill | `skills/angular-code-review/`（含 `reference.md`） | ✅ |
| 範例 skill | `skills/git-commit-helper/` | ✅ |
| 共用函式庫 | `scripts/lib.sh` | ✅ |
| 驗證腳本 | `scripts/validate-skill.sh` | ✅ |
| 安裝腳本 | `scripts/install.sh` | ✅ |
| 專案說明 | `README.md` | ✅ |
| 變更紀錄 | `CHANGELOG.md` v1.0.0 | ✅ |
| Git 忽略規則 | `.gitignore` | ✅ |

### 已驗證行為

- `./scripts/validate-skill.sh --all` — 2 個 skills + manifest 全部通過
- `./scripts/install.sh --global <name>` — symlink 安裝至 `~/.cursor/skills/`
- `./scripts/install.sh --project <path> <name> --copy` — 複製安裝至專案 `.cursor/skills/`
- `./scripts/install.sh --all --project <path> --copy` — 複製安裝全部 skills 至指定專案
- 重複安裝阻擋、`--force` 覆寫 — 正常運作
- 禁止寫入 `~/.cursor/skills-cursor/` — 已實作於 `scripts/lib.sh`

### 待辦（Phase 2 起）

- 建立 initial commit 並 push remote
- 實作 `bin/skill` 統一 CLI（`list`、`info`、`sync`、`uninstall`）
- Install manifest 追蹤已安裝狀態
- 自動生成 `SKILLS.md`

---

## 1. 專案背景

### 1.1 什麼是 Agent Skill？

Agent Skill 是 Cursor 中用來教導 AI Agent 執行特定任務的 Markdown 指令集。每個 skill 以目錄形式存在，核心檔案為 `SKILL.md`（含 YAML frontmatter 與 Markdown 正文），可選附帶 `reference.md`、`examples.md`、`scripts/` 等輔助資源。

### 1.2 Cursor 內建的 Skill 存放位置

| 類型 | 路徑 | 作用域 | 備註 |
|------|------|--------|------|
| **Personal** | `~/.cursor/skills/<skill-name>/` | 使用者所有專案 | 本專案主要管理目標 |
| **Project** | `<target-project>/.cursor/skills/<skill-name>/` | 單一 repo 及其協作者 | 可選安裝目標 |
| **Built-in** | `~/.cursor/skills-cursor/` | Cursor 內建 | **禁止修改或覆寫** |

### 1.3 現有痛點

- Skills 分散在多個專案或本機路徑，難以統一維護與版本追蹤
- 換機器或新專案時，需手動複製貼上，容易遺漏或版本不一致
- 無法快速選擇「只安裝某幾個 skill」到指定專案
- 缺乏統一的命名、描述、品質驗證標準

---

## 2. 專案願景與目標

### 2.1 願景

建立一個 **以 Git 管理的 Skills 中央倉庫**，作為所有自訂 Agent Skills 的單一真實來源（Single Source of Truth）。透過簡單的安裝機制，可將任意 skill 部署到：

- 本機 Personal 目錄（全域可用）
- 任意目標專案的 Project 目錄（隨 repo 共享）

### 2.2 核心目標

| # | 目標 | 說明 | 狀態 |
|---|------|------|------|
| G1 | **集中收納** | 所有自訂 skills 統一存放於此 repo，附目錄與說明 | ✅ Phase 1 |
| G2 | **版本管理** | 以 Git 追蹤每個 skill 的演進，支援 tag / release | 🟡 Git 已 init，待 commit / tag |
| G3 | **選擇性安裝** | 可安裝全部、單一、或多個指定 skills 到目標位置 | ✅ Phase 1 |
| G4 | **可更新 / 可移除** | 支援 sync、upgrade、uninstall，避免殘留舊版 | ⬜ Phase 2（symlink 模式下更新已即時生效） |
| G5 | **品質一致** | 提供驗證腳本，確保 frontmatter、命名、結構符合規範 | ✅ Phase 1 |

### 2.3 非目標（初期不做）

- 不管理 Cursor 內建 skills（`skills-cursor`）
- 不做公開 npm registry 或 marketplace
- 不取代 Cursor IDE 內建的 skill 創建 UI
- 初期不支援 Windows 以外的特殊路徑處理（先以 Linux / macOS 為主）

---

## 3. 使用者情境

### UC-1：新增 Skill

> 我寫好一個新的 `angular-code-review` skill，想把它收進中央倉庫並 commit。

1. 在 `skills/` 下建立 `angular-code-review/` 目錄
2. 放入符合規範的 `SKILL.md` 及相關檔案
3. 執行驗證腳本確認格式正確
4. Git commit & push

### UC-2：安裝到 Personal（全域）

> 我想在本機所有 Cursor 專案都能用到 `create-hook` 和 `babysit` 這兩個 skills。

```bash
# ✅ Phase 1 已實作
./scripts/install.sh --global angular-code-review git-commit-helper

# ⬜ Phase 2 待實作
skill install --global angular-code-review create-hook
```

### UC-3：安裝到指定專案

> 我想把 skill 裝到 `~/projects/my-app/` 的 project skills 裡，讓團隊共用。

```bash
# ✅ 安裝單一 skill
./scripts/install.sh --project ~/projects/my-app angular-code-review --copy

# ✅ 安裝全部 skills 到指定專案
./scripts/install.sh --all --project ~/projects/my-app --copy

# ⬜ Phase 2 待實作
skill install --project ~/projects/my-app angular-nx-standards
skill install --all --project ~/projects/my-app
```

### UC-4：更新已安裝的 Skill ⬜ Phase 2

> 中央倉庫的 skill 更新了，我想同步到已安裝的位置。

> **Phase 1 備註：** symlink 模式下，修改本 repo 後即時生效，無需額外 sync。

```bash
skill sync angular-code-review
# 或一次更新全部
skill sync --all
```

### UC-5：列出與查詢 ⬜ Phase 2

> 我想看倉庫裡有哪些 skills，以及某個 skill 是否已安裝。

> **Phase 1 替代：** 查閱 `skills/manifest.json` 或執行 `ls skills/`。

```bash
skill list                  # 列出倉庫內所有 skills
skill list --installed      # 列出已安裝到 personal 的 skills
skill info angular-code-review
```

### UC-6：移除 Skill ⬜ Phase 2

> **Phase 1 替代：** 手動刪除 `~/.cursor/skills/<name>` 或專案內 `.cursor/skills/<name>`。

```bash
skill uninstall --global angular-code-review
skill uninstall --project ~/projects/my-app angular-nx-standards
```

---

## 4. 功能需求

### 4.1 Skill 倉庫管理

- [x] **FR-01** 所有 skills 存放於 `skills/<skill-name>/` 目錄
- [x] **FR-02** 每個 skill 必須包含 `SKILL.md`，且 frontmatter 含 `name`、`description`
- [x] **FR-03** 維護 `skills/manifest.json`（或 `SKILLS.md`）作為可讀目錄，記錄名稱、描述、版本、標籤
- [x] **FR-04** 支援 skill 分類標籤（如 `angular`、`git`、`ci`、`cursor-config`）
- [x] **FR-05** 提供 `validate` 命令檢查 skill 結構與 frontmatter 規範 → `scripts/validate-skill.sh`

### 4.2 安裝與部署

- [x] **FR-10** 支援 `--global` / `--personal`（安裝至 `~/.cursor/skills/`）→ `scripts/install.sh`
- [x] **FR-11** 支援 `--project <path>`（安裝至 `<path>/.cursor/skills/`）
- [x] **FR-12** 支援一次安裝多個 skills（空格分隔）
- [x] **FR-13** 支援 `--all` 安裝倉庫內全部 skills
- [x] **FR-14** 預設安裝策略：**符號連結（symlink）**；提供 `--copy` 選項改為複製
- [x] **FR-15** 安裝前檢查目標路徑是否已存在同名 skill，需 `--force` 覆寫
- [x] **FR-16** 禁止對 `~/.cursor/skills-cursor/` 進行任何寫入操作

### 4.3 更新與移除

- [ ] **FR-20** `sync` 重新指向或複製最新版本（symlink 模式下 git pull 即生效）→ Phase 2
- [ ] **FR-21** `uninstall` 移除 symlink 或複製的目錄，不影響倉庫原始檔 → Phase 2
- [ ] **FR-22** 記錄已安裝狀態（建議 `.skill-install-lock` 或 `~/.cursor/skills/.adam-manifest.json`）→ Phase 2

### 4.4 Git 工作流

- [x] **FR-30** 本 repo 以 Git 管理（已 init；待 initial commit）
- [ ] **FR-31** 建議 commit 格式：`skill(<name>): <description>`，例如 `skill(angular-review): add NGXS checklist`
- [ ] **FR-32** 重大變更以 Git tag 標記版本（如 `angular-review/v1.2.0`）
- [x] **FR-33** 提供 `CHANGELOG.md` 或各 skill 目錄下 `CHANGELOG.md` 記錄變更

### 4.5 文件與可發現性

- [x] **FR-40** 根目錄 `README.md` 說明專案用途、快速開始、指令參考
- [ ] **FR-41** 各 skill 可選 `README.md` 補充使用範例（`SKILL.md` 保持精簡）
- [ ] **FR-42** `SKILLS.md` 自動或半自動生成 skill 總覽表 → Phase 2

---

## 5. 建議的 Repository 結構

```
adam_auto_skill/
├── initial.md                 # 本需求規格（專案起點文件）
├── README.md                  # ✅ 專案說明與快速開始
├── CHANGELOG.md               # ✅ 全專案變更紀錄
├── .gitignore                 # ✅
├── skills/                    # ★ 所有 skills 的存放根目錄
│   ├── manifest.json          # ✅ Skill 目錄索引
│   ├── angular-code-review/   # ✅ 範例 skill
│   │   ├── SKILL.md
│   │   └── reference.md
│   ├── git-commit-helper/     # ✅ 範例 skill
│   │   └── SKILL.md
│   └── ...
├── scripts/                   # ✅ 本專案管理用腳本
│   ├── lib.sh                 # ✅ 共用函式
│   ├── install.sh             # ✅ 安裝入口
│   └── validate-skill.sh      # ✅ 驗證 skill 結構
├── bin/
│   └── skill                  # ⬜ Phase 2：統一 CLI 入口
└── .github/
    └── workflows/
        └── validate.yml       # ⬜ Phase 3：CI 驗證
```

---

## 6. Skill 撰寫規範（本倉庫標準）

### 6.1 目錄命名

- 小寫字母、數字、連字號：`angular-code-review` ✅
- 禁止空格、底線、大寫

### 6.2 SKILL.md Frontmatter

```yaml
---
name: angular-code-review
description: >-
  Review Angular code for NGXS patterns, inject() usage, and team standards.
  Use when reviewing Angular PRs or when the user asks for Angular code review.
---
```

| 欄位 | 規則 |
|------|------|
| `name` | 最多 64 字元；小寫、數字、連字號；與目錄名一致 |
| `description` | 最多 1024 字元；第三人稱；包含 **做什麼（WHAT）** 與 **何時觸發（WHEN）** |

### 6.3 內容原則

- `SKILL.md` 建議不超過 500 行；詳細內容放 `reference.md`
- 引用附檔僅一層深度（從 `SKILL.md` 直接連結）
- 程式碼與註解使用 English；與使用者溝通的範例文字可中英並用

### 6.4 驗證檢查項

1. 目錄名與 frontmatter `name` 一致
2. 必要 frontmatter 欄位存在且非空
3. `description` 長度與格式
4. 無敏感資訊（API key、密碼、內網 URL）
5. 未引用 `skills-cursor` 內建路徑作為寫入目標

---

## 7. 安裝機制設計

### 7.1 策略比較

| 策略 | 優點 | 缺點 | 建議用途 |
|------|------|------|----------|
| **Symlink** | 倉庫更新即生效；節省磁碟 | 目標機器需允許 symlink；Windows 需權限 | 開發者本機 personal 安裝（**預設**） |
| **Copy** | 相容性最佳；可離線 | 需手動 sync；佔用空間 | 安裝到他人專案、CI 環境 |
| **Git submodule** | 版本鎖定清晰 | 操作複雜；對非 Git 使用者不友善 | 團隊 project skill（進階，後期） |

### 7.2 安裝流程（預期）

```
使用者執行 install 命令
        │
        ▼
解析目標（personal / project path）
        │
        ▼
驗證 skill 存在於 skills/ 且通過 validate
        │
        ▼
檢查目標路徑衝突
        │
        ├── 已存在 → 提示 --force 覆寫
        │
        ▼
建立 symlink 或 copy 至目標 .cursor/skills/<name>/
        │
        ▼
更新 install manifest（記錄來源路徑、模式、時間）  ← ⬜ Phase 2
        │
        ▼
輸出成功訊息
```

### 7.3 目標路徑解析

| 參數 | 解析結果 |
|------|----------|
| `--global` / `--personal` | `$HOME/.cursor/skills/` |
| `--project <path>` | `<path>/.cursor/skills/`（自動建立 `.cursor/skills` 若不存在） |
| `--all` | 安裝 `skills/` 下全部 skills；可與 `--global` 或 `--project` 搭配 |
| `--copy` | 使用複製而非 symlink |
| `--force` | 覆寫已存在的同名 skill |

---

## 8. CLI 指令規格（草案）

**Phase 1 對應腳本：**

```bash
./scripts/validate-skill.sh [--all] [<name>...]   # ✅ 已實作
./scripts/install.sh [options] [<names>...]       # ✅ 已實作

# 安裝全部至本機
./scripts/install.sh --all --global

# 安裝全部至指定專案
./scripts/install.sh --all --project <path> [--copy] [--force]
```

**Phase 2 統一 CLI（待實作）：**

```bash
skill list [--installed] [--tags <tag>]     # 列出 skills
skill info <name>                           # 顯示 skill 詳情
skill validate [<name>]                     # 驗證一個或全部 skills
skill install [options] <names...>          # 安裝
skill install --all [options]               # 安裝全部
skill sync [<names...>] [--all]             # 同步已安裝 skills
skill uninstall [options] <names...>        # 移除
```

**共用 options：**

| Option | 說明 |
|--------|------|
| `-g, --global` | 安裝到 `~/.cursor/skills/` |
| `-p, --project <path>` | 安裝到指定專案 |
| `-c, --copy` | 複製模式（預設 symlink） |
| `-f, --force` | 強制覆寫 |
| `-v, --verbose` | 詳細輸出 |

---

## 9. 實作階段規劃

### Phase 1 — 基礎倉庫（MVP） ✅ 完成

- [x] 初始化 Git repo（已 init，待 initial commit）
- [x] 建立 `skills/` 目錄結構與 `manifest.json` 格式
- [x] 遷移 1～2 個現有 skill 作為範例（`angular-code-review`、`git-commit-helper`）
- [x] 撰寫 `README.md`
- [x] 實作 `scripts/validate-skill.sh`
- [x] 實作 `scripts/install.sh`（支援 personal + project、symlink + copy）
- [x] 實作 `scripts/lib.sh` 共用函式庫
- [x] 撰寫 `CHANGELOG.md`、`.gitignore`

### Phase 2 — CLI 與狀態管理

- [ ] 統一 `bin/skill` CLI 入口
- [ ] Install manifest 追蹤已安裝 skills
- [ ] `list --installed`、`sync`、`uninstall` 命令
- [ ] 自動生成 `SKILLS.md`

### Phase 3 — 品質與自動化

- [ ] GitHub Actions CI 驗證 PR 中的 skills
- [ ] Pre-commit hook 驗證变更的 skill
- [ ] Skill 模板腳本（`skill new <name>`  scaffold）

### Phase 4 — 進階（可選）

- [ ] 從其他 Git remote 拉取第三方 skill
- [ ] Project skill 以 submodule 方式整合
- [ ] 與 Cursor SDK / Automations 整合

---

## 10. 待決策事項

| # | 問題 | 選項 | 決策 / 狀態 |
|---|------|------|-------------|
| D1 | CLI 實作語言 | Bash only / Python / Node.js | ✅ **Bash**（Phase 1 已採用） |
| D2 | 預設安裝模式 | Symlink vs Copy | ✅ **Symlink**（personal 預設）；Copy 透過 `--copy` |
| D3 | Manifest 格式 | JSON / YAML | ✅ **JSON**（`skills/manifest.json`） |
| D4 | 是否 monorepo tag | 全 repo tag vs 每 skill 獨立 tag | 初期全 repo tag；skill 穩定後改 per-skill tag |
| D5 | 命名前綴 | 是否加 `adam-` 前綴 | ✅ 不加，目錄名即 skill name |

---

## 11. 成功標準

### Phase 1 成功標準

| # | 標準 | 狀態 |
|---|------|------|
| 1 | 在本 repo 新增一個 skill 並通過 validate | ✅ 已驗證 |
| 2 | 執行一條命令將其安裝到 `~/.cursor/skills/`，Cursor 重開後可發現該 skill | ✅ 已驗證（symlink） |
| 3 | 執行一條命令將其安裝到任意專案的 `.cursor/skills/` | ✅ 已驗證（copy） |
| 4 | 執行 uninstall 乾淨移除，不影響倉庫原始檔 | ⬜ Phase 2 |
| 5 | 所有變更有 Git 歷史可追溯 | ⬜ 待 initial commit |

### Phase 2 成功標準（待完成）

- 統一 `bin/skill` CLI 取代分散腳本
- Install manifest 追蹤已安裝 skills
- `sync`、`uninstall`、`list --installed` 可用
- 自動生成 `SKILLS.md`

---

## 12. 參考資料

- Cursor Skill 官方結構：`~/.cursor/skills-cursor/create-skill/SKILL.md`
- Personal skills 路徑：`~/.cursor/skills/`
- Project skills 路徑：`<project>/.cursor/skills/`
- **禁止寫入**：`~/.cursor/skills-cursor/`

---

*文件版本：v0.2 | 建立日期：2026-06-03 | Phase 1 完成：2026-06-03*
