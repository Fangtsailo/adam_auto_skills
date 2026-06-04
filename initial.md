# Adam Auto Skill — 專案規格與擴充手冊

> 個人 Cursor Agent Skills 的集中管理與跨專案安裝工具  
> **本文件：** 維護者與後續擴充用的完整規格（CLI、架構、貢獻、整合）  
> **一般使用者：** 請先看 [`README.md`](README.md) 快速上手

**專案版本：** 1.3.0（見 [`CHANGELOG.md`](CHANGELOG.md)）  
**文件版本：** v1.0 | 最後更新：2026-06-04

---

## 0. 實作進度

**目前階段：Phase 4 完成 ✅**

| 階段 | 狀態 | 說明 |
|------|------|------|
| Phase 1 — 基礎倉庫（MVP） | ✅ | Git、skills 目錄、validate/install |
| Phase 2 — CLI 與狀態管理 | ✅ | `bin/skill`、install manifest、sync/uninstall、`SKILLS.md` |
| Phase 3 — 品質與自動化 | ✅ | CI、pre-commit、`skill new` |
| Phase 4 — 進階 | ✅ | 遠端 pull、submodule、CI/SDK 文件 |

### 已交付項目

| 項目 | 路徑 / 指令 |
|------|-------------|
| 統一 CLI | `bin/skill` |
| Install manifest | `scripts/manifest.py` → `.adam-manifest.json` |
| 遠端登錄 | `config/remotes.json` + `./bin/skill remote` |
| 拉取遠端 skill | `./bin/skill pull <remote>/<name>` |
| Submodule | `./bin/skill submodule` |
| CI/SDK 文件 | `docs/automations.md`、`examples/` |
| 品質自動化 | `.github/workflows/validate.yml`、pre-commit hook |

### 已驗證行為

- `remote add` + `pull <remote>/<skill>` — shallow clone 後 copy 至 `skills/`
- `submodule list` — submodule 狀態查詢
- `file://` 本機 repo 作為 remote 測試 pull

### 待辦（可選）

- 遠端 push 至 GitHub（若尚未設定）
- Per-skill Git tag（見 FR-32）
- 各 skill 可選 `README.md`（見 FR-41）

---

## 1. 專案背景

### 1.1 什麼是 Agent Skill？

Agent Skill 是 Cursor 中用來教導 AI Agent 執行特定任務的 Markdown 指令集。每個 skill 以目錄形式存在，核心檔案為 `SKILL.md`（含 YAML frontmatter 與 Markdown 正文），可選附帶 `reference.md`、`examples.md`、`scripts/` 等。

### 1.2 Cursor Skill 存放位置

| 類型 | 路徑 | 作用域 | 本工具 |
|------|------|--------|--------|
| **Personal** | `~/.cursor/skills/<skill-name>/` | 所有專案 | `install --global` |
| **Project** | `<project>/.cursor/skills/<skill-name>/` | 單一 repo | `install --project <path>` |
| **Built-in** | `~/.cursor/skills-cursor/` | Cursor 內建 | **禁止寫入** |

### 1.3 現有痛點

- Skills 分散，難以統一維護與版本追蹤
- 換機或新專案需手動複製，易遺漏
- 無法快速選擇安裝 subset 到指定專案
- 缺乏統一命名、描述與驗證標準

### 1.4 環境需求

| 項目 | 說明 |
|------|------|
| **作業系統** | Linux / macOS 為主；Windows symlink 需額外權限 |
| **Bash** | 4+ |
| **Python 3** | manifest、remotes、`validate --all`、`generate` |
| **Git** | 版本追蹤、submodule、遠端 pull |
| **Cursor** | 安裝 skill 後需重開 IDE |

指令請在 **repo 根目錄** 執行，或以 `bin/skill` 絕對路徑呼叫。

---

## 2. 專案願景與目標

### 2.1 願景

以 Git 管理的 **Skills 中央倉庫**（Single Source of Truth），可部署至 Personal 或任意 Project 的 `.cursor/skills/`。

### 2.2 核心目標

| # | 目標 | 狀態 |
|---|------|------|
| G1 | 集中收納所有自訂 skills | ✅ |
| G2 | Git 版本管理（tag 待後續） | ✅ |
| G3 | 選擇性安裝（單一 / 多個 / 全部） | ✅ |
| G4 | sync / uninstall | ✅ |
| G5 | 驗證與 CI / pre-commit | ✅ |

### 2.3 非目標

- 不管理 `skills-cursor` 內建 skills
- 不做公開 marketplace / npm registry
- 不取代 Cursor IDE 內建 skill UI
- 初期不以 Windows 路徑為主要設計對象

