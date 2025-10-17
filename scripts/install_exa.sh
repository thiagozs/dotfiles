#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

install_exa() {
    if command_exists exa; then
        log_info "exa já está instalado."
        return
    fi

    if is_linux; then
        apt_install_packages exa
    elif is_macos; then
        brew_install_package exa
    else
        fail "Instalação do exa não suportada neste sistema."
    fi

    log_info "exa instalado."
}

install_exa
