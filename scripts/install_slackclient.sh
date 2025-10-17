#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

VERSION="4.36.140"
DEB_URL="https://downloads.slack-edge.com/releases/linux/${VERSION}/prod/x64/slack-desktop-${VERSION}-amd64.deb"
DEB_FILE="slack-desktop-${VERSION}-amd64.deb"

show_help() {
    cat <<'EOF'
Uso: install_slackclient.sh [opções]

Opções:
  --version X.Y.Z   Define a versão do Slack Desktop a instalar
  --url URL         Fornece URL customizada para o pacote .deb
  -h, --help        Exibe esta ajuda
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            shift
            VERSION="${1:-$VERSION}"
            DEB_URL="https://downloads.slack-edge.com/releases/linux/${VERSION}/prod/x64/slack-desktop-${VERSION}-amd64.deb"
            DEB_FILE="slack-desktop-${VERSION}-amd64.deb"
            ;;
        --url)
            shift
            DEB_URL="${1:-$DEB_URL}"
            DEB_FILE="$(basename "$DEB_URL")"
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

if command_exists slack; then
    log_info "Slack já está instalado."
    exit 0
fi

ensure_command wget "instale wget (sudo apt install -y wget)"

log_info "Baixando Slack Desktop ${VERSION}..."
wget -q "$DEB_URL" -O "$DEB_FILE"

log_info "Instalando pacote ${DEB_FILE}..."
sudo dpkg -i "$DEB_FILE" || sudo apt-get install -f -y

rm -f "$DEB_FILE"
log_info "Slack Desktop instalado."
