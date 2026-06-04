#!/usr/bin/env bash
# Uninstall skills from personal or project Cursor skills directories.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

UNINSTALL_ALL=false
SKILL_NAMES=()

usage() {
    cat <<'EOF'
Usage: uninstall.sh [options] [skill-name...]

Remove installed skills from a target location. Does not modify this repository.

Options:
  -g, --global, --personal   Uninstall from ~/.cursor/skills/
  -p, --project <path>       Uninstall from <path>/.cursor/skills/
  -a, --all                  Uninstall all skills tracked in the install manifest
  -h, --help                 Show this help

Examples:
  ./scripts/uninstall.sh --global angular-code-review
  ./scripts/uninstall.sh --all --global
  ./scripts/uninstall.sh --project ~/projects/my-app git-commit-helper
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--all)
            UNINSTALL_ALL=true
            shift
            ;;
        -g|--global|--personal|-p|--project)
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
            SKILL_NAMES+=("$1")
            shift
            ;;
    esac
done

parse_common_target_options "$@"

if [[ ${#REMAINING_ARGS[@]} -gt 0 ]]; then
    SKILL_NAMES+=("${REMAINING_ARGS[@]}")
fi

TARGET_DIR="$(resolve_target_dir "$TARGET_TYPE" "$PROJECT_PATH")"
log_info "Target directory: ${TARGET_DIR}"

if [[ "$UNINSTALL_ALL" == "true" ]]; then
    mapfile -t SKILL_NAMES < <(manifest_list_skill_names "$TARGET_DIR")
    if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
        for skill_name in $(list_repo_skills); do
            if [[ -e "${TARGET_DIR}/${skill_name}" || -L "${TARGET_DIR}/${skill_name}" ]]; then
                SKILL_NAMES+=("$skill_name")
            fi
        done
    fi
fi

if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
    usage
    exit 1
fi

for skill_name in "${SKILL_NAMES[@]}"; do
    uninstall_skill_from_target "$skill_name" "$TARGET_DIR"
done

log_info "Successfully uninstalled ${#SKILL_NAMES[@]} skill(s)"
