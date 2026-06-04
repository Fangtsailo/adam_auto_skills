#!/usr/bin/env bash
# Show detailed information about a skill.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

usage() {
    cat <<'EOF'
Usage: info.sh [options] <skill-name>

Show skill details from the repository catalog and optional install status.

Options:
  -g, --global, --personal   Check personal install status
  -p, --project <path>       Check project install status
  -h, --help                 Show this help

Examples:
  ./scripts/info.sh angular-code-review
  ./scripts/info.sh --global git-commit-helper
EOF
}

CHECK_INSTALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -g|--global|--personal|-p|--project)
            CHECK_INSTALL=true
            break
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            die "Unknown option: $1"
            ;;
        *)
            break
            ;;
    esac
done

if [[ "$CHECK_INSTALL" == "true" ]]; then
    parse_common_target_options "$@"
else
    REMAINING_ARGS=("$@")
fi

SKILL_NAME="${REMAINING_ARGS[0]:-}"
[[ -n "$SKILL_NAME" ]] || { usage; exit 1; }

is_valid_skill_name "$SKILL_NAME" || die "Invalid skill name: ${SKILL_NAME}"

SOURCE_PATH="$(skill_source_path "$SKILL_NAME")"
[[ -d "$SOURCE_PATH" ]] || die "Skill not found: ${SKILL_NAME}"

SKILL_MD="${SOURCE_PATH}/SKILL.md"
[[ -f "$SKILL_MD" ]] || die "Missing SKILL.md for: ${SKILL_NAME}"

FM_NAME="$(extract_frontmatter_name "$SKILL_MD")"
FM_DESC="$(extract_frontmatter_description "$SKILL_MD")"

echo "Skill: ${SKILL_NAME}"
echo "Path:  ${SOURCE_PATH}"
echo ""
echo "Frontmatter name:        ${FM_NAME}"
echo "Frontmatter description: ${FM_DESC}"

if entry="$(get_skill_catalog_entry "$SKILL_NAME" 2>/dev/null)"; then
    ENTRY="$entry" python3 <<'PY'
import json
import os

entry = json.loads(os.environ["ENTRY"])
print(f"Catalog version:         {entry.get('version', 'n/a')}")
print(f"Tags:                    {', '.join(entry.get('tags', []))}")
PY
else
    log_warn "Skill not listed in skills/manifest.json"
fi

if [[ "$CHECK_INSTALL" == "true" ]]; then
    TARGET_DIR="$(resolve_target_dir "$TARGET_TYPE" "$PROJECT_PATH")"
    TARGET_PATH="${TARGET_DIR}/${SKILL_NAME}"
    echo ""
    echo "Install target: ${TARGET_DIR}"

    if [[ -e "$TARGET_PATH" || -L "$TARGET_PATH" ]]; then
        mode="$(detect_install_mode "$TARGET_PATH")"
        echo "Installed: yes (${mode})"
        if [[ -f "$(manifest_file_for_dir "$TARGET_DIR")" ]]; then
            manifest_py get-details \
                --manifest "$(manifest_file_for_dir "$TARGET_DIR")" \
                --skill-name "$SKILL_NAME"
        fi
    else
        echo "Installed: no"
    fi
fi
