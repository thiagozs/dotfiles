#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/docker.sh"

USERNAME="${USER}"
ADD_TO_SUDOERS=true
INSTALL_DOCKER=true
INSTALL_DOCKER_COMPOSE=true

APT_UPDATED=0

show_help() {
    cat <<'EOF'
Uso: install_essentials.sh [opções]

Opções:
  --username NOME           Usuário que deverá ter sudo sem senha (default: usuário atual)
  --skip-sudoers            Não alterar a configuração de sudo
  --skip-docker             Não instalar Docker Engine
  --skip-docker-compose     Não instalar Docker Compose (plugin)
  -h, --help                Exibe esta ajuda
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --username)
            shift
            USERNAME="${1:-}"
            ;;
        --skip-sudoers)
            ADD_TO_SUDOERS=false
            ;;
        --skip-docker)
            INSTALL_DOCKER=false
            ;;
        --skip-docker-compose)
            INSTALL_DOCKER_COMPOSE=false
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

[[ -n "$USERNAME" ]] || fail "Informe um usuário via --username"

ensure_command sudo "instale o pacote sudo"

update_apt_cache() {
    if [[ $APT_UPDATED -eq 1 ]]; then
        log_info "Cache do apt já atualizado nesta execução."
        return
    fi

    log_info "Atualizando cache do apt..."
    sudo apt-get update -y
    APT_UPDATED=1
}

ensure_user_exists() {
    if id "$USERNAME" &>/dev/null; then
        log_info "Usuário $USERNAME encontrado."
    else
        fail "Usuário $USERNAME não existe."
    fi
}

configure_sudoers() {
    if ! $ADD_TO_SUDOERS; then
        log_info "Alteração de sudoers desabilitada (--skip-sudoers)."
        return
    fi

    if sudo -l -U "$USERNAME" | grep -q "(ALL : ALL) NOPASSWD: ALL"; then
        log_info "Usuário $USERNAME já possui sudo sem senha."
        return
    fi

    log_info "Adicionando $USERNAME ao sudoers sem senha."
    local entry="$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL"
    printf "%s\n" "$entry" | sudo EDITOR='tee -a' visudo >/dev/null
}

install_homebrew() {
    if command_exists brew; then
        log_info "Homebrew já instalado."
        return
    fi

    ensure_command curl "instale curl (sudo apt install -y curl)"

    if is_linux; then
        update_apt_cache
        sudo apt-get install -y build-essential procps curl file git
    fi

    log_info "Instalando Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if is_linux; then
        local brew_profile="/home/linuxbrew/.linuxbrew/bin/brew"
        if [[ -x "$brew_profile" ]]; then
            eval "$("$brew_profile" shellenv)"
            # shellcheck disable=SC2016 # queremos persistir o comando literal com $(...)
            upsert_config_line 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' "$HOME/.profile"
        fi
    fi
}

install_docker_engine() {
    if ! $INSTALL_DOCKER; then
        log_info "Instalação do Docker Engine desabilitada (--skip-docker)."
        return
    fi

    if docker_cli_installed; then
        log_info "Docker CLI já instalado."
        return
    fi

    docker_require_linux
    docker_install_prereqs APT_UPDATED
    docker_setup_repository APT_UPDATED

    log_info "Instalando Docker CLI e componentes básicos."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
    docker_add_user_to_group "$USERNAME"
}

install_docker_compose() {
    if ! $INSTALL_DOCKER_COMPOSE; then
        log_info "Instalação do Docker Compose desabilitada (--skip-docker-compose)."
        return
    fi

    if docker_compose_plugin_installed; then
        log_info "Docker Compose já está disponível."
        return
    fi

    docker_require_linux
    docker_install_prereqs APT_UPDATED
    docker_setup_repository APT_UPDATED

    log_info "Instalando plugin Docker Compose."
    sudo apt-get install -y docker-compose-plugin
}

install_docker_compose_legacy_symlink() {
    docker_ensure_legacy_symlink
}

ensure_user_exists
configure_sudoers
install_homebrew
install_docker_engine
install_docker_compose
install_docker_compose_legacy_symlink

log_info "Configuração essencial concluída."
