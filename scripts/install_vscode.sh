#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

if command_exists code; then
    log_info "Visual Studio Code já está instalado."
    exit 0
fi

is_linux || fail "Instalação automatizada do VS Code implementada apenas para Linux."

ensure_command wget "instale wget (sudo apt install -y wget)"
ensure_command gpg "instale gnupg (sudo apt install -y gnupg)"

update_apt_cache() {
    if [[ "${APT_UPDATED:-0}" -eq 1 ]]; then
        return
    fi
    sudo apt-get update -y
    APT_UPDATED=1
}

KEYRING="/etc/apt/keyrings/packages.microsoft.gpg"
REPO_FILE="/etc/apt/sources.list.d/vscode.list"
ARCH="$(dpkg --print-architecture)"

if [[ ! -f "$KEYRING" ]]; then
    log_info "Registrando chave GPG da Microsoft..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o "$KEYRING"
    sudo chmod go+r "$KEYRING"
fi

if [[ ! -f "$REPO_FILE" ]]; then
    log_info "Configurando repositório do VS Code..."
    echo "deb [arch=${ARCH} signed-by=${KEYRING}] https://packages.microsoft.com/repos/vscode stable main" | sudo tee "$REPO_FILE" >/dev/null
fi

update_apt_cache
log_info "Instalando Visual Studio Code..."
sudo apt-get install -y code

log_info "Visual Studio Code instalado com sucesso."
