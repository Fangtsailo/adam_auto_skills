#!/usr/bin/env bash
# List skills in the repository or installed targets.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

SHOW_INSTALLED=false
TAG_FILTER=""

usage() {
    cat <<'EOF'
Usage: list.sh [options]

List skills in the repository or installed at a target location.

Options:
  -g, --global, --personal   Target personal install location (~/.cursor/skills/)
  -p, --project <path>       Target project install location
  --installed                List installed skills (default target: personal)
  --tags <tag>               Filter repository skills by tag
  -h, --help                 Show this help

Examples:
  ./scripts/list.sh
  ./scripts/list.sh --tags angular
  ./scripts/list.sh --installed --global
  ./scripts/list.sh --installed --project ~/projects/my-app
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --installed)
            SHOW_INSTALLED=true
            shift
            ;;
        --tags)
            TAG_FILTER="${2:-}"
            [[ -n "$TAG_FILTER" ]] || die "--tags requires a tag argument"
            shift 2
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
            die "Unexpected argument: $1"
            ;;
    esac
done

parse_common_target_options "$@"

if [[ "$SHOW_INSTALLED" == "true" ]]; then
    TARGET_DIR="$(resolve_target_dir "$TARGET_TYPE" "$PROJECT_PATH")"
    echo "Installed skills in: ${TARGET_DIR}"
    echo ""

    if [[ ! -f "$(manifest_file_for_dir "$TARGET_DIR")" ]]; then
        log_warn "No install manifest found. Skills may have been installed before Phase 2."
        for skill_name in $(list_repo_skills); do
            if [[ -e "${TARGET_DIR}/${skill_name}" || -L "${TARGET_DIR}/${skill_name}" ]]; then
                mode="$(detect_install_mode "${TARGET_DIR}/${skill_name}")"
                printf "  %-24s %s\n" "$skill_name" "$mode"
            fi
        done
        exit 0
    fi

    while IFS= read -r skill_name; do
        [[ -n "$skill_name" ]] || continue
        entry="$(manifest_py get-entry \
            --manifest "$(manifest_file_for_dir "$TARGET_DIR")" \
            --skill-name "$skill_name")"
        mode="${entry%%$'\t'*}"
        installed_at="${entry#*$'\t'}"
        printf "  %-24s %-8s %s\n" "$skill_name" "$mode" "$installed_at"
    done < <(manifest_list_skill_names "$TARGET_DIR")
    exit 0
fi

echo "Repository skills:"
echo ""
printf "  %-24s %-8s %-20s %s\n" "NAME" "VERSION" "TAGS" "DESCRIPTION"
while IFS=$'\t' read -r name version tags description; do
    printf "  %-24s %-8s %-20s %s\n" "$name" "$version" "$tags" "$description"
done < <(list_catalog_skills "$TAG_FILTER")
