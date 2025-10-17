#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

GVM_ROOT_DIR="${GVM_ROOT:-$HOME/.gvm}"
GVM_INSTALLER="https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer"

install_gvm() {
    if [[ -d "$GVM_ROOT_DIR" ]]; then
        log_info "gvm já está instalado em ${GVM_ROOT_DIR}."
        return
    fi

    ensure_command curl "instale curl (sudo apt install -y curl)"
    ensure_command bash "instale bash"

    log_info "Instalando gvm a partir do repositório oficial."
    local tmp
    tmp=$(mktemp)
    curl -sSL "$GVM_INSTALLER" -o "$tmp"
    bash "$tmp"
    rm -f "$tmp"

    log_info "gvm instalado. Adicione 'source \"$GVM_ROOT_DIR/scripts/gvm\"' ao seu shell para começar a usar."
}

install_gvm
