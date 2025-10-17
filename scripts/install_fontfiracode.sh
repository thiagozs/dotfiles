#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

FONT_DIR="${HOME}/.fonts"
WORK_DIR="${FONT_DIR}/FiraCode"
ARCHIVE_URL="https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
ARCHIVE_NAME="Fira_Code.zip"

ensure_command wget "instale wget (sudo apt install -y wget)"
ensure_command unzip "instale unzip (sudo apt install -y unzip)"
ensure_command fc-cache "instale fontconfig (sudo apt install -y fontconfig)"

ensure_directory "$FONT_DIR"
ensure_directory "$WORK_DIR"

log_info "Baixando Fira Code..."
wget -qO "${WORK_DIR}/${ARCHIVE_NAME}" "$ARCHIVE_URL"

log_info "Extraindo arquivos..."
unzip -oq "${WORK_DIR}/${ARCHIVE_NAME}" -d "$WORK_DIR"

if compgen -G "${WORK_DIR}"/ttf/*.ttf >/dev/null; then
    cp "${WORK_DIR}/ttf/"*.ttf "$FONT_DIR/"
    log_info "Fontes Fira Code copiadas para ${FONT_DIR}."
else
    log_warn "Não foi possível localizar arquivos TTF extraídos."
fi

rm -f "${WORK_DIR:?}/${ARCHIVE_NAME}"
fc-cache -f >/dev/null
log_info "Cache de fontes atualizado."
