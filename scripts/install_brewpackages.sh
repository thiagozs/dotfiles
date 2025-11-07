#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

MANIFEST="tools/brew_packages.txt"
SKIP_UPGRADE=false
FAILURES_LOG="${HOME}/.dotfiles/install-failures.log"

show_help() {
    cat <<'EOF'
Uso: install_brewpackages.sh [opções]

Opções:
  --file CAMINHO        Caminho para lista de fórmulas (default: tools/brew_packages.txt)
  --skip-upgrade        Não executar brew update/upgrade antes da instalação
  -h, --help            Exibe esta ajuda

A lista aceita linhas com comentários (#) e ignora entradas vazias.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --file)
            shift
            MANIFEST="${1:-}"
            ;;
        --skip-upgrade)
            SKIP_UPGRADE=true
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

ensure_command brew "siga as instruções de instalação do Homebrew"

if [[ ! -f "$MANIFEST" ]]; then
    log_warn "Manifesto de pacotes Homebrew não encontrado em $MANIFEST. Nada a fazer."
    exit 0
fi

if [[ "$SKIP_UPGRADE" == false ]]; then
    log_info "Atualizando Homebrew..."
    brew update
    log_info "Atualizando fórmulas instaladas..."
    brew upgrade
fi

log_info "Instalando pacotes listados em $MANIFEST..."
# reset failures log for this run
ensure_directory "$(dirname "$FAILURES_LOG")"
: > "$FAILURES_LOG" || true
failed_any=false
while IFS= read -r package; do
    package="${package%%\#*}"
    package="$(echo "$package" | xargs)"
    [[ -z "$package" ]] && continue

    if brew list --formula | grep -Fxq "$package"; then
        log_info "$package (formula) já instalado."
        continue
    fi

    if brew list --cask | grep -Fxq "$package"; then
        log_info "$package (cask) já instalado."
        continue
    fi

    log_info "Instalando $package..."
    # Tentar instalar, mas não falhar todo o processo se a fórmula não existir
    # ou ocorrer erro; registra aviso e continua com o próximo pacote.
    if ! brew install "$package"; then
        log_warn "Falha ao instalar '$package' via Homebrew — pulando (verifique manualmente)."
        # record failure for audit
        printf "%s\n" "$package" >>"$FAILURES_LOG" || true
        failed_any=true
        continue
    fi
done <"$MANIFEST"

if [[ "$failed_any" == true ]]; then
    log_warn "Algumas fórmulas falharam. Verifique o log: $FAILURES_LOG"
    log_info "Resumo das fórmulas que falharam:" 
    if [[ -s "$FAILURES_LOG" ]]; then
        sed -n '1,200p' "$FAILURES_LOG" | while IFS= read -r f; do log_warn " - $f"; done
    fi
else
    log_info "Processamento de pacotes Homebrew concluído."
fi
