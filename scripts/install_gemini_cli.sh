#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

CLI_CANDIDATES=(gemini gemini-cli)
NPM_PACKAGE="@google/generative-ai-cli"

already_installed() {
    for cmd in "${CLI_CANDIDATES[@]}"; do
        if command_exists "$cmd"; then
            log_info "Gemini CLI já disponível como '${cmd}'."
            return 0
        fi
    done
    return 1
}

install_via_npm() {
    if ! command_exists npm; then
        log_warn "npm não encontrado; pulando instalação do Gemini CLI via npm."
        return 1
    fi

    if npm list -g --depth=0 2>/dev/null | grep -q "$NPM_PACKAGE"; then
        log_info "${NPM_PACKAGE} já instalado globalmente via npm."
        return 0
    fi

    log_info "Instalando ${NPM_PACKAGE} globalmente via npm."
    if npm install -g "$NPM_PACKAGE"; then
        return 0
    fi

    log_warn "Falha ao instalar ${NPM_PACKAGE} via npm."
    return 1
}

install_via_pip() {
    if command_exists pipx; then
        if pipx list 2>/dev/null | grep -qi "gemini"; then
            log_info "Gemini CLI já instalado via pipx."
            return 0
        fi

        log_info "Instalando Gemini CLI via pipx (google-generativeai-cli)."
        if pipx install google-generativeai-cli; then
            return 0
        fi
        log_warn "Falha ao instalar Gemini CLI via pipx."
        return 1
    fi

    if command_exists pip3; then
        log_info "Instalando Gemini CLI via pip3 (google-generativeai-cli)."
        if pip3 install --user google-generativeai-cli; then
            return 0
        fi
        log_warn "Falha ao instalar Gemini CLI via pip3."
        return 1
    fi

    log_warn "pipx/pip3 não encontrados; não foi possível instalar Gemini CLI via Python."
    return 1
}

main() {
    if already_installed; then
        return
    fi

    local installed=1

    if install_via_npm; then
        installed=0
    elif install_via_pip; then
        installed=0
    fi

    if [[ $installed -ne 0 ]]; then
        fail "Não foi possível instalar automaticamente o Gemini CLI. Consulte a documentação oficial do Google Gemini."
    fi

    if already_installed; then
        log_info "Gemini CLI instalado com sucesso."
    else
        log_warn "Instalação concluída mas o binário não foi localizado no PATH. Ajuste sua configuração manualmente."
    fi
}

main
