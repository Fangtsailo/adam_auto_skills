#!/usr/bin/env bash
# Manage skills imported as Git submodules.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

SUBCMD=""
SKILL_NAME=""
REPO_URL=""
BRANCH="main"
FORCE=false

usage() {
    cat <<'EOF'
Usage: submodule-skill.sh <command> [options] [args...]

Commands:
  add <url> <skill-name>     Add skill repo as git submodule under skills/
  update [skill-name]        Update submodule(s)
  remove <skill-name>        Remove submodule and manifest entry
  list                       List skill submodules

Options:
  -b, --branch <name>        Branch for submodule (default: main)
  -f, --force                Overwrite existing path when adding
  -h, --help                 Show this help

Examples:
  ./bin/skill submodule add https://github.com/org/my-skill.git my-skill
  ./bin/skill submodule update my-skill
  ./bin/skill submodule remove my-skill
EOF
}

update_manifest_submodule() {
    local skill_name="$1"
    local url="$2"
    local branch="$3"
    local skill_md="${SKILLS_DIR}/${skill_name}/SKILL.md"

    python3 - "$SKILLS_DIR/manifest.json" "$skill_name" "$url" "$branch" "$skill_md" <<'PY'
import json
import sys
from pathlib import Path

manifest_file, skill_name, url, branch, skill_md = sys.argv[1:6]
description = ""
path = Path(skill_md)
if path.exists():
    text = path.read_text(encoding="utf-8")
    if text.startswith("---"):
        parts = text.split("---", 2)
        if len(parts) >= 3:
            for line in parts[1].splitlines():
                if line.strip().startswith("description:"):
                    description = line.split(":", 1)[1].strip().strip("'\"")
                    break

with open(manifest_file, encoding="utf-8") as handle:
    data = json.load(handle)

skills = data.setdefault("skills", [])
skills = [item for item in skills if item.get("name") != skill_name]
skills.append(
    {
        "name": skill_name,
        "description": description or f"Submodule skill: {skill_name}",
        "tags": ["submodule", "imported"],
        "version": "1.0.0",
        "install_type": "submodule",
        "source": {"submodule": True, "url": url, "branch": branch},
    }
)
skills.sort(key=lambda item: item.get("name", ""))
data["skills"] = skills

with open(manifest_file, "w", encoding="utf-8") as handle:
    json.dump(data, handle, indent=4)
    handle.write("\n")
PY
}

remove_manifest_entry() {
    local skill_name="$1"
    python3 - "$SKILLS_DIR/manifest.json" "$skill_name" <<'PY'
import json
import sys

manifest_file, skill_name = sys.argv[1:3]
with open(manifest_file, encoding="utf-8") as handle:
    data = json.load(handle)
data["skills"] = [item for item in data.get("skills", []) if item.get("name") != skill_name]
with open(manifest_file, "w", encoding="utf-8") as handle:
    json.dump(data, handle, indent=4)
    handle.write("\n")
PY
}

cmd_add() {
    [[ -n "$REPO_URL" && -n "$SKILL_NAME" ]] || die "Usage: submodule add <url> <skill-name>"

    is_valid_skill_name "$SKILL_NAME" || die "Invalid skill name: ${SKILL_NAME}"

    local target_path="${SKILLS_DIR}/${SKILL_NAME}"
    if [[ -e "$target_path" || -L "$target_path" ]]; then
        [[ "$FORCE" == "true" ]] || die "Path already exists: ${target_path}. Use --force."
        remove_skill_at_target "$target_path"
    fi

    cd "$REPO_ROOT"
    if [[ -f ".gitmodules" ]] && grep -q "path = skills/${SKILL_NAME}" .gitmodules 2>/dev/null; then
        die "Submodule already registered for skills/${SKILL_NAME}"
    fi

    git submodule add -b "$BRANCH" "$REPO_URL" "skills/${SKILL_NAME}"

    [[ -f "${target_path}/SKILL.md" ]] || die "Submodule added but SKILL.md not found at skills/${SKILL_NAME}"

    update_manifest_submodule "$SKILL_NAME" "$REPO_URL" "$BRANCH"
    "${SCRIPT_DIR}/validate-skill.sh" "$SKILL_NAME"
    "${SCRIPT_DIR}/generate-skills-md.sh"

    log_info "Added submodule skill: ${SKILL_NAME}"
    log_info "  URL: ${REPO_URL}"
    log_info "  Branch: ${BRANCH}"
}

cmd_update() {
    cd "$REPO_ROOT"

    if [[ -n "$SKILL_NAME" ]]; then
        git submodule update --remote "skills/${SKILL_NAME}"
        log_info "Updated submodule: ${SKILL_NAME}"
        return
    fi

    git submodule update --remote --recursive
    log_info "Updated all submodules"
}

cmd_remove() {
    [[ -n "$SKILL_NAME" ]] || die "Usage: submodule remove <skill-name>"

    cd "$REPO_ROOT"
    local submodule_path="skills/${SKILL_NAME}"

    if [[ ! -d "$submodule_path" ]]; then
        log_warn "Submodule path not found: ${submodule_path}"
    else
        git submodule deinit -f "$submodule_path" 2>/dev/null || true
        git rm -f "$submodule_path" 2>/dev/null || rm -rf "$submodule_path"
    fi

    remove_manifest_entry "$SKILL_NAME"
    "${SCRIPT_DIR}/generate-skills-md.sh"
    log_info "Removed submodule skill: ${SKILL_NAME}"
}

cmd_list() {
    cd "$REPO_ROOT"
    if [[ ! -f ".gitmodules" ]]; then
        echo "No submodules configured."
        return
    fi
    echo "Skill submodules:"
    git config -f .gitmodules --get-regexp path | while read -r _ path; do
        [[ "$path" == skills/* ]] || continue
        echo "  ${path#skills/}"
    done
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        add|update|remove|list)
            SUBCMD="$1"
            shift
            break
            ;;
        -b|--branch)
            BRANCH="${2:-}"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
done

case "$SUBCMD" in
    add)
        REPO_URL="${1:-}"
        SKILL_NAME="${2:-}"
        cmd_add
        ;;
    update)
        SKILL_NAME="${1:-}"
        cmd_update
        ;;
    remove)
        SKILL_NAME="${1:-}"
        cmd_remove
        ;;
    list)
        cmd_list
        ;;
    *)
        usage
        exit 1
        ;;
esac
