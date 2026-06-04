#!/usr/bin/env bash
# Install git hooks for adam_auto_skill.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOKS_SRC="${SCRIPT_DIR}/hooks"
GIT_HOOKS_DIR="${REPO_ROOT}/.git/hooks"

usage() {
    cat <<'EOF'
Usage: install-hooks.sh [options]

Install git hooks from scripts/hooks/ into .git/hooks/.

Options:
  -h, --help    Show this help

Examples:
  ./scripts/install-hooks.sh
  ./bin/skill hooks install
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
done

[[ -d "$GIT_HOOKS_DIR" ]] || die "Not a git repository: ${REPO_ROOT}"

for hook in "${HOOKS_SRC}"/*; do
    [[ -f "$hook" ]] || continue
    hook_name="$(basename "$hook")"
    target="${GIT_HOOKS_DIR}/${hook_name}"

    ln -sf "$hook" "$target"
    chmod +x "$hook" "$target"
    echo "[INFO] Installed hook: ${hook_name}"
done

echo "[INFO] Git hooks installed. Pre-commit will validate changed skills."
