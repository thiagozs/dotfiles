#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

install_fzf() {
    if command_exists fzf; then
        log_info "fzf já está instalado."
        return
    fi

    if is_linux; then
        apt_install_packages fzf
    elif is_macos; then
        brew_install_package fzf
    else
        fail "Instalação do fzf não suportada neste sistema."
    fi

    log_info "fzf instalado."
}

install_fzf