---

## 3. 使用者情境

### UC-1：新增 Skill

```bash
./bin/skill new my-skill --description "Does X. Use when Y." --tags workflow
./bin/skill validate my-skill
./bin/skill generate
git commit -m "skill(my-skill): add new skill"
```

手動流程：建立 `skills/<name>/SKILL.md` → 更新 `manifest.json` → `validate` → `generate` → commit。

### UC-2：安裝到 Personal

```bash
./bin/skill install --global angular-code-review git-commit-helper
./bin/skill install --all --global
```

### UC-3：安裝到指定專案

```bash
./bin/skill install --project ~/projects/my-app angular-code-review --copy
./bin/skill install --all --project ~/projects/my-app --copy
```

### UC-4：更新已安裝 Skill

- **Symlink：** 修改本 repo 即時生效
- **Copy：** 需 `sync`

```bash
./bin/skill sync angular-code-review --global
./bin/skill sync --all --project ~/projects/my-app
```

### UC-5：列出與查詢

```bash
./bin/skill list
./bin/skill list --tags angular
./bin/skill list --installed --global
./bin/skill info angular-code-review
./bin/skill info --global angular-code-review
```

### UC-6：移除 Skill

```bash
./bin/skill uninstall --global angular-code-review
./bin/skill uninstall --all --project ~/projects/my-app
```

### UC-7：從遠端拉取第三方 Skill

```bash
./bin/skill remote add upstream https://github.com/org/skills-repo.git --branch main
./bin/skill pull upstream/some-skill
./bin/skill validate some-skill && ./bin/skill generate
```

### UC-8：Submodule 管理獨立 Skill Repo

```bash
./bin/skill submodule add https://github.com/org/my-skill.git my-skill
./bin/skill submodule update my-skill
```

---

## 4. 功能需求

### 4.1 Skill 倉庫管理

- [x] **FR-01** `skills/<skill-name>/`
- [x] **FR-02** 必填 `SKILL.md` + frontmatter `name`、`description`
- [x] **FR-03** `skills/manifest.json` + 自動 `SKILLS.md`
- [x] **FR-04** 標籤分類
- [x] **FR-05** `./bin/skill validate`
- [x] **FR-05b** `validate --all` manifest 一致性

### 4.2 安裝與部署

- [x] **FR-10** `--global` / `--personal`
- [x] **FR-11** `--project <path>`
- [x] **FR-12** 多 skill 一次安裝
- [x] **FR-13** `--all`
- [x] **FR-14** 預設 symlink；`--copy` 複製
- [x] **FR-15** 衝突需 `--force`
- [x] **FR-16** 禁止寫入 `skills-cursor`

### 4.3 更新與移除

- [x] **FR-20** `sync`
- [x] **FR-21** `uninstall`（不刪 central repo）
- [x] **FR-22** `.adam-manifest.json`

### 4.4 Git 工作流

- [x] **FR-30** Git 管理
- [ ] **FR-31** 建議 commit：`skill(<name>): <description>`
- [ ] **FR-32** 重大變更 per-skill 或 repo tag
- [x] **FR-33** `CHANGELOG.md`

### 4.5 文件與可發現性

- [x] **FR-40** `README.md` — 一般使用者快速上手（精簡）
- [x] **FR-40b** `initial.md` — 完整規格與擴充手冊（本文件）
- [ ] **FR-41** 各 skill 可選 `README.md`
- [x] **FR-42** `./bin/skill generate` → `SKILLS.md`

### 4.6 品質與自動化

- [x] **FR-50** GitHub Actions CI
- [x] **FR-51** pre-commit hook
- [x] **FR-52** `./bin/skill new`
- [x] **FR-53** `./bin/skill hooks install`

### 4.7 進階整合

- [x] **FR-60** `config/remotes.json` + `remote`
- [x] **FR-61** `pull <remote>/<name>`
- [x] **FR-62** `submodule`
- [x] **FR-63** `docs/automations.md` + `examples/`

---

## 5. Repository 結構

```
adam_auto_skill/
├── README.md                      # 一般使用者快速上手（精簡）
├── initial.md                     # 本文件：完整規格與擴充手冊
├── CHANGELOG.md
├── SKILLS.md                      # 自動產生，勿手動編輯
├── bin/skill                        # 統一 CLI
├── config/remotes.json
├── skills/
│   ├── manifest.json
│   ├── angular-code-review/
│   │   ├── SKILL.md
│   │   └── reference.md
│   └── git-commit-helper/
│       └── SKILL.md
├── scripts/
│   ├── lib.sh
│   ├── manifest.py
│   ├── remotes.py
│   ├── validate-skill.sh
│   ├── install.sh / sync.sh / uninstall.sh
│   ├── list.sh / info.sh
│   ├── new-skill.sh
│   ├── generate-skills-md.sh
│   ├── install-hooks.sh
│   ├── remote.sh / pull-skill.sh / submodule-skill.sh
│   └── hooks/pre-commit
├── docs/automations.md
├── examples/
│   ├── install-skills-ci.sh
│   └── github-action-install-skills.yml
└── .github/workflows/validate.yml
```

