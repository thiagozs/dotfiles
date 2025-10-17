#!/usr/bin/env bash

# Funções utilitárias compartilhadas entre os scripts de instalação.
# Mantemos o estado mínimo aqui para evitar efeitos colaterais ao fazer source.

if [[ "${COMMON_DOTFILES_SOURCED:-0}" -eq 1 ]]; then
    return
fi

COMMON_DOTFILES_SOURCED=1

_log_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

log_info() {
    printf "[%s] [INFO] %s\n" "$(_log_timestamp)" "$*" >&1
}

log_warn() {
    printf "[%s] [WARN] %s\n" "$(_log_timestamp)" "$*" >&2
}

log_error() {
    printf "[%s] [ERRO] %s\n" "$(_log_timestamp)" "$*" >&2
}

fail() {
    log_error "$*"
    exit 1
}

ensure_command() {
    local cmd="$1"
    local hint="${2:-instale o pacote correspondente}"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        fail "Comando obrigatório '$cmd' não encontrado. Sugestão: ${hint}"
    fi
}

run_step() {
    local description="$1"
    shift

    log_info "${description}"
    if "$@"; then
        log_info "✔ ${description}"
    else
        fail "✖ Falha ao executar: ${description}"
    fi
}

ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

upsert_config_line() {
    # Garante que uma linha exista em um arquivo. Se não existir, adiciona ao final.
    local line="$1"
    local target="$2"

    if [[ ! -f "$target" ]]; then
        touch "$target"
    fi

    if ! grep -Fxq "$line" "$target"; then
        printf "%s\n" "$line" >>"$target"
    fi
}

is_linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}
