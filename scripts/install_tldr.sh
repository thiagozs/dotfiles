#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

install_tldr() {
    if command_exists tldr; then
        log_info "tldr já está instalado."
        return
    fi

    if is_linux; then
        apt_install_packages tldr
    elif is_macos; then
        brew_install_package tldr
    else
        fail "Instalação do tldr não suportada neste sistema."
    fi

    log_info "tldr instalado."
}

install_tldr
