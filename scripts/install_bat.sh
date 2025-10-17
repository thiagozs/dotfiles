#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

ensure_bat_symlink() {
    if command_exists bat || ! command_exists batcat; then
        return
    fi

    local target="/usr/local/bin/bat"
    if [[ ! -e "$target" ]]; then
        log_info "Criando alias bat -> batcat em ${target}."
        echo '#!/usr/bin/env bash' | sudo tee "$target" >/dev/null
        echo 'exec batcat "$@"' | sudo tee -a "$target" >/dev/null
        sudo chmod +x "$target"
    fi
}

install_bat() {
    if command_exists bat || command_exists batcat; then
        log_info "bat já está instalado."
        ensure_bat_symlink
        return
    fi

    if is_linux; then
        apt_install_packages bat
        ensure_bat_symlink
    elif is_macos; then
        brew_install_package bat
    else
        fail "Instalação do bat não suportada neste sistema."
    fi

    log_info "bat instalado."
}

install_bat