---

## 6. Skill 撰寫規範

### 6.1 目錄命名

- 小寫、數字、連字號：`my-skill-name`
- 禁止空格、底線、大寫；目錄名 = frontmatter `name`

### 6.2 Frontmatter

```yaml
---
name: my-skill-name
description: >-
  What this skill does (WHAT). Use when the user needs X (WHEN).
---
```

| 欄位 | 規則 |
|------|------|
| `name` | ≤ 64 字元；與目錄名一致 |
| `description` | ≤ 1024 字元；第三人稱；含 WHAT + WHEN |

### 6.3 內容原則

- `SKILL.md` 建議 ≤ 500 行；詳情放 `reference.md` / `examples.md`
- 附檔引用僅一層深度
- 程式碼與註解：English；使用者範例可中英並用

### 6.4 驗證檢查項（`./bin/skill validate`）

1. 目錄與 `SKILL.md` 存在；以 `---` 開頭的 YAML frontmatter
2. `name`、`description` 非空、格式與長度合法
3. 目錄名與 `name` 一致
4. 敏感資訊模式（API key、token、密碼等）
5. 不得指示寫入 `skills-cursor`
6. **`validate --all` 額外：** `manifest.json` 有效 JSON；manifest 條目與 `skills/` 目錄一致

---

## 7. 安裝機制設計

### 7.1 策略比較

| 策略 | 優點 | 缺點 | 建議用途 |
|------|------|------|----------|
| **Symlink** | 中央 repo 更新即生效 | 需 symlink 支援 | 本機 `--global`（**預設**） |
| **Copy** | 相容性佳 | 需 `sync` | 專案、CI、他人機器 |
| **Git submodule** | 版本鎖定 | 操作較複雜 | 獨立 skill repo（`submodule`） |
| **Remote pull** | 匯入第三方 skill | copy 進本 repo，非 submodule | `pull` |

### 7.2 安裝流程

```
install 命令
    → 解析目標（--global / --project）
    → validate skill
    → 檢查衝突（需 --force 覆寫）
    → symlink 或 copy 至 .cursor/skills/<name>/
    → 更新 .adam-manifest.json
```

### 7.3 目標路徑解析

| 參數 | 結果 |
|------|------|
| `--global` / `--personal` / `-g` | `$HOME/.cursor/skills/` |
| `--project <path>` / `-p` | `<path>/.cursor/skills/`（自動建立） |
| `--all` / `-a` | manifest 內全部 skills |
| `--copy` / `-c` | 複製（預設 symlink） |
| `--force` / `-f` | 覆寫已存在安裝 |

### 7.4 Install Manifest（`.adam-manifest.json`）

由 `scripts/manifest.py` 寫入**安裝目標**目錄：

| 目標 | 路徑 |
|------|------|
| Personal | `~/.cursor/skills/.adam-manifest.json` |
| Project | `<project>/.cursor/skills/.adam-manifest.json` |

每筆 skill 欄位：

| 欄位 | 說明 |
|------|------|
| `mode` | `symlink` 或 `copy` |
| `source` | 本 repo 內 skill 絕對路徑 |
| `installed_at` | ISO 8601 UTC |

`sync` / `uninstall --all` 依 manifest 運作；`uninstall` 不刪除 central repo 原始檔。

---

## 8. CLI 指令規格（完整）

```bash
./bin/skill <command> [options] [args...]
./bin/skill help    # -h / --help
```

### 8.1 指令總覽

| 指令 | 說明 |
|------|------|
| `list` | 倉庫 skills；`--tags`、`--installed` |
| `info <name>` | 詳情；`--global` / `--project` 查安裝狀態 |
| `validate [--all] [<name>...]` | 結構驗證；`--all` 含 manifest |
| `new <name>` | Scaffold + 更新 manifest |
| `install` | 安裝至目標 |
| `sync` | 重新同步已安裝 |
| `uninstall` | 移除已安裝 |
| `generate` | 產生 `SKILLS.md`（別名 `docs`） |
| `hooks install` | 安裝 pre-commit |
| `remote list` / `remote add` | 遠端 registry |
| `pull <remote>/<name>` | 從遠端拉取至 `skills/` |
| `submodule` | add / update / remove / list |

