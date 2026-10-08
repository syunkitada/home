#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: agents/setup.sh [all|codex|skills|--help]

Create symlinks for Codex settings and shared agent skills.
No argument defaults to all. Existing conflicting paths are never overwritten.

Environment variables:
  CODEX_SOURCE_DIR         Source directory (default: agents/codex)
  CODEX_HOME               Destination directory (default: $HOME/.codex)
  AGENT_SKILLS_SOURCE_DIR  Source directory (default: agents/_skills)
  AGENT_SKILLS_HOME        Destination directory (default: $HOME/.agents/skills)
EOF
}

if [[ $# -gt 1 ]]; then
    usage >&2
    exit 1
fi
mode=${1:-all}
case "$mode" in
    all|codex|skills) ;;
    --help) usage; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$mode" >&2; usage >&2; exit 1 ;;
esac

agents_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
sources=()
targets=()
errors=0
shopt -s nullglob dotglob

error() {
    printf '%s\n' "$*" >&2
    errors=1
}

absolute_path() {
    case "$1" in
        /*) printf '%s\n' "$1" ;;
        *) printf '%s/%s\n' "$PWD" "$1" ;;
    esac
}

add_link() {
    sources+=("$1")
    targets+=("$2")
}

if [[ "$mode" == all || "$mode" == codex ]]; then
    codex_source=${CODEX_SOURCE_DIR:-$agents_dir/codex}
    codex_home=$(absolute_path "${CODEX_HOME:-$HOME/.codex}")
    if [[ ! -d "$codex_source" ]]; then
        error "Missing Codex source directory: $codex_source"
    else
        codex_source=$(cd -- "$codex_source" && pwd -P)
        if [[ ! -f "$codex_source/config.toml" ]]; then
            error "Missing Codex config: $codex_source/config.toml"
        else
            add_link "$codex_source/config.toml" "$codex_home/config.toml"
        fi
        for source in "$codex_source"/rules/*.rules "$codex_source"/hooks/*.sh; do
            [[ "$source" == "$codex_source/rules/default.rules" ]] && continue
            if [[ ! -f "$source" ]]; then
                error "Expected a source file: $source"
                continue
            fi
            relative=${source#"$codex_source/"}
            add_link "$source" "$codex_home/$relative"
        done
    fi
fi

if [[ "$mode" == all || "$mode" == skills ]]; then
    skills_source=${AGENT_SKILLS_SOURCE_DIR:-$agents_dir/_skills}
    skills_home=$(absolute_path "${AGENT_SKILLS_HOME:-$HOME/.agents/skills}")
    if [[ ! -d "$skills_source" ]]; then
        error "Missing skills source directory: $skills_source"
    else
        skills_source=$(cd -- "$skills_source" && pwd -P)
        for source in "$skills_source"/*; do
            [[ -d "$source" ]] || continue
            if [[ ! -f "$source/SKILL.md" ]]; then
                error "Missing skill manifest: $source/SKILL.md"
                continue
            fi
            add_link "$source" "$skills_home/${source##*/}"
        done
    fi
fi

# Validate every selected link and its parents before making any changes.
for ((i = 0; i < ${#sources[@]}; i++)); do
    source=${sources[i]}
    target=${targets[i]}
    if [[ -L "$target" && -e "$target" && "$target" -ef "$source" ]]; then
        continue
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        error "Conflicting destination: $target (expected link to $source)"
    fi
    parent=$(dirname -- "$target")
    while [[ "$parent" != / ]]; do
        if [[ ( -e "$parent" || -L "$parent" ) && ! -d "$parent" ]]; then
            error "Destination parent is not a directory: $parent"
            break
        fi
        parent=$(dirname -- "$parent")
    done
done

if [[ "$errors" -ne 0 ]]; then
    printf 'Setup stopped; no links were created. Resolve the reported conflicts and retry.\n' >&2
    exit 1
fi

for ((i = 0; i < ${#sources[@]}; i++)); do
    source=${sources[i]}
    target=${targets[i]}
    if [[ -L "$target" && -e "$target" && "$target" -ef "$source" ]]; then
        printf 'Unchanged: %s\n' "$target"
        continue
    fi
    mkdir -p -- "$(dirname -- "$target")"
    ln -s -- "$source" "$target"
    printf 'Linked: %s -> %s\n' "$target" "$source"
done
