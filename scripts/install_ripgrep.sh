#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

install_ripgrep() {
    if command_exists rg; then
        log_info "ripgrep já está instalado."
        return
    fi

    if is_linux; then
        apt_install_packages ripgrep
    elif is_macos; then
        brew_install_package ripgrep
    else
        fail "Instalação do ripgrep não suportada neste sistema."
    fi

    log_info "ripgrep instalado."
}

install_ripgrep
