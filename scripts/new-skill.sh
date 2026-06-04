#!/usr/bin/env bash
# Scaffold a new skill in the repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

SKILL_NAME=""
DESCRIPTION=""
TAGS=""
FORCE=false

usage() {
    cat <<'EOF'
Usage: new-skill.sh [options] <skill-name>

Create a new skill directory with SKILL.md template and update manifest.json.

Options:
  -d, --description <text>   Skill description (required unless --force)
  -t, --tags <tag,...>       Comma-separated tags (default: general)
  -f, --force                Overwrite existing skill directory
  -h, --help                 Show this help

Examples:
  ./scripts/new-skill.sh my-skill -d "Does something useful. Use when..." -t workflow,tools
  ./bin/skill new my-skill --description "..." --tags angular,review
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--description)
            DESCRIPTION="${2:-}"
            [[ -n "$DESCRIPTION" ]] || die "--description requires a value"
            shift 2
            ;;
        -t|--tags)
            TAGS="${2:-}"
            [[ -n "$TAGS" ]] || die "--tags requires a value"
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
        -*)
            die "Unknown option: $1"
            ;;
        *)
            [[ -z "$SKILL_NAME" ]] || die "Unexpected argument: $1"
            SKILL_NAME="$1"
            shift
            ;;
    esac
done

[[ -n "$SKILL_NAME" ]] || { usage; exit 1; }
is_valid_skill_name "$SKILL_NAME" || die "Invalid skill name: ${SKILL_NAME}"

SKILL_DIR="${SKILLS_DIR}/${SKILL_NAME}"
SKILL_MD="${SKILL_DIR}/SKILL.md"

if [[ -e "$SKILL_DIR" ]]; then
    [[ "$FORCE" == "true" ]] || die "Skill already exists: ${SKILL_NAME}. Use --force to overwrite."
    rm -rf "$SKILL_DIR"
fi

if [[ -z "$DESCRIPTION" ]]; then
    DESCRIPTION="Describe what this skill does and when the agent should use it. Use when the user mentions ${SKILL_NAME}."
fi

if [[ -z "$TAGS" ]]; then
    TAGS="general"
fi

mkdir -p "$SKILL_DIR"

TITLE="$(echo "$SKILL_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}')"

cat > "$SKILL_MD" <<EOF
---
name: ${SKILL_NAME}
description: >-
  ${DESCRIPTION}
---

# ${TITLE}

## Instructions

1. Replace this section with step-by-step guidance for the agent.
2. Keep SKILL.md concise; move detailed docs to reference.md if needed.

## Examples

- Example scenario and expected behavior

## Additional Resources

- Optional: add [reference.md](reference.md) for detailed documentation
EOF

python3 - "$SKILLS_DIR/manifest.json" "$SKILL_NAME" "$DESCRIPTION" "$TAGS" <<'PY'
import json
import sys
from pathlib import Path

manifest_file, skill_name, description, tags_raw = sys.argv[1:5]
tags = [tag.strip() for tag in tags_raw.split(",") if tag.strip()]
path = Path(manifest_file)

with path.open(encoding="utf-8") as handle:
    data = json.load(handle)

skills = data.setdefault("skills", [])
skills = [skill for skill in skills if skill.get("name") != skill_name]
skills.append(
    {
        "name": skill_name,
        "description": description,
        "tags": tags,
        "version": "1.0.0",
    }
)
skills.sort(key=lambda item: item.get("name", ""))
data["skills"] = skills

with path.open("w", encoding="utf-8") as handle:
    json.dump(data, handle, indent=4)
    handle.write("\n")
PY

"${SCRIPT_DIR}/validate-skill.sh" "$SKILL_NAME"
"${SCRIPT_DIR}/generate-skills-md.sh"

log_info "Created skill: ${SKILL_NAME}"
log_info "  Directory: ${SKILL_DIR}"
log_info "  Next steps: edit SKILL.md, then commit with: skill(${SKILL_NAME}): <description>"
