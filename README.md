# Adam Auto Skill

Personal Cursor Agent Skills 的集中管理倉庫。以 Git 追蹤所有自訂 skills，並可安裝到本機 Personal 目錄或任意專案的 Project 目錄。

## 快速開始

```bash
# 驗證所有 skills
./scripts/validate-skill.sh --all

# 安裝到本機（~/.cursor/skills/，預設 symlink）
./scripts/install.sh --global angular-code-review

# 安裝多個 skills
./scripts/install.sh --global git-commit-helper angular-code-review

# 安裝到指定專案（複製模式，適合分享給他人）
./scripts/install.sh --project ~/projects/my-app angular-code-review --copy

# 安裝全部 skills 到本機
./scripts/install.sh --all --global

# 安裝全部 skills 到指定專案（建議 --copy）
./scripts/install.sh --all --project ~/projects/my-app --copy
```

安裝後重新開啟 Cursor，Agent 即可發現已部署的 skills。

## 目錄結構

```
adam_auto_skill/
├── skills/                  # 所有 skills 的來源
│   ├── manifest.json        # Skill 索引
│   ├── angular-code-review/
│   └── git-commit-helper/
├── scripts/
│   ├── validate-skill.sh    # 驗證 skill 結構
│   └── install.sh           # 安裝 skill
├── initial.md               # 專案需求規格
└── README.md
```

## Skills 一覽

| Skill | 標籤 | 說明 |
|-------|------|------|
| `angular-code-review` | angular, code-review | Angular 程式碼審查（NGXS、inject()、TypeScript） |
| `git-commit-helper` | git, commit | 依 diff 產生 commit message |

完整索引見 [`skills/manifest.json`](skills/manifest.json)。

## 新增 Skill

1. 在 `skills/<skill-name>/` 建立目錄
2. 撰寫 `SKILL.md`（含 `name`、`description` frontmatter）
3. 更新 `skills/manifest.json`
4. 執行驗證：

```bash
./scripts/validate-skill.sh <skill-name>
```

5. Git commit（建議格式：`skill(<name>): <description>`）

### SKILL.md 規範

- 目錄名與 frontmatter `name` 必須一致
- `name`：小寫、數字、連字號，最多 64 字元
- `description`：最多 1024 字元，第三人稱，包含 WHAT 與 WHEN

## 安裝選項

| 選項 | 說明 |
|------|------|
| `--global` / `--personal` | 安裝到 `~/.cursor/skills/` |
| `--project <path>` | 安裝到 `<path>/.cursor/skills/` |
| `--copy` | 複製檔案（預設為 symlink） |
| `--force` | 覆寫已存在的 skill |
| `--all` | 安裝倉庫內全部 skills（可與 `--global` 或 `--project` 搭配） |

### 常用安裝情境

| 情境 | 指令 |
|------|------|
| 本機安裝單一 skill | `./scripts/install.sh --global <name>` |
| 本機安裝全部 skills | `./scripts/install.sh --all --global` |
| 專案安裝單一 skill | `./scripts/install.sh --project <path> <name> --copy` |
| 專案安裝全部 skills | `./scripts/install.sh --all --project <path> --copy` |
| 覆寫已存在的 skill | 加上 `--force` |

> `--all` 與 `--project` 可任意組合；參數順序不拘（例如 `--project <path> --all --copy` 亦可）。

### Symlink vs Copy

- **Symlink（預設）**：修改本 repo 後立即生效，適合本機開發
- **Copy**：獨立副本，適合安裝到他人專案或離線環境

## 存放路徑參考

| 類型 | 路徑 | 作用域 |
|------|------|--------|
| Personal | `~/.cursor/skills/` | 所有專案 |
| Project | `<project>/.cursor/skills/` | 單一 repo |
| Built-in | `~/.cursor/skills-cursor/` | Cursor 內建（**禁止寫入**） |

## 開發路線圖

- **Phase 1**（目前）：基礎倉庫、validate、install
- **Phase 2**：統一 CLI（`bin/skill`）、install manifest、sync/uninstall
- **Phase 3**：CI 驗證、pre-commit hook、skill scaffold

詳細規格見 [`initial.md`](initial.md)。

## License

Private — personal skill collection.
