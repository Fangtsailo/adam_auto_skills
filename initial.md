# Adam Auto Skill — 專案需求規格

> 個人 Cursor Agent Skills 的集中管理與跨專案安裝工具

---

## 0. 實作進度

**目前階段：Phase 4 完成 ✅**

| 階段 | 狀態 | 說明 |
|------|------|------|
| Phase 1 — 基礎倉庫（MVP） | ✅ 完成 | Git 初始化、skills 倉庫、validate/install 腳本、README |
| Phase 2 — CLI 與狀態管理 | ✅ 完成 | `bin/skill`、install manifest、sync/uninstall、SKILLS.md |
| Phase 3 — 品質與自動化 | ✅ 完成 | CI、pre-commit hook、skill scaffold |
| Phase 4 — 進階 | ✅ 完成 | 遠端 pull、submodule、CI/SDK 整合文件 |

### 已交付項目（Phase 1–4）

| 項目 | 路徑 / 指令 | 狀態 |
|------|-------------|------|
| 遠端登錄 | `config/remotes.json` | ✅ |
| 拉取遠端 skill | `./bin/skill pull <remote>/<name>` | ✅ |
| Submodule 管理 | `./bin/skill submodule` | ✅ |
| CI/SDK 整合文件 | `docs/automations.md` | ✅ |
| CI 安裝範例 | `examples/install-skills-ci.sh` | ✅ |
| 統一 CLI | `bin/skill` | ✅ |
| 品質自動化 | CI + pre-commit + validate | ✅ |

### 已驗證行為

- `./bin/skill remote add` + `./bin/skill pull <remote>/<skill>` — 從 Git 遠端拉取 skill
- `./bin/skill submodule list` — submodule 狀態查詢
- `file://` 本機 repo 作為 remote 測試 pull 成功

### 待辦（可選）

- Push remote 至 GitHub（若尚未設定）
- 實際 submodule add 需獨立 skill repo（指令已就緒）

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
| G2 | **版本管理** | 以 Git 追蹤每個 skill 的演進，支援 tag / release | ✅ Git 已使用（Phase 1–2 commits）；tag 待後續 |
| G3 | **選擇性安裝** | 可安裝全部、單一、或多個指定 skills 到目標位置 | ✅ Phase 1 |
| G4 | **可更新 / 可移除** | 支援 sync、upgrade、uninstall，避免殘留舊版 | ✅ Phase 2 |
| G5 | **品質一致** | 提供驗證腳本，確保 frontmatter、命名、結構符合規範 | ✅ Phase 1–3（含 CI / pre-commit） |

### 2.3 非目標（初期不做）

- 不管理 Cursor 內建 skills（`skills-cursor`）
- 不做公開 npm registry 或 marketplace
- 不取代 Cursor IDE 內建的 skill 創建 UI
- 初期不支援 Windows 以外的特殊路徑處理（先以 Linux / macOS 為主）

---

## 3. 使用者情境

### UC-1：新增 Skill ✅ Phase 3

> 我寫好一個新的 skill，想把它收進中央倉庫並 commit。

**方式一（推薦）：**

```bash
./bin/skill new my-skill --description "..." --tags workflow
./bin/skill validate my-skill
git commit -m "skill(my-skill): add new skill"
```

**方式二（手動）：**

1. 在 `skills/` 下建立目錄並撰寫 `SKILL.md`
2. 更新 `skills/manifest.json`
3. `./bin/skill validate <name>` 與 `./bin/skill generate`
4. Git commit & push

### UC-2：安裝到 Personal（全域）

> 我想在本機所有 Cursor 專案都能用到 `create-hook` 和 `babysit` 這兩個 skills。

```bash
# ✅ Phase 2 已實作
./bin/skill install --global angular-code-review git-commit-helper
```

### UC-3：安裝到指定專案

> 我想把 skill 裝到 `~/projects/my-app/` 的 project skills 裡，讓團隊共用。

```bash
# ✅ Phase 2 已實作
./bin/skill install --project ~/projects/my-app angular-code-review --copy
./bin/skill install --all --project ~/projects/my-app --copy
```

### UC-4：更新已安裝的 Skill ✅ Phase 2

> 中央倉庫的 skill 更新了，我想同步到已安裝的位置。

> **備註：** symlink 模式下，修改本 repo 後即時生效；copy 模式需執行 sync。

```bash
./bin/skill sync angular-code-review --global
./bin/skill sync --all --global
```

### UC-5：列出與查詢 ✅ Phase 2

> 我想看倉庫裡有哪些 skills，以及某個 skill 是否已安裝。

