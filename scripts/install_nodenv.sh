#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

NODENV_ROOT="${NODENV_ROOT:-$HOME/.nodenv}"
NODENV_REPO="https://github.com/nodenv/nodenv.git"
NODE_BUILD_REPO="https://github.com/nodenv/node-build.git"
NODE_BUILD_DIR="${NODENV_ROOT}/plugins/node-build"

clone_or_update_repo() {
    local repo="$1"
    local target="$2"

    if [[ -d "$target/.git" ]]; then
        log_info "Atualizando $(basename "$target")..."
        git -C "$target" pull --ff-only >/dev/null
        return
    fi

    if [[ -d "$target" ]]; then
        log_warn "Diretório $target existe mas não é um repositório git. Pulando."
        return
    fi

    ensure_directory "$(dirname "$target")"
    log_info "Clonando $(basename "$target")..."
    git clone "$repo" "$target" >/dev/null
}

install_nodenv() {
    ensure_command git "instale git (sudo apt install -y git)"

    clone_or_update_repo "$NODENV_REPO" "$NODENV_ROOT"
    clone_or_update_repo "$NODE_BUILD_REPO" "$NODE_BUILD_DIR"

    if command_exists nodenv; then
        log_info "nodenv já disponível no PATH."
    else
        log_info "nodenv instalado. Adicione 'export NODENV_ROOT=\"$NODENV_ROOT\"' e 'eval \"\$(nodenv init -)\"' ao seu shell para começar a usar."
    fi
}

install_nodenv
