#!/usr/bin/env bash
# Install skills from adam_auto_skill into a target project (CI-friendly).
#
# Usage:
#   install-skills-ci.sh --repo <git-url> --project <path> [--skills name1,name2] [--all]
#
# Environment:
#   ADAM_AUTO_SKILL_REPO  Optional override for repo URL

set -euo pipefail

REPO_URL="${ADAM_AUTO_SKILL_REPO:-}"
PROJECT_PATH=""
SKILLS_ARG=""
INSTALL_ALL=false
CLONE_DIR=""

usage() {
    cat <<'EOF'
Usage: install-skills-ci.sh --repo <url> --project <path> [options]

Options:
  --repo <url>           Git URL of adam_auto_skill repository (or set ADAM_AUTO_SKILL_REPO)
  --project <path>       Target project to install skills into
  --skills <a,b,c>       Comma-separated skill names (default: none without --all)
  --all                  Install all skills from the repository
  -h, --help             Show this help

Examples:
  ADAM_AUTO_SKILL_REPO=https://github.com/user/adam_auto_skill.git \
    ./install-skills-ci.sh --project ./my-app --all

  ./install-skills-ci.sh --repo https://github.com/user/adam_auto_skill.git \
    --project ./my-app --skills angular-code-review,git-commit-helper
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo)
            REPO_URL="${2:-}"
            shift 2
            ;;
        --project)
            PROJECT_PATH="${2:-}"
            shift 2
            ;;
        --skills)
            SKILLS_ARG="${2:-}"
            shift 2
            ;;
        --all)
            INSTALL_ALL=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "[ERROR] Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

[[ -n "$REPO_URL" ]] || { echo "[ERROR] --repo or ADAM_AUTO_SKILL_REPO is required" >&2; exit 1; }
[[ -n "$PROJECT_PATH" ]] || { echo "[ERROR] --project is required" >&2; exit 1; }
[[ -d "$PROJECT_PATH" ]] || { echo "[ERROR] Project path does not exist: ${PROJECT_PATH}" >&2; exit 1; }

CLONE_DIR="$(mktemp -d)"
trap 'rm -rf "$CLONE_DIR"' EXIT

git clone --depth 1 "$REPO_URL" "${CLONE_DIR}/adam_auto_skill"

INSTALL_CMD=("${CLONE_DIR}/adam_auto_skill/bin/skill" install --project "$PROJECT_PATH" --copy)

if [[ "$INSTALL_ALL" == "true" ]]; then
    INSTALL_CMD+=(--all)
elif [[ -n "$SKILLS_ARG" ]]; then
    IFS=',' read -ra SKILL_NAMES <<< "$SKILLS_ARG"
    INSTALL_CMD+=("${SKILL_NAMES[@]}")
else
    echo "[ERROR] Specify --all or --skills" >&2
    exit 1
fi

"${INSTALL_CMD[@]}"
echo "[INFO] Skills installed into ${PROJECT_PATH}/.cursor/skills/"
