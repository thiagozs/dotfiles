#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

NPM_PACKAGE="openai"
PYTHON_PACKAGE="openai"
WRAPPER_PATH="${HOME}/.local/bin/codex"

already_installed() {
    if command_exists openai; then
        log_info "OpenAI CLI já disponível como 'openai'."
        return 0
    fi
    return 1
}

install_via_npm() {
    if ! command_exists npm; then
        log_warn "npm não encontrado; pulando instalação do OpenAI CLI via npm."
        return 1
    fi

    if npm list -g --depth=0 2>/dev/null | grep -Fq "$NPM_PACKAGE"; then
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

create_wrapper_if_needed() {
    if command_exists codex; then
        return
    fi

    if ! command_exists openai; then
        return
    fi

    ensure_directory "$(dirname "$WRAPPER_PATH")"
    cat >"$WRAPPER_PATH" <<'EOF'
#!/usr/bin/env bash
exec openai "$@"
EOF
    chmod +x "$WRAPPER_PATH"
    log_info "Wrapper 'codex' criado em ${WRAPPER_PATH} apontando para 'openai'."
}

install_via_pipx() {
    if ! command_exists pipx; then
        log_warn "pipx não encontrado; pulando instalação do OpenAI CLI via pipx."
        return 1
    fi

    if pipx list 2>/dev/null | grep -Fqi "$PYTHON_PACKAGE"; then
        log_info "${PYTHON_PACKAGE} já instalado via pipx."
    else
        log_info "Instalando ${PYTHON_PACKAGE} via pipx."
        if ! pipx install "${PYTHON_PACKAGE}"; then
            log_warn "Falha ao instalar ${PYTHON_PACKAGE} via pipx."
            return 1
        fi
    fi

    create_wrapper_if_needed
    return 0
}

install_via_pip() {
    if ! command_exists pip3; then
        log_warn "pip3 não encontrado; pulando instalação do OpenAI CLI via pip3."
        return 1
    fi

    log_info "Instalando ${PYTHON_PACKAGE} via pip3 --user."
    if ! pip3 install --user "${PYTHON_PACKAGE}"; then
        log_warn "Falha ao instalar ${PYTHON_PACKAGE} via pip3."
        return 1
    fi

    create_wrapper_if_needed
    return 0
}

main() {
    if already_installed; then
        create_wrapper_if_needed
        return
    fi

    local installed=1

    if install_via_pipx; then
        installed=0
    elif install_via_pip; then
        installed=0
    elif install_via_npm; then
        installed=0
    fi

    if [[ $installed -ne 0 ]]; then
        fail "Não foi possível instalar automaticamente o OpenAI CLI (Codex). Consulte https://platform.openai.com/docs/api-reference/cli."
    fi

    create_wrapper_if_needed

    if already_installed; then
        log_info "OpenAI CLI instalado com sucesso."
    else
        log_warn "Instalação concluída, mas o comando 'openai' não foi localizado no PATH. Ajuste sua configuração manualmente."
    fi
}

main