### 8.2 共用 Options（install / sync / uninstall / list --installed / info）

| 長選項 | 短選項 | 說明 |
|--------|--------|------|
| `--global` / `--personal` | `-g` | `~/.cursor/skills/` |
| `--project <path>` | `-p` | `<path>/.cursor/skills/` |
| `--copy` | `-c` | 複製模式 |
| `--force` | `-f` | 覆寫 |
| `--all` | `-a` | 全部 skills 或 manifest 內已安裝項 |

### 8.3 各命令專用 Options

**validate**

| 選項 | 說明 |
|------|------|
| `--all` / `-a` | 全部 skill + manifest 一致性 |
| `--verbose` / `-v` | 詳細輸出 |

**new**

| 選項 | 說明 |
|------|------|
| `--description` / `-d` | 必填（除非 `--force`） |
| `--tags` / `-t` | 逗號分隔（預設 `general`） |
| `--force` / `-f` | 覆寫目錄 |

**remote add**

| 選項 | 說明 |
|------|------|
| `--branch` | 預設 `main` |
| `--skills-path` | 遠端 skills 根目錄，預設 `skills` |

設定檔：`config/remotes.json`。

**pull**

| 選項 | 說明 |
|------|------|
| `--force` / `-f` | 覆寫 `skills/<name>/` |
| `--no-update-manifest` | 不更新 manifest |

**submodule**

| 子命令 | 說明 |
|--------|------|
| `add <url> <skill-name>` | `--branch`、`--force` |
| `update [skill-name]` | 更新一個或全部 |
| `remove <skill-name>` | 移除 submodule + manifest |
| `list` | 狀態列表 |

### 8.4 常用操作情境

| 情境 | 指令 |
|------|------|
| 倉庫內列表 | `./bin/skill list` |
| 標籤篩選 | `./bin/skill list --tags angular` |
| 本機安裝單一 | `./bin/skill install --global <name>` |
| 本機安裝全部 | `./bin/skill install --all --global` |
| 專案安裝（copy） | `./bin/skill install --project <path> <name> --copy` |
| 專案安裝全部 | `./bin/skill install --all --project <path> --copy` |
| 查看已安裝 | `./bin/skill list --installed --global` |
| 同步 copy 安裝 | `./bin/skill sync --all --project <path>` |
| 拉取遠端 | `./bin/skill pull <remote>/<skill>` |

### 8.5 Legacy 腳本（Phase 1）

行為與 `bin/skill` 一致，共用 install manifest：

```bash
./scripts/validate-skill.sh [--all] [-v] [<name>...]
./scripts/install.sh [options] [<names>...]
./scripts/sync.sh / uninstall.sh / list.sh / info.sh
```

---

## 9. 新增與維護 Skill（貢獻流程）

### 9.1 Scaffold（推薦）

```bash
./bin/skill new my-skill \
  --description "Does something. Use when user asks for X." \
  --tags workflow,tools
./bin/skill validate my-skill
./bin/skill generate
git add skills/my-skill skills/manifest.json SKILLS.md
git commit -m "skill(my-skill): add new skill"
```

### 9.2 貢獻者檢查清單（避免 CI 失敗）

```bash
./bin/skill validate --all -v
./bin/skill generate
git diff SKILLS.md    # 若有差異必須 commit
```

建議 commit 格式：`skill(<name>): <description>`

### 9.3 Pre-commit Hook

`./bin/skill hooks install` 後：

- 僅 staged 檔案涉及 `skills/` 時觸發
- `manifest.json` 變更或無法推斷單一 skill → `validate --all`
- 否則只驗證變更的 skill 目錄
- 若 `SKILLS.md` 需更新 → hook 自動 `git add SKILLS.md`

Hook 來源：`scripts/hooks/pre-commit`（symlink 至 `.git/hooks/`）。

---

## 10. 品質保障

### 10.1 CI（`.github/workflows/validate.yml`）

觸發：`push` / `pull_request` → `master` 或 `main`

1. `./scripts/validate-skill.sh --all -v`
2. `./scripts/generate-skills-md.sh` — `SKILLS.md` 須與 manifest 同步，否則失敗

### 10.2 本機

```bash
./bin/skill hooks install
./bin/skill validate --all && ./bin/skill generate
```

---

## 11. 遠端 Skill 與 Submodule

### 11.1 Remote Pull（copy 進本 repo）

