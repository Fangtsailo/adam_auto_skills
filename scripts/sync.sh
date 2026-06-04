#!/usr/bin/env bash
# Sync installed skills from the repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

SYNC_ALL=false
SKILL_NAMES=()

usage() {
    cat <<'EOF'
Usage: sync.sh [options] [skill-name...]

Re-sync installed skills from this repository.

Options:
  -g, --global, --personal   Sync personal install location (~/.cursor/skills/)
  -p, --project <path>       Sync project install location
  -a, --all                  Sync all skills listed in the install manifest
  -h, --help                 Show this help

Examples:
  ./scripts/sync.sh --global angular-code-review
  ./scripts/sync.sh --all --global
  ./scripts/sync.sh --all --project ~/projects/my-app
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--all)
            SYNC_ALL=true
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

if [[ "$SYNC_ALL" == "true" ]]; then
    mapfile -t SKILL_NAMES < <(manifest_list_skill_names "$TARGET_DIR")
    if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
        mapfile -t SKILL_NAMES < <(
            for skill_name in $(list_repo_skills); do
                if [[ -e "${TARGET_DIR}/${skill_name}" || -L "${TARGET_DIR}/${skill_name}" ]]; then
                    echo "$skill_name"
                fi
            done
        )
    fi
fi

if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
    usage
    exit 1
fi

for skill_name in "${SKILL_NAMES[@]}"; do
    if ! "${SCRIPT_DIR}/validate-skill.sh" "$skill_name" >/dev/null 2>&1; then
        die "Skill failed validation: ${skill_name}"
    fi
    sync_skill_at_target "$skill_name" "$TARGET_DIR"
done

log_info "Successfully synced ${#SKILL_NAMES[@]} skill(s)"
