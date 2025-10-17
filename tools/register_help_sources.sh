#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

TOOLS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "${TOOLS_DIR}/.." && pwd)
# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/lib/common.sh"

TARGET_ROOT="${HOME}/.dotfiles"
PATHS_SOURCE="${ROOT_DIR}/paths"
ALIASES_SOURCE="${ROOT_DIR}/aliases"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"

ensure_zshrc() {
    if [[ -f "$ZSHRC" ]]; then
        return
    fi

    ensure_directory "$(dirname "$ZSHRC")"
    touch "$ZSHRC"
    log_warn "Criado arquivo vazio $ZSHRC; personalize conforme necessário."
}

resolve_path() {
    local path="$1"
    if command_exists realpath; then
        realpath "$path"
    else
        ensure_command python3 "instale python3"
        python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$path"
    fi
}

link_and_source() {
    local source_dir="$1"
    local destination_dir="$2"
    local extension="$3"

    ensure_directory "$destination_dir"

    shopt -s nullglob
    for file in "${source_dir}"/*."${extension}"; do
        local base
        base="$(basename "$file")"
        local target="${destination_dir}/${base}"

        ln -sfn "$(resolve_path "$file")" "$target"
        log_info "Registrado link para ${target}"

        upsert_config_line "source ${target}" "$ZSHRC"
    done
    shopt -u nullglob
}

ensure_directory "$TARGET_ROOT"
ensure_directory "${TARGET_ROOT}/paths"
ensure_directory "${TARGET_ROOT}/aliases"
ensure_zshrc

link_and_source "$PATHS_SOURCE" "${TARGET_ROOT}/paths" "path"
link_and_source "$ALIASES_SOURCE" "${TARGET_ROOT}/aliases" "aliases"

log_info "Fontes de ajuda registradas com sucesso."
