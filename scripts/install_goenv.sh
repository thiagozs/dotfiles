#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

GOENV_ROOT="${GOENV_ROOT:-$HOME/.goenv}"
GOENV_REPO="https://github.com/syndbg/goenv.git"
GO_BUILD_REPO="https://github.com/syndbg/go-build.git"
GO_BUILD_DIR="${GOENV_ROOT}/plugins/go-build"

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

install_goenv() {
    ensure_command git "instale git (sudo apt install -y git)"

    clone_or_update_repo "$GOENV_REPO" "$GOENV_ROOT"
    clone_or_update_repo "$GO_BUILD_REPO" "$GO_BUILD_DIR"

    if command_exists goenv; then
        log_info "goenv já disponível no PATH."
    else
        log_info "goenv instalado. Adicione 'export GOENV_ROOT=\"$GOENV_ROOT\"' e 'eval \"\$(goenv init -)\"' ao seu shell para começar a usar."
    fi
}

install_goenv