```bash
./bin/skill remote add upstream https://github.com/org/skills-repo.git \
  --branch main --skills-path skills
./bin/skill remote list
./bin/skill pull upstream/some-skill
./bin/skill validate some-skill && ./bin/skill generate
```

- Shallow clone（`--depth 1`）
- 複製遠端 `<skills_path>/<skill-name>/` 至 `skills/<name>/`
- 預設更新 `manifest.json`（`install_type: imported`）
- **非** submodule 關係

### 11.2 Submodule

```bash
./bin/skill submodule add https://github.com/org/my-skill.git my-skill
./bin/skill submodule update [my-skill]
./bin/skill submodule list
./bin/skill submodule remove my-skill
```

適合 skill 有獨立 repo、需版本鎖定。

---

## 12. 外部專案與 CI 整合

將 skills 安裝到**其他專案**（通常 `--copy`）：

| 資源 | 路徑 |
|------|------|
| 整合指南 | `docs/automations.md` |
| Bash 腳本 | `examples/install-skills-ci.sh` |
| GitHub Actions | `examples/github-action-install-skills.yml` |

最小 Actions 片段：

```yaml
- name: Install Cursor skills
  run: |
    git clone --depth 1 https://github.com/YOUR_USER/adam_auto_skill.git /tmp/adam_auto_skill
    /tmp/adam_auto_skill/bin/skill install --all --project "${{ github.workspace }}" --copy
```

Cursor SDK 範例見 `docs/automations.md`。

---

## 13. 目前 Skills 一覽

| Skill | 版本 | 標籤 | 說明 |
|-------|------|------|------|
| `angular-code-review` | 1.0.0 | angular, code-review, typescript | NGXS、`inject()`、嚴格 TypeScript、團隊規範 |
| `git-commit-helper` | 1.0.0 | git, commit, workflow | 分析 staged diff 產生 commit message |

機器可讀：`skills/manifest.json`  
人類可讀（自動）：`SKILLS.md`

---

## 14. 實作階段規劃

### Phase 1 — 基礎倉庫 ✅

- Git、`skills/`、`manifest.json`、範例 skills
- `validate-skill.sh`、`install.sh`、`lib.sh`
- `README.md`（精簡）、`initial.md`、`CHANGELOG.md`

### Phase 2 — CLI 與狀態 ✅

- `bin/skill`、`manifest.py`、`.adam-manifest.json`
- `list`、`info`、`sync`、`uninstall`、`generate`

### Phase 3 — 品質 ✅

- GitHub Actions、pre-commit、`skill new`、`validate --all`

### Phase 4 — 進階 ✅

- `remote` / `pull`、`submodule`、`docs/automations.md`、`examples/`

### 後續擴充建議（未實作）

- Per-skill versioning / tag
- `remote remove`、manifest 欄位擴充
- Windows 路徑與 symlink 說明腳本
- Skill 市集或 sync 至雲端備份

---

## 15. 待決策事項

| # | 問題 | 決策 |
|---|------|------|
| D1 | CLI 語言 | ✅ Bash + Python 輔助 |
| D2 | 預設安裝模式 | ✅ Symlink；`--copy` 選用 |
| D3 | Manifest 格式 | ✅ JSON |
| D4 | Tag 策略 | 初期全 repo；後續可 per-skill |
| D5 | 命名前綴 | ✅ 不加 `adam-`，目錄名即 skill name |
| D6 | 文件分工 | ✅ README 精簡；initial.md 完整規格 |

---

## 16. 成功標準

### Phase 1–4

| 階段 | 關鍵驗證 | 狀態 |
|------|----------|------|
| 1 | validate + install personal/project + uninstall | ✅ |
| 2 | 統一 CLI + manifest + SKILLS.md | ✅ |
| 3 | CI + pre-commit + scaffold | ✅ |
| 4 | remote pull + submodule + automations 文件 | ✅ |

---

## 17. 參考資料與相關文件

| 文件 | 內容 |
|------|------|
| [`README.md`](README.md) | 一般使用者快速上手 |
| [`CHANGELOG.md`](CHANGELOG.md) | 版本發布 |
| [`docs/automations.md`](docs/automations.md) | CI / SDK |
| [`SKILLS.md`](SKILLS.md) | 自動目錄 |
| [`skills/manifest.json`](skills/manifest.json) | Skill 索引 |

**Cursor 路徑參考**

- 官方 skill 結構範例：`~/.cursor/skills-cursor/create-skill/SKILL.md`
- Personal：`~/.cursor/skills/`
- Project：`<project>/.cursor/skills/`
- **禁止寫入：** `~/.cursor/skills-cursor/`

---

*文件版本：v1.0 | 專案版本：1.3.0 | Phase 4 完成*
