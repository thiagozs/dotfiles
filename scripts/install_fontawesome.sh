#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

FONT_DIR="${HOME}/.fonts"
REPO_DIR="${FONT_DIR}/FontAwesome"
FONTS_SUBPATH="otfs"
REPO_URL="https://github.com/FortAwesome/Font-Awesome.git"

ensure_command git "instale git (sudo apt install -y git)"
ensure_command fc-cache "instale fontconfig (sudo apt install -y fontconfig)"

ensure_directory "$FONT_DIR"

if [[ -d "${REPO_DIR}/.git" ]]; then
    log_info "Atualizando Font Awesome..."
    git -C "$REPO_DIR" pull --ff-only >/dev/null
elif [[ -d "$REPO_DIR" ]]; then
    log_warn "Diretório $REPO_DIR já existe e não parece ser um repositório git. Pulando atualização."
else
    log_info "Clonando Font Awesome..."
    git clone --depth=1 "$REPO_URL" "$REPO_DIR" >/dev/null
fi

if compgen -G "${REPO_DIR}/${FONTS_SUBPATH}/*.otf" >/dev/null; then
    log_info "Copiando fontes OTF..."
    cp "${REPO_DIR}/${FONTS_SUBPATH}/"*.otf "$FONT_DIR/"
    fc-cache -f >/dev/null
    log_info "Fontes Font Awesome instaladas em ${FONT_DIR}."
else
    log_warn "Nenhum arquivo OTF encontrado em ${REPO_DIR}/${FONTS_SUBPATH}."
fi
