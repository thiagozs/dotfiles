#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

ATUIN_INSTALLER_URL="https://setup.atuin.sh"

install_atuin_via_official_script() {
    ensure_command curl "instale curl (sudo apt install -y curl)"

    local installer
    installer="$(mktemp)"
    # shellcheck disable=SC2064
    trap "rm -f '$installer'" RETURN

    log_info "Baixando instalador oficial do atuin."
    curl --proto '=https' --tlsv1.2 -sSf "$ATUIN_INSTALLER_URL" -o "$installer"

    chmod +x "$installer"
    if ! bash "$installer"; then
        log_warn "Instalador oficial do atuin retornou código não-zero."
        return 1
    fi

    return 0
}

install_atuin() {
    if command_exists atuin; then
        log_info "atuin já está instalado."
        return
    fi

    if is_macos; then
        brew_install_package atuin
    elif is_linux; then
        if ! install_atuin_via_official_script; then
            fail "Não foi possível instalar o atuin automaticamente. Consulte https://docs.atuin.sh/guide/installation."
        fi
    else
        fail "Instalação do atuin não suportada neste sistema."
    fi

    if command_exists atuin; then
        log_info "atuin instalado."
    else
        log_warn "Instalação finalizada, mas o binário 'atuin' não foi encontrado no PATH. Ajuste sua configuração manualmente."
    fi
}

install_atuin
