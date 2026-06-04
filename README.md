# Adam Auto Skill

以 Git 集中管理 Cursor Agent Skills，並安裝到本機或專案。

| 安裝目標 | 路徑 |
|----------|------|
| 本機（所有專案） | `~/.cursor/skills/` |
| 單一專案 | `<project>/.cursor/skills/` |

安裝後請**重新開啟 Cursor**。擴充、CLI 完整規格與貢獻流程見 **[`initial.md`](initial.md)**。

---

## 快速開始

```bash
git clone <your-repo-url> adam_auto_skill && cd adam_auto_skill
chmod +x bin/skill scripts/*.sh

./bin/skill list
./bin/skill install --global angular-code-review    # 本機，預設 symlink
./bin/skill list --installed --global

# 裝到某專案（建議 copy）
./bin/skill install --project ~/projects/my-app angular-code-review --copy
```

---

## 常用指令

```bash
./bin/skill help

./bin/skill list [--tags <tag>]
./bin/skill info <name> [--global]
./bin/skill install [--global | --project <path>] [<name>...] [--all] [--copy] [--force]
./bin/skill sync [--global | --project <path>] [<name>...] [--all]
./bin/skill uninstall [--global | --project <path>] [<name>...] [--all]
```

| 需求 | 指令 |
|------|------|
| 本機安裝全部 | `./bin/skill install --all --global` |
| 專案安裝全部 | `./bin/skill install --all --project <path> --copy` |
| 更新 copy 安裝 | `./bin/skill sync --all --project <path>` |
| 查看已安裝 | `./bin/skill list --installed --global` |

**安裝模式：** 本機開發用預設 **symlink**（改 central repo 即生效）；專案 / CI 建議 **`--copy`**（需 `sync` 更新）。詳見 [`initial.md` §7](initial.md#7-安裝機制設計)。

---

## 內建 Skills

| Skill | 說明 |
|-------|------|
| `angular-code-review` | Angular 程式碼審查（NGXS、`inject()`、TypeScript） |
| `git-commit-helper` | 依 staged diff 產生 commit message |

完整列表：[`SKILLS.md`](SKILLS.md)

---

## 維護本倉庫（簡要）

```bash
./bin/skill new <name> --description "..." --tags workflow
./bin/skill validate --all && ./bin/skill generate
./bin/skill hooks install   # 可選：commit 前自動驗證
```

貢獻檢查清單、遠端 pull、submodule、CI 整合 → [`initial.md`](initial.md)

---

## 相關文件

| 文件 | 用途 |
|------|------|
| [`initial.md`](initial.md) | 完整規格、CLI、擴充與貢獻手冊 |
| [`docs/automations.md`](docs/automations.md) | 外部專案 / CI / SDK 安裝 |
| [`CHANGELOG.md`](CHANGELOG.md) | 版本紀錄 |

## License

Private — personal skill collection.
