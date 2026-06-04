#!/usr/bin/env bash
# Manage remote skill sources.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

usage() {
    cat <<'EOF'
Usage: remote.sh <command> [args...]

Commands:
  list                         List configured remotes
  add <name> <url> [options]   Register a remote repository

Options (for add):
  --branch <name>              Git branch (default: main)
  --skills-path <path>         Skills directory in remote repo (default: skills)

Examples:
  ./bin/skill remote add upstream https://github.com/org/skills-repo.git
  ./bin/skill remote list
EOF
}

SUBCMD="${1:-}"
shift || true

case "$SUBCMD" in
    list)
        exec python3 "${SCRIPT_DIR}/remotes.py" list
        ;;
    add)
        NAME="${1:-}"
        URL="${2:-}"
        [[ -n "$NAME" && -n "$URL" ]] || { usage; exit 1; }
        shift 2 || true
        exec python3 "${SCRIPT_DIR}/remotes.py" add "$NAME" "$URL" "$@"
        ;;
    -h|--help|"")
        usage
        ;;
    *)
        die "Unknown remote command: ${SUBCMD}"
        ;;
esac
