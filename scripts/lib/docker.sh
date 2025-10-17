#!/usr/bin/env bash

if [[ "${DOTFILES_DOCKER_LIB_SOURCED:-0}" -eq 1 ]]; then
    return
fi

DOTFILES_DOCKER_LIB_SOURCED=1

docker_require_linux() {
    if ! is_linux; then
        fail "As rotinas de Docker estão implementadas apenas para Linux."
    fi
}

docker_update_apt_cache() {
    local -n cache_flag="$1"

    if [[ "${cache_flag:-0}" -eq 1 ]]; then
        log_info "Cache do apt já atualizado nesta execução."
        return
    fi

    log_info "Atualizando cache do apt..."
    sudo apt-get update -y
    cache_flag=1
}

docker_install_prereqs() {
    local -n cache_flag="$1"
    docker_update_apt_cache cache_flag
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
}

docker_setup_repository() {
    local -n cache_flag="$1"

    local keyring="/etc/apt/keyrings/docker.gpg"
    if [[ ! -f "$keyring" ]]; then
        log_info "Registrando chave GPG do Docker."
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o "$keyring"
        sudo chmod a+r "$keyring"
    fi

    local repo
    repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    if ! grep -Rqs "download.docker.com/linux/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
        log_info "Adicionando repositório do Docker."
        echo "$repo" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    fi

    docker_update_apt_cache cache_flag
}

docker_add_user_to_group() {
    local user="$1"

    if ! id "$user" &>/dev/null; then
        log_warn "Usuário $user não encontrado; não foi possível adicioná-lo ao grupo docker."
        return
    fi

    log_info "Adicionando $user ao grupo docker."
    sudo usermod -aG docker "$user"
}

docker_cli_installed() {
    command_exists docker
}

docker_compose_plugin_installed() {
    if command_exists docker-compose; then
        return 0
    fi

    docker compose version >/dev/null 2>&1
}

docker_ensure_legacy_symlink() {
    if command_exists docker-compose || ! command_exists docker; then
        return
    fi

    local target="/usr/local/bin/docker-compose"
    local target_dir="/usr/local/bin"

    if docker compose version >/dev/null 2>&1 && [[ ! -e "$target" ]]; then
        log_info "Criando alias docker-compose -> docker compose."

        sudo install -d -m 0755 "$target_dir"

        local tmp
        tmp="$(mktemp)"
        {
            echo '#!/usr/bin/env bash'
            echo 'exec docker compose "$@"'
        } >"$tmp"

        sudo install -m 0755 "$tmp" "$target"
        rm -f "$tmp"
    fi
}
