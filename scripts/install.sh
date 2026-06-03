#!/usr/bin/env bash
# Install skills from this repo to personal or project Cursor skills directories.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

TARGET_TYPE=""
PROJECT_PATH=""
INSTALL_MODE="symlink"
FORCE=false
INSTALL_ALL=false
SKILL_NAMES=()

usage() {
    cat <<'EOF'
Usage: install.sh [options] [skill-name...]

Install skills from this repository to Cursor skills directories.

Options:
  -g, --global, --personal   Install to ~/.cursor/skills/ (default if no target set)
  -p, --project <path>       Install to <path>/.cursor/skills/
  -c, --copy                 Copy files instead of creating symlinks (default: symlink)
  -f, --force                Overwrite existing installation
  -a, --all                  Install all skills in skills/
  -h, --help                 Show this help

Examples:
  ./scripts/install.sh --global angular-code-review
  ./scripts/install.sh --global git-commit-helper angular-code-review
  ./scripts/install.sh --project ~/projects/my-app angular-code-review --copy
  ./scripts/install.sh --all --global
  ./scripts/install.sh --all --project ~/projects/my-app --copy
EOF
}

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
        -c|--copy)
            INSTALL_MODE="copy"
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -a|--all)
            INSTALL_ALL=true
            shift
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

if [[ -z "$TARGET_TYPE" ]]; then
    TARGET_TYPE="personal"
fi

if [[ "$INSTALL_ALL" == "true" ]]; then
    mapfile -t SKILL_NAMES < <(list_repo_skills)
fi

if [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
    usage
    exit 1
fi

TARGET_DIR="$(resolve_target_dir "$TARGET_TYPE" "$PROJECT_PATH")"
log_info "Target directory: ${TARGET_DIR}"
log_info "Install mode: ${INSTALL_MODE}"

for skill_name in "${SKILL_NAMES[@]}"; do
    if ! is_valid_skill_name "$skill_name"; then
        die "Invalid skill name: ${skill_name}"
    fi

    if ! "${SCRIPT_DIR}/validate-skill.sh" "$skill_name" >/dev/null 2>&1; then
        die "Skill failed validation: ${skill_name}. Run: ./scripts/validate-skill.sh ${skill_name}"
    fi

    install_skill_to_target "$skill_name" "$TARGET_DIR" "$INSTALL_MODE" "$FORCE"
done

log_info "Successfully installed ${#SKILL_NAMES[@]} skill(s)"
