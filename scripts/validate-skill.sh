#!/usr/bin/env bash
# Validate one or all skills in the repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

VERBOSE=false
ERRORS=0

usage() {
    cat <<'EOF'
Usage: validate-skill.sh [options] [skill-name...]

Validate skill structure and SKILL.md frontmatter.

Options:
  -a, --all       Validate all skills in skills/
  -v, --verbose   Show detailed output
  -h, --help      Show this help

Examples:
  ./scripts/validate-skill.sh --all
  ./scripts/validate-skill.sh angular-code-review
EOF
}

log_pass() {
    echo "[PASS] $*"
}

log_fail() {
    echo "[FAIL] $*" >&2
    ERRORS=$((ERRORS + 1))
}

check_sensitive_patterns() {
    local file="$1"
    local patterns=(
        'AKIA[0-9A-Z]{16}'
        'sk-[a-zA-Z0-9]{20,}'
        'ghp_[a-zA-Z0-9]{20,}'
        'password[[:space:]]*=[[:space:]]*["'\''][^"'\'']+["'\'']'
        'api[_-]?key[[:space:]]*=[[:space:]]*["'\''][^"'\'']+["'\'']'
    )
    local pattern
    for pattern in "${patterns[@]}"; do
        if grep -qE "$pattern" "$file" 2>/dev/null; then
            log_fail "${file}: possible sensitive credential detected"
            return 1
        fi
    done
    return 0
}

validate_skill() {
    local skill_name="$1"
    local skill_dir="${SKILLS_DIR}/${skill_name}"
    local skill_md="${skill_dir}/SKILL.md"

    [[ "$VERBOSE" == "true" ]] && log_info "Validating skill: ${skill_name}"

    if ! is_valid_skill_name "$skill_name"; then
        log_fail "${skill_name}: invalid directory name (use lowercase, numbers, hyphens)"
        return
    fi

    if [[ ! -d "$skill_dir" ]]; then
        log_fail "${skill_name}: directory not found at ${skill_dir}"
        return
    fi

    if [[ ! -f "$skill_md" ]]; then
        log_fail "${skill_name}: missing SKILL.md"
        return
    fi

    if ! head -n 1 "$skill_md" | grep -q '^---$'; then
        log_fail "${skill_name}: SKILL.md must start with YAML frontmatter (---)"
        return
    fi

    local fm_name fm_desc
    fm_name="$(extract_frontmatter_name "$skill_md")"
    fm_desc="$(extract_frontmatter_description "$skill_md")"

    if [[ -z "$fm_name" ]]; then
        log_fail "${skill_name}: frontmatter 'name' is missing or empty"
        return
    fi

    if [[ -z "$fm_desc" ]]; then
        log_fail "${skill_name}: frontmatter 'description' is missing or empty"
        return
    fi

    if [[ "$fm_name" != "$skill_name" ]]; then
        log_fail "${skill_name}: directory name '${skill_name}' does not match frontmatter name '${fm_name}'"
        return
    fi

    if [[ ${#fm_name} -gt 64 ]]; then
        log_fail "${skill_name}: frontmatter 'name' exceeds 64 characters"
        return
    fi

    if [[ ${#fm_desc} -gt 1024 ]]; then
        log_fail "${skill_name}: frontmatter 'description' exceeds 1024 characters"
        return
    fi

    if ! is_valid_skill_name "$fm_name"; then
        log_fail "${skill_name}: frontmatter 'name' has invalid format"
        return
    fi

    if grep -qE '\]\((\./)?CONTEXT\.md\)' "$skill_md"; then
        if [[ ! -e "${skill_dir}/CONTEXT.md" ]]; then
            log_fail "${skill_name}: SKILL.md points at CONTEXT.md but ${skill_dir}/CONTEXT.md is missing"
            return
        fi
    fi

    if grep -q 'skills-cursor' "$skill_md" 2>/dev/null; then
        if grep -qE '(write|install|create|copy).*(skills-cursor)|(skills-cursor).*(write|install|create|copy)' "$skill_md" 2>/dev/null; then
            log_fail "${skill_name}: SKILL.md must not instruct writing to skills-cursor"
            return
        fi
    fi

    check_sensitive_patterns "$skill_md" || true

    log_pass "${skill_name}"
}

validate_manifest() {
    local manifest="${SKILLS_DIR}/manifest.json"
    if [[ ! -f "$manifest" ]]; then
        log_fail "manifest.json not found at ${manifest}"
        return
    fi

    if ! python3 -m json.tool "$manifest" >/dev/null 2>&1; then
        log_fail "manifest.json is not valid JSON"
        return
    fi

    log_pass "manifest.json"
}

validate_manifest_consistency() {
    local manifest="${SKILLS_DIR}/manifest.json"
    local result
    result="$(python3 - "$manifest" "$SKILLS_DIR" <<'PY'
import json
import sys
from pathlib import Path

manifest_file, skills_dir = sys.argv[1:3]
with open(manifest_file, encoding="utf-8") as handle:
    data = json.load(handle)

manifest_names = {skill.get("name") for skill in data.get("skills", []) if skill.get("name")}
repo_names = set()
for path in Path(skills_dir).iterdir():
    if path.is_dir() and (path / "SKILL.md").exists():
        repo_names.add(path.name)

missing_in_manifest = sorted(repo_names - manifest_names)
missing_in_repo = sorted(manifest_names - repo_names)
errors = []
if missing_in_manifest:
    errors.append(f"skills missing from manifest.json: {', '.join(missing_in_manifest)}")
if missing_in_repo:
    errors.append(f"manifest entries missing skill directory: {', '.join(missing_in_repo)}")
print("\n".join(errors))
PY
)"

    if [[ -n "$result" ]]; then
        while IFS= read -r line; do
            [[ -n "$line" ]] || continue
            log_fail "$line"
        done <<< "$result"
        return
    fi

    log_pass "manifest consistency"
}

SKILL_NAMES=()
VALIDATE_ALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--all)
            VALIDATE_ALL=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
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

if [[ "$VALIDATE_ALL" == "true" ]]; then
    mapfile -t SKILL_NAMES < <(list_repo_skills)
elif [[ ${#SKILL_NAMES[@]} -eq 0 ]]; then
    usage
    exit 1
fi

validate_manifest

if [[ "$VALIDATE_ALL" == "true" ]]; then
    validate_manifest_consistency
fi

for skill in "${SKILL_NAMES[@]}"; do
    validate_skill "$skill"
done

if [[ "$ERRORS" -gt 0 ]]; then
    log_error "${ERRORS} validation error(s) found"
    exit 1
fi

log_info "All validations passed (${#SKILL_NAMES[@]} skill(s))"