```bash
./bin/skill list
./bin/skill list --tags angular
./bin/skill list --installed --global
./bin/skill info angular-code-review
./bin/skill info --global angular-code-review
```

### UC-6：移除 Skill ✅ Phase 2

```bash
./bin/skill uninstall --global angular-code-review
./bin/skill uninstall --all --project ~/projects/my-app
```

---

## 4. 功能需求

### 4.1 Skill 倉庫管理

- [x] **FR-01** 所有 skills 存放於 `skills/<skill-name>/` 目錄
- [x] **FR-02** 每個 skill 必須包含 `SKILL.md`，且 frontmatter 含 `name`、`description`
- [x] **FR-03** 維護 `skills/manifest.json`（或 `SKILLS.md`）作為可讀目錄，記錄名稱、描述、版本、標籤
- [x] **FR-04** 支援 skill 分類標籤（如 `angular`、`git`、`ci`、`cursor-config`）
- [x] **FR-05** 提供 `validate` 命令檢查 skill 結構與 frontmatter 規範 → `./bin/skill validate`
- [x] **FR-05b** Manifest 與 skill 目錄一致性檢查 → `validate --all`（Phase 3）

### 4.2 安裝與部署

- [x] **FR-10** 支援 `--global` / `--personal`（安裝至 `~/.cursor/skills/`）→ `scripts/install.sh`
- [x] **FR-11** 支援 `--project <path>`（安裝至 `<path>/.cursor/skills/`）
- [x] **FR-12** 支援一次安裝多個 skills（空格分隔）
- [x] **FR-13** 支援 `--all` 安裝倉庫內全部 skills
- [x] **FR-14** 預設安裝策略：**符號連結（symlink）**；提供 `--copy` 選項改為複製
- [x] **FR-15** 安裝前檢查目標路徑是否已存在同名 skill，需 `--force` 覆寫
- [x] **FR-16** 禁止對 `~/.cursor/skills-cursor/` 進行任何寫入操作

### 4.3 更新與移除

- [x] **FR-20** `sync` 重新指向或複製最新版本 → `./bin/skill sync`
- [x] **FR-21** `uninstall` 移除 symlink 或複製的目錄，不影響倉庫原始檔 → `./bin/skill uninstall`
- [x] **FR-22** 記錄已安裝狀態 → `<target>/.cursor/skills/.adam-manifest.json`

### 4.4 Git 工作流

- [x] **FR-30** 本 repo 以 Git 管理（Phase 1–3 commits）
- [ ] **FR-31** 建議 commit 格式：`skill(<name>): <description>`，例如 `skill(angular-review): add NGXS checklist`
- [ ] **FR-32** 重大變更以 Git tag 標記版本（如 `angular-review/v1.2.0`）
- [x] **FR-33** 提供 `CHANGELOG.md` 或各 skill 目錄下 `CHANGELOG.md` 記錄變更

### 4.5 文件與可發現性

- [x] **FR-40** 根目錄 `README.md` 說明專案用途、快速開始、指令參考
- [ ] **FR-41** 各 skill 可選 `README.md` 補充使用範例（`SKILL.md` 保持精簡）
- [x] **FR-42** `SKILLS.md` 自動或半自動生成 skill 總覽表 → `./bin/skill generate`

### 4.6 品質與自動化（Phase 3）

- [x] **FR-50** GitHub Actions CI 驗證 skills → `.github/workflows/validate.yml`
- [x] **FR-51** Pre-commit hook 驗證變更的 skills → `scripts/hooks/pre-commit`
- [x] **FR-52** Skill scaffold 模板 → `./bin/skill new <name>`
- [x] **FR-53** Hook 安裝指令 → `./bin/skill hooks install`

### 4.7 進階整合（Phase 4）

- [x] **FR-60** 遠端 skill 來源登錄 → `config/remotes.json` + `./bin/skill remote`
- [x] **FR-61** 從遠端拉取 skill → `./bin/skill pull <remote>/<name>`
- [x] **FR-62** Submodule 整合 → `./bin/skill submodule`
- [x] **FR-63** CI / SDK 整合文件 → `docs/automations.md`

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
│   ├── manifest.py            # ✅ Install manifest 管理
│   ├── validate-skill.sh      # ✅ 驗證 skill 結構
│   ├── install.sh / sync.sh / uninstall.sh
│   ├── new-skill.sh           # ✅ Skill scaffold（Phase 3）
│   ├── generate-skills-md.sh
│   ├── install-hooks.sh
│   └── hooks/pre-commit       # ✅ Pre-commit hook（Phase 3）
├── bin/
│   └── skill                  # ✅ 統一 CLI 入口
├── SKILLS.md                  # ✅ 自動產生目錄
└── .github/workflows/
    └── validate.yml           # ✅ CI 驗證（Phase 3）
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
更新 install manifest（記錄來源路徑、模式、時間）  ← ✅ Phase 2
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

