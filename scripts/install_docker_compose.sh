#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/docker.sh"

# shellcheck disable=SC2034 # usado por referência nas funções docker_*
APT_UPDATED=0
CREATE_LEGACY_SYMLINK=true

show_help() {
    cat <<'EOF'
Uso: install_docker_compose.sh [opções]

Opções:
  --skip-legacy-symlink   Não cria o auxiliar /usr/local/bin/docker-compose
  -h, --help              Exibe esta ajuda
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-legacy-symlink)
            CREATE_LEGACY_SYMLINK=false
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

if docker_compose_plugin_installed; then
    log_info "Docker Compose já está disponível."
    exit 0
fi

docker_require_linux
docker_install_prereqs APT_UPDATED
docker_setup_repository APT_UPDATED

log_info "Instalando plugin Docker Compose (v2)."
sudo apt-get install -y docker-compose-plugin

if ! docker_cli_installed; then
    log_warn "Docker CLI não foi detectado. Considere executar scripts/install_docker_cli.sh."
fi

if $CREATE_LEGACY_SYMLINK; then
    docker_ensure_legacy_symlink
fi

log_info "Docker Compose instalado com sucesso."
