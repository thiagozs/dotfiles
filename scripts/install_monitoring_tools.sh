#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

install_linux_pkg() {
    local pkg="$1"
    local display="$2"

    apt_update_once
    if sudo apt-get install -y "$pkg"; then
        log_info "${display} instalado."
    else
        log_warn "Não foi possível instalar ${display} via apt. Considere instalar manualmente."
    fi
}

install_brew_pkg() {
    local pkg="$1"
    local display="$2"

    if brew list --formula | grep -Fxq "$pkg"; then
        log_info "${display} já instalado via Homebrew."
        return
    fi

    if brew install "$pkg"; then
        log_info "${display} instalado."
    else
        log_warn "Não foi possível instalar ${display} via Homebrew."
    fi
}

install_suite() {
    local commands=(htop btop gotop glances)
    local packages_linux=(htop btop gotop glances)
    local packages_brew=(htop btop gotop glances)
    local descriptions=("htop" "btop" "gotop" "glances")

    for i in "${!commands[@]}"; do
        local cmd="${commands[$i]}"
        local pkg_linux="${packages_linux[$i]}"
        local pkg_brew="${packages_brew[$i]}"
        local desc="${descriptions[$i]}"

        if command_exists "$cmd"; then
            log_info "${desc} já está instalado."
            continue
        fi

        if is_linux; then
            install_linux_pkg "$pkg_linux" "$desc"
        elif is_macos; then
            install_brew_pkg "$pkg_brew" "$desc"
        else
            log_warn "Instalação de ${desc} não suportada neste sistema."
        fi
    done
}

install_suite
