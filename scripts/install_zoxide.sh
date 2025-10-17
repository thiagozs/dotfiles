#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

install_zoxide() {
    if command_exists zoxide; then
        log_info "zoxide já está instalado."
        return
    fi

    if is_linux; then
        apt_install_packages zoxide
    elif is_macos; then
        brew_install_package zoxide
    else
        fail "Instalação do zoxide não suportada neste sistema."
    fi

    log_info "zoxide instalado."
}

install_zoxide
