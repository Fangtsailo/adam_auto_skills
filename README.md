# Adam Auto Skill

Personal Cursor Agent Skills 的集中管理倉庫。以 Git 追蹤所有自訂 skills，並可安裝到本機 Personal 目錄或任意專案的 Project 目錄。

## 快速開始

```bash
# 建議：使用統一 CLI
./bin/skill list
./bin/skill validate --all
./bin/skill install --global angular-code-review
./bin/skill list --installed --global

# 安裝全部 skills 到指定專案（建議 --copy）
./bin/skill install --all --project ~/projects/my-app --copy

# 同步 / 移除
./bin/skill sync --all --global
./bin/skill uninstall --global angular-code-review

# 產生 SKILLS.md 目錄
./bin/skill generate

# 建立新 skill（scaffold）
./bin/skill new my-skill --description "..." --tags workflow

# 安裝 git hooks（commit 前自動驗證 skills）
./bin/skill hooks install
```

安裝後重新開啟 Cursor，Agent 即可發現已部署的 skills。

> Phase 1 的 `./scripts/install.sh`、`./scripts/validate-skill.sh` 仍可使用，行為與 `./bin/skill` 一致。

## CLI 指令

| 指令 | 說明 |
|------|------|
| `list` | 列出倉庫內 skills（可加 `--tags <tag>`） |
| `list --installed` | 列出已安裝 skills（搭配 `--global` 或 `--project <path>`） |
| `info <name>` | 顯示 skill 詳情（可加 `--global` 查看安裝狀態） |
| `validate [--all] [<name>...]` | 驗證 skill 結構 |
| `new <name> [options]` | 建立新 skill 模板並更新 manifest |
| `install [options] [<names>...]` | 安裝 skills |
| `sync [options] [<names>...]` | 重新同步已安裝 skills |
| `uninstall [options] [<names>...]` | 移除已安裝 skills |
| `generate` | 從 `skills/manifest.json` 產生 `SKILLS.md` |
| `hooks install` | 安裝 pre-commit hook |

### 共用 Options

| 選項 | 說明 |
|------|------|
| `--global` / `--personal` | 目標：`~/.cursor/skills/` |
| `--project <path>` | 目標：`<path>/.cursor/skills/` |
| `--copy` | 複製模式（預設 symlink） |
| `--force` | 覆寫已存在的 skill |
| `--all` | 套用至倉庫或 manifest 內全部 skills |

### 常用安裝情境

| 情境 | 指令 |
|------|------|
| 本機安裝單一 skill | `./bin/skill install --global <name>` |
| 本機安裝全部 skills | `./bin/skill install --all --global` |
| 專案安裝單一 skill | `./bin/skill install --project <path> <name> --copy` |
| 專案安裝全部 skills | `./bin/skill install --all --project <path> --copy` |
| 查看本機已安裝 | `./bin/skill list --installed --global` |
| 同步本機全部 skills | `./bin/skill sync --all --global` |
| 移除本機 skill | `./bin/skill uninstall --global <name>` |

## 目錄結構

```
adam_auto_skill/
├── bin/skill                # 統一 CLI 入口
├── skills/                  # 所有 skills 的來源
│   └── manifest.json        # Skill 索引
├── scripts/
│   ├── lib.sh               # 共用函式
│   ├── manifest.py          # Install manifest 管理
│   ├── validate-skill.sh
│   ├── install.sh
│   ├── sync.sh
│   ├── uninstall.sh
│   ├── new-skill.sh
│   ├── install-hooks.sh
│   └── hooks/pre-commit
├── .github/workflows/validate.yml
├── SKILLS.md

## Install Manifest

安裝紀錄寫入目標目錄的 `.adam-manifest.json`：

- Personal：`~/.cursor/skills/.adam-manifest.json`
- Project：`<project>/.cursor/skills/.adam-manifest.json`

記錄內容包含 skill 名稱、安裝模式（symlink/copy）、來源路徑、安裝時間。

## Skills 一覽

| Skill | 標籤 | 說明 |
|-------|------|------|
| `angular-code-review` | angular, code-review | Angular 程式碼審查（NGXS、inject()、TypeScript） |
| `git-commit-helper` | git, commit | 依 diff 產生 commit message |

完整索引見 [`SKILLS.md`](SKILLS.md) 或 [`skills/manifest.json`](skills/manifest.json)。

## 新增 Skill

**方式一（推薦）：**

```bash
./bin/skill new my-skill --description "..." --tags workflow
```

**方式二（手動）：** 建立目錄、`SKILL.md`、更新 `manifest.json`，再執行 `validate` 與 `generate`。

## 品質保障

- **Pre-commit：** `./bin/skill hooks install` — commit 前自動驗證 skills
- **CI：** `.github/workflows/validate.yml` — push/PR 時驗證全部 skills

## 存放路徑參考

| 類型 | 路徑 | 作用域 |
|------|------|--------|
| Personal | `~/.cursor/skills/` | 所有專案 |
| Project | `<project>/.cursor/skills/` | 單一 repo |
| Built-in | `~/.cursor/skills-cursor/` | Cursor 內建（**禁止寫入**） |

## 開發路線圖

- **Phase 1** ✅：基礎倉庫、validate、install
- **Phase 2** ✅：統一 CLI、install manifest、sync/uninstall、SKILLS.md
- **Phase 3** ✅：CI 驗證、pre-commit hook、skill scaffold

詳細規格見 [`initial.md`](initial.md)。

## License

Private — personal skill collection.
