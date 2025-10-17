#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

SET_DEFAULT_SHELL=false

show_help() {
    cat <<'EOF'
Uso: install_zsh.sh [opções]

Opções:
  --set-default-shell    Configura o zsh como shell padrão do usuário atual
  -h, --help             Exibe esta ajuda
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --set-default-shell)
            SET_DEFAULT_SHELL=true
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            fail "Opção desconhecida: $1"
            ;;
    esac
    shift || true
done

install_zsh_package() {
    if command_exists zsh; then
        log_info "zsh já está instalado."
        return
    fi

    if is_linux; then
        log_info "Instalando zsh via apt..."
        sudo apt-get update -y
        sudo apt-get install -y zsh
    elif is_macos; then
        log_info "Instalando zsh via Homebrew..."
        brew install zsh
    else
        fail "Instalação automática do zsh não suportada neste sistema."
    fi
}

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Oh My Zsh já instalado."
        return
    fi

    ensure_command curl "instale curl (via apt ou brew)"

    export RUNZSH=no
    export CHSH=no
    export KEEP_ZSHRC=yes

    log_info "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

ensure_default_shell() {
    if ! $SET_DEFAULT_SHELL; then
        return
    fi

    local current_shell
    current_shell="$(basename "${SHELL}")"
    if [[ "$current_shell" == "zsh" ]]; then
        log_info "zsh já é o shell padrão."
        return
    fi

    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ -z "$zsh_path" ]]; then
        fail "zsh não localizado após instalação."
    fi

    log_info "Definindo zsh como shell padrão."
    chsh -s "$zsh_path"
}

install_zsh_package
install_oh_my_zsh
ensure_default_shell

log_info "Configuração de zsh concluída."
