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
ADD_TO_GROUP=true
# shellcheck disable=SC2034 # usado por referência em funções docker_* via nome de variável
APT_UPDATED=0

show_help() {
    cat <<'EOF'
Uso: install_docker_cli.sh [opções]

Opções:
  --username NOME        Usuário que deve ser adicionado ao grupo docker (default: usuário atual)
  --skip-group           Não adiciona o usuário ao grupo docker
  -h, --help             Exibe esta ajuda
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --username)
            shift
            USERNAME="${1:-}"
            ;;
        --skip-group)
            ADD_TO_GROUP=false
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

[[ -n "$USERNAME" ]] || fail "Informe um usuário via --username."

if docker_cli_installed; then
    log_info "Docker CLI já está instalado."
    exit 0
fi

docker_require_linux
docker_install_prereqs APT_UPDATED
docker_setup_repository APT_UPDATED

log_info "Instalando Docker CLI (docker-ce, docker-ce-cli, containerd, buildx)."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

if $ADD_TO_GROUP; then
    docker_add_user_to_group "$USERNAME"
fi

log_info "Docker CLI instalado com sucesso."
