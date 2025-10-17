#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
NVM_VERSION="v0.39.7"

install_nvm() {
    if [[ -d "$NVM_DIR" ]]; then
        log_info "nvm já está instalado em ${NVM_DIR}."
        return
    fi

    ensure_command curl "instale curl (sudo apt install -y curl)"

    log_info "Instalando nvm ${NVM_VERSION}..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

    log_info "nvm instalado. Adicione 'source \"$NVM_DIR/nvm.sh\"' ao seu shell se ainda não estiver configurado."
}

install_nvm
