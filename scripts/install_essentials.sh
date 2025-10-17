#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

USERNAME="${USER}"
ADD_TO_SUDOERS=true
INSTALL_DOCKER=true
INSTALL_DOCKER_DESKTOP=false
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
  --with-docker-desktop     Instala Docker Desktop (somente Linux)
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
        --with-docker-desktop)
            INSTALL_DOCKER_DESKTOP=true
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
            upsert_config_line 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' "$HOME/.profile"
        fi
    fi
}

install_docker_engine() {
    if ! $INSTALL_DOCKER; then
        log_info "Instalação do Docker Engine desabilitada (--skip-docker)."
        return
    fi

    if command_exists docker; then
        log_info "Docker já instalado."
        return
    fi

    is_linux || fail "Instalação do Docker Engine automatizada suportada apenas em Linux."

    update_apt_cache
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    local keyring="/etc/apt/keyrings/docker.gpg"
    if [[ ! -f "$keyring" ]]; then
        log_info "Registrando chave GPG do Docker."
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o "$keyring"
        sudo chmod a+r "$keyring"
    fi

    local repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    if ! grep -Rqs "download.docker.com/linux/ubuntu" /etc/apt/sources.list.d /etc/apt/sources.list; then
        echo "$repo" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    fi

    update_apt_cache
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

    if id "$USERNAME" &>/dev/null; then
        sudo usermod -aG docker "$USERNAME"
    fi
}

install_docker_compose() {
    if ! $INSTALL_DOCKER_COMPOSE; then
        log_info "Instalação do Docker Compose desabilitada (--skip-docker-compose)."
        return
    fi

    if command_exists docker-compose || docker compose version >/dev/null 2>&1; then
        log_info "Docker Compose já instalado."
        return
    fi

    update_apt_cache
    sudo apt-get install -y docker-compose-plugin
}

install_docker_desktop() {
    if ! $INSTALL_DOCKER_DESKTOP; then
        log_info "Docker Desktop não solicitado."
        return
    fi

    is_linux || fail "Docker Desktop para Linux somente."

    if dpkg -l | grep -q docker-desktop; then
        log_info "Docker Desktop já instalado."
        return
    fi

    update_apt_cache
    sudo apt-get install -y gnome-terminal wget

    local package="docker-desktop-latest.deb"
    log_info "Baixando Docker Desktop..."
    wget -q https://desktop.docker.com/linux/main/amd64/docker-desktop-4.27.2-amd64.deb -O "$package"

    log_info "Instalando Docker Desktop..."
    sudo apt-get install -y "./$package"

    rm -f "$package"
}

install_docker_compose_legacy_symlink() {
    if command_exists docker-compose || ! command_exists docker; then
        return
    fi

    if docker compose version >/dev/null 2>&1 && [[ ! -e /usr/local/bin/docker-compose ]]; then
        log_info "Criando alias docker-compose -> docker compose."
        echo '#!/usr/bin/env bash' | sudo tee /usr/local/bin/docker-compose >/dev/null
        echo 'exec docker compose "$@"' | sudo tee -a /usr/local/bin/docker-compose >/dev/null
        sudo chmod +x /usr/local/bin/docker-compose
    fi
}

ensure_user_exists
configure_sudoers
install_homebrew
install_docker_engine
install_docker_compose
install_docker_desktop
install_docker_compose_legacy_symlink

log_info "Configuração essencial concluída."
