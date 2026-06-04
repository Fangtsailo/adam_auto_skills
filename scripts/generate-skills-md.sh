#!/usr/bin/env bash
# Generate SKILLS.md from skills/manifest.json.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

OUTPUT_FILE="${REPO_ROOT}/SKILLS.md"

usage() {
    cat <<'EOF'
Usage: generate-skills-md.sh [options]

Generate SKILLS.md from skills/manifest.json.

Options:
  -o, --output <path>   Output file (default: ./SKILLS.md)
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTPUT_FILE="${2:-}"
            [[ -n "$OUTPUT_FILE" ]] || die "--output requires a path argument"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
done

python3 - "$SKILLS_DIR/manifest.json" "$OUTPUT_FILE" <<'PY'
import json
import sys
from datetime import datetime, timezone

manifest_file, output_file = sys.argv[1:3]
with open(manifest_file, encoding="utf-8") as handle:
    data = json.load(handle)

generated_at = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
lines = [
    "# Skills Catalog",
    "",
    "Auto-generated from `skills/manifest.json`. Do not edit manually.",
    "",
    f"*Generated at: {generated_at}*",
    "",
    "| Skill | Version | Tags | Description |",
    "|-------|---------|------|-------------|",
]

for skill in data.get("skills", []):
    name = skill.get("name", "")
    version = skill.get("version", "")
    tags = ", ".join(skill.get("tags", []))
    description = skill.get("description", "").replace("|", "\\|")
    lines.append(f"| `{name}` | {version} | {tags} | {description} |")

lines.extend(["", "## Install", "", "```bash", "./bin/skill install --global <skill-name>", "```", ""])

with open(output_file, "w", encoding="utf-8") as handle:
    handle.write("\n".join(lines))
    handle.write("\n")
PY

log_info "Generated ${OUTPUT_FILE}"