## 8. CLI 指令規格

**統一 CLI（Phase 2–3，✅ 已實作）：**

```bash
./bin/skill list [--installed] [--tags <tag>]
./bin/skill info <name> [--global|--project <path>]
./bin/skill validate [--all] [<name>...]
./bin/skill new <name> [--description "..."] [--tags tag1,tag2]   # Phase 3
./bin/skill install [options] [<names>...]
./bin/skill sync [options] [<names>...]
./bin/skill uninstall [options] [<names>...]
./bin/skill generate
./bin/skill hooks install
./bin/skill remote list | remote add <name> <url>
./bin/skill pull <remote>/<skill>
./bin/skill submodule add|update|remove|list
```

**Phase 1 腳本（仍可用，行為一致）：**

```bash
./scripts/validate-skill.sh [--all] [<name>...]
./scripts/install.sh [options] [<names>...]
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

- [x] 初始化 Git repo（initial commit 完成；Phase 2 commit 完成）
- [x] 建立 `skills/` 目錄結構與 `manifest.json` 格式
- [x] 遷移 1～2 個現有 skill 作為範例（`angular-code-review`、`git-commit-helper`）
- [x] 撰寫 `README.md`
- [x] 實作 `scripts/validate-skill.sh`
- [x] 實作 `scripts/install.sh`（支援 personal + project、symlink + copy）
- [x] 實作 `scripts/lib.sh` 共用函式庫
- [x] 撰寫 `CHANGELOG.md`、`.gitignore`

### Phase 2 — CLI 與狀態管理 ✅ 完成

- [x] 統一 `bin/skill` CLI 入口
- [x] Install manifest 追蹤已安裝 skills（`.adam-manifest.json` + `scripts/manifest.py`）
- [x] `list --installed`、`sync`、`uninstall` 命令
- [x] 自動生成 `SKILLS.md`（`./bin/skill generate`）
- [x] `list`、`info` 命令

### Phase 3 — 品質與自動化 ✅ 完成

- [x] GitHub Actions CI 驗證 PR 中的 skills（`.github/workflows/validate.yml`）
- [x] Pre-commit hook 驗證變更的 skill（`scripts/hooks/pre-commit`）
- [x] Skill 模板腳本（`./bin/skill new <name>`）
- [x] Manifest 一致性驗證（`validate --all`）
- [x] Hook 安裝器（`./bin/skill hooks install`）

### Phase 4 — 進階 ✅ 完成

- [x] 從其他 Git remote 拉取第三方 skill（`remote` + `pull`）
- [x] Project skill 以 submodule 方式整合（`submodule add/update/remove`）
- [x] 與 Cursor SDK / Automations 整合（`docs/automations.md` + CI 範例）

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
| 4 | 執行 uninstall 乾淨移除，不影響倉庫原始檔 | ✅ 已驗證 |
| 5 | 所有變更有 Git 歷史可追溯 | ✅ initial commit 完成 |

### Phase 2 成功標準

| # | 標準 | 狀態 |
|---|------|------|
| 1 | 統一 `bin/skill` CLI 取代分散腳本 | ✅ |
| 2 | Install manifest 追蹤已安裝 skills | ✅ |
| 3 | `sync`、`uninstall`、`list --installed` 可用 | ✅ |
| 4 | 自動生成 `SKILLS.md` | ✅ |

### Phase 3 成功標準

| # | 標準 | 狀態 |
|---|------|------|
| 1 | GitHub Actions CI 驗證 PR 中的 skills | ✅ |
| 2 | Pre-commit hook 驗證變更的 skill | ✅ |
| 3 | `skill new <name>` scaffold 模板 | ✅ |

### Phase 4 成功標準

| # | 標準 | 狀態 |
|---|------|------|
| 1 | 從其他 Git remote 拉取第三方 skill | ✅ |
| 2 | Project skill 以 submodule 方式整合 | ✅ |
| 3 | 與 Cursor SDK / Automations 整合文件與範例 | ✅ |

---

## 12. 參考資料

- Cursor Skill 官方結構：`~/.cursor/skills-cursor/create-skill/SKILL.md`
- Personal skills 路徑：`~/.cursor/skills/`
- Project skills 路徑：`<project>/.cursor/skills/`
- **禁止寫入**：`~/.cursor/skills-cursor/`

---

*文件版本：v0.5 | Phase 4 完成：2026-06-03*
