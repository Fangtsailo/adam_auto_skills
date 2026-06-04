#!/usr/bin/env bash
# Shared utilities for adam_auto_skill scripts.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"
BUILTIN_SKILLS_DIR="${HOME}/.cursor/skills-cursor"
PERSONAL_SKILLS_DIR="${HOME}/.cursor/skills"

log_info() {
    echo "[INFO] $*"
}

log_warn() {
    echo "[WARN] $*" >&2
}

log_error() {
    echo "[ERROR] $*" >&2
}

die() {
    log_error "$*"
    exit 1
}

is_valid_skill_name() {
    local name="$1"
    [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

skill_source_path() {
    local name="$1"
    echo "${SKILLS_DIR}/${name}"
}

list_repo_skills() {
    local skill_dir name
    for skill_dir in "${SKILLS_DIR}"/*/; do
        [[ -d "$skill_dir" ]] || continue
        name="$(basename "$skill_dir")"
        [[ "$name" == "manifest.json" ]] && continue
        if [[ -f "${skill_dir}/SKILL.md" ]]; then
            echo "$name"
        fi
    done | sort
}

resolve_target_dir() {
    local target_type="$1"
    local project_path="${2:-}"

    case "$target_type" in
        personal|global)
            echo "$PERSONAL_SKILLS_DIR"
            ;;
        project)
            [[ -n "$project_path" ]] || die "Project path is required for --project"
            [[ -d "$project_path" ]] || die "Project path does not exist: $project_path"
            echo "$(cd "$project_path" && pwd)/.cursor/skills"
            ;;
        *)
            die "Unknown target type: $target_type"
            ;;
    esac
}

assert_not_builtin_dir() {
    local target_dir="$1"
    local resolved_builtin
    resolved_builtin="$(cd "${BUILTIN_SKILLS_DIR}" 2>/dev/null && pwd || echo "${BUILTIN_SKILLS_DIR}")"
    local resolved_target
    resolved_target="$(cd "$(dirname "$target_dir")" 2>/dev/null && pwd)/$(basename "$target_dir")"

    if [[ "$resolved_target" == "$resolved_builtin" ]] || [[ "$resolved_target" == "${resolved_builtin}"/* ]]; then
        die "Refusing to write to Cursor built-in skills directory: ${BUILTIN_SKILLS_DIR}"
    fi
}

extract_frontmatter_field() {
    local file="$1"
    local field="$2"
    awk -v field="$field" '
        BEGIN { in_fm=0; found=0; value="" }
        /^---$/ {
            if (in_fm) { exit }
            in_fm=1
            next
        }
        in_fm && $0 ~ "^" field "[[:space:]]*:" {
            sub("^" field "[[:space:]]*:[[:space:]]*", "")
            value=$0
            if (value ~ /^>-$/ || value ~ /^>/) {
                while ((getline line) > 0) {
                    if (line ~ /^[[:space:]]+/ || line ~ /^>/) {
                        sub(/^[[:space:]]*>?[[:space:]]?/, "", line)
                        if (value == "" || value ~ /^>-$/) { value=line } else { value=value " " line }
                    } else {
                        break
                    }
                }
            }
            gsub(/^["'\''"]|["'\''"]$/, "", value)
            print value
            found=1
            exit
        }
        END { if (!found) exit 1 }
    ' "$file" 2>/dev/null || true
}

extract_frontmatter_name() {
    extract_frontmatter_field "$1" "name"
}

extract_frontmatter_description() {
    extract_frontmatter_field "$1" "description"
}

ensure_dir() {
    local dir="$1"
    mkdir -p "$dir"
}

remove_skill_at_target() {
    local target_path="$1"
    if [[ -L "$target_path" ]]; then
        rm "$target_path"
    elif [[ -d "$target_path" ]]; then
        rm -rf "$target_path"
    fi
}

install_skill_to_target() {
    local skill_name="$1"
    local target_dir="$2"
    local mode="$3"
    local force="$4"

    local source_path target_path
    source_path="$(skill_source_path "$skill_name")"
    target_path="${target_dir}/${skill_name}"

    [[ -d "$source_path" ]] || die "Skill not found in repo: ${skill_name}"
    [[ -f "${source_path}/SKILL.md" ]] || die "Skill missing SKILL.md: ${skill_name}"

    assert_not_builtin_dir "$target_dir"
    ensure_dir "$target_dir"

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        if [[ "$force" != "true" ]]; then
            die "Skill already exists at ${target_path}. Use --force to overwrite."
        fi
        remove_skill_at_target "$target_path"
    fi

    case "$mode" in
        symlink)
            ln -s "$source_path" "$target_path"
            log_info "Installed (symlink): ${skill_name} -> ${target_path}"
            ;;
        copy)
            cp -R "$source_path" "$target_path"
            log_info "Installed (copy): ${skill_name} -> ${target_path}"
            ;;
        *)
            die "Unknown install mode: ${mode}"
            ;;
    esac

    manifest_record_install "$target_dir" "$skill_name" "$mode" "$source_path"
}

manifest_file_for_dir() {
    echo "${1}/.adam-manifest.json"
}

manifest_py() {
    python3 "${REPO_ROOT}/scripts/manifest.py" --repo-root "${REPO_ROOT}" "$@"
}

manifest_read() {
    local target_dir="$1"
    manifest_py read --manifest "$(manifest_file_for_dir "$target_dir")"
}

manifest_record_install() {
    local target_dir="$1"
    local skill_name="$2"
    local mode="$3"
    local source_path="$4"

    manifest_py record \
        --manifest "$(manifest_file_for_dir "$target_dir")" \
        --skill-name "$skill_name" \
        --mode "$mode" \
        --source "$source_path"
}

manifest_remove_skill() {
    local target_dir="$1"
    local skill_name="$2"

    manifest_py remove \
        --manifest "$(manifest_file_for_dir "$target_dir")" \
        --skill-name "$skill_name"
}

manifest_list_skill_names() {
    local target_dir="$1"
    manifest_py list --manifest "$(manifest_file_for_dir "$target_dir")"
}

detect_install_mode() {
    local target_path="$1"

    if [[ -L "$target_path" ]]; then
        echo "symlink"
    elif [[ -d "$target_path" ]]; then
        echo "copy"
    else
        echo "unknown"
    fi
}

sync_skill_at_target() {
    local skill_name="$1"
    local target_dir="$2"
    local force="${3:-false}"

    local source_path target_path mode
    source_path="$(skill_source_path "$skill_name")"
    target_path="${target_dir}/${skill_name}"

    [[ -d "$source_path" ]] || die "Skill not found in repo: ${skill_name}"

    if [[ ! -e "$target_path" && ! -L "$target_path" ]]; then
        log_warn "Skill not installed at ${target_path}; installing instead"
        install_skill_to_target "$skill_name" "$target_dir" "symlink" "true"
        return
    fi

    mode="$(detect_install_mode "$target_path")"
    if [[ "$mode" == "unknown" ]]; then
        die "Cannot sync ${skill_name}: unexpected target at ${target_path}"
    fi

    local manifest_mode
    manifest_mode="$(manifest_py get-mode \
        --manifest "$(manifest_file_for_dir "$target_dir")" \
        --skill-name "$skill_name")"
    if [[ -n "$manifest_mode" ]]; then
        mode="$manifest_mode"
    fi

    remove_skill_at_target "$target_path"

    case "$mode" in
        symlink)
            ln -s "$source_path" "$target_path"
            log_info "Synced (symlink): ${skill_name} -> ${target_path}"
            ;;
        copy)
            cp -R "$source_path" "$target_path"
            log_info "Synced (copy): ${skill_name} -> ${target_path}"
            ;;
        *)
            die "Unknown install mode for sync: ${mode}"
            ;;
    esac

    manifest_record_install "$target_dir" "$skill_name" "$mode" "$source_path"
}

uninstall_skill_from_target() {
    local skill_name="$1"
    local target_dir="$2"

    local target_path
    target_path="${target_dir}/${skill_name}"

    assert_not_builtin_dir "$target_dir"

    if [[ ! -e "$target_path" && ! -L "$target_path" ]]; then
        log_warn "Skill not installed: ${skill_name} at ${target_path}"
        manifest_remove_skill "$target_dir" "$skill_name"
        return
    fi

    remove_skill_at_target "$target_path"
    manifest_remove_skill "$target_dir" "$skill_name"
    log_info "Uninstalled: ${skill_name} from ${target_dir}"
}

get_skill_tags() {
    local skill_name="$1"
    python3 - "$SKILLS_DIR/manifest.json" "$skill_name" <<'PY'
import json
import sys

manifest_file, skill_name = sys.argv[1:3]
try:
    with open(manifest_file, encoding="utf-8") as handle:
        data = json.load(handle)
except FileNotFoundError:
    sys.exit(0)

for skill in data.get("skills", []):
    if skill.get("name") == skill_name:
        print(",".join(skill.get("tags", [])))
        break
PY
}

get_skill_catalog_entry() {
    local skill_name="$1"
    python3 - "$SKILLS_DIR/manifest.json" "$skill_name" <<'PY'
import json
import sys

manifest_file, skill_name = sys.argv[1:3]
try:
    with open(manifest_file, encoding="utf-8") as handle:
        data = json.load(handle)
except FileNotFoundError:
    sys.exit(1)

for skill in data.get("skills", []):
    if skill.get("name") == skill_name:
        print(json.dumps(skill))
        sys.exit(0)

sys.exit(1)
PY
}

list_catalog_skills() {
    local tag_filter="${1:-}"
    python3 - "$SKILLS_DIR/manifest.json" "$tag_filter" <<'PY'
import json
import sys

manifest_file, tag_filter = sys.argv[1:3]
with open(manifest_file, encoding="utf-8") as handle:
    data = json.load(handle)

for skill in data.get("skills", []):
    tags = skill.get("tags", [])
    if tag_filter and tag_filter not in tags:
        continue
    name = skill.get("name", "")
    description = skill.get("description", "")
    version = skill.get("version", "")
    tag_text = ", ".join(tags)
    print(f"{name}\t{version}\t{tag_text}\t{description}")
PY
}

parse_common_target_options() {
    TARGET_TYPE=""
    PROJECT_PATH=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -g|--global|--personal)
                TARGET_TYPE="personal"
                shift
                ;;
            -p|--project)
                TARGET_TYPE="project"
                PROJECT_PATH="${2:-}"
                [[ -n "$PROJECT_PATH" ]] || die "--project requires a path argument"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done

    REMAINING_ARGS=("$@")

    if [[ -z "$TARGET_TYPE" ]]; then
        TARGET_TYPE="personal"
    fi
}

