#!/usr/bin/env bash
# Pull a skill from a configured remote Git repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

usage() {
    cat <<'EOF'
Usage: pull-skill.sh [options] <remote>/<skill-name>

Pull a skill directory from a configured remote into skills/.

Options:
  -f, --force                Overwrite existing skill directory
  --no-update-manifest       Do not update skills/manifest.json
  -h, --help                 Show this help

Examples:
  ./bin/skill remote add upstream https://github.com/org/skills-repo.git
  ./bin/skill pull upstream/my-skill
EOF
}

FORCE=false
NO_UPDATE_MANIFEST=false
TARGET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force)
            FORCE=true
            shift
            ;;
        --no-update-manifest)
            NO_UPDATE_MANIFEST=true
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
            TARGET="$1"
            shift
            ;;
    esac
done

[[ -n "$TARGET" ]] || { usage; exit 1; }

ARGS=(pull "$TARGET")
[[ "$FORCE" == "true" ]] && ARGS+=(--force)
[[ "$NO_UPDATE_MANIFEST" == "true" ]] && ARGS+=(--no-update-manifest)

python3 "${SCRIPT_DIR}/remotes.py" "${ARGS[@]}"

if [[ "$NO_UPDATE_MANIFEST" != "true" ]]; then
    skill_name="${TARGET#*/}"
    "${SCRIPT_DIR}/validate-skill.sh" "$skill_name"
    "${SCRIPT_DIR}/generate-skills-md.sh"
fi

log_info "Pull completed: ${TARGET}"
