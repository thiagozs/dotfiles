#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSH_TEMPLATE="${ROOT_DIR}/templates/zshrc"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"
THEME="spaceship"
declare -a PLUGINS=("git" "zsh-autosuggestions" "zsh-syntax-highlighting")

show_help() {
    cat <<'EOF'
Uso: install_zsh_plugins.sh [opções]

Opções:
  --theme NOME           Define o tema a ser aplicado no .zshrc (default: spaceship)
  --plugin NOME          Adiciona plugin extra (pode repetir)
  -h, --help             Exibe esta ajuda
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --theme)
            shift
            THEME="${1:-$THEME}"
            ;;
        --plugin)
            shift
            PLUGINS+=("${1:-}")
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

ensure_command git "instale git (sudo apt install -y git)"

ensure_zshrc_exists() {
    if [[ -f "$ZSHRC" ]]; then
        return
    fi

    if [[ -f "$ZSH_TEMPLATE" ]]; then
        cp "$ZSH_TEMPLATE" "$ZSHRC"
        log_info "Arquivo $ZSHRC criado a partir do template de dotfiles."
    elif [[ -f "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" ]]; then
        cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$ZSHRC"
        log_info "Arquivo $ZSHRC criado a partir do template padrão."
    else
        touch "$ZSHRC"
        log_warn "Template do Oh My Zsh não encontrado. Um .zshrc vazio foi criado."
    fi
}

ensure_plugin() {
    local name="$1"
    local repo="$2"
    local target="${ZSH_CUSTOM}/plugins/${name}"
    ensure_directory "$(dirname "$target")"

    if [[ -d "$target/.git" ]]; then
        log_info "Atualizando plugin $name..."
        git -C "$target" pull --ff-only >/dev/null
    elif [[ -d "$target" && ! -d "$target/.git" ]]; then
        log_warn "Diretório $target existe mas não é um clone git. Pulando."
    else
        log_info "Clonando plugin $name..."
        git clone --depth=1 "$repo" "$target" >/dev/null
    fi
}

ensure_theme() {
    local name="$1"
    local repo="$2"
    local themes_dir="${ZSH_CUSTOM}/themes"
    local target="${themes_dir}/${name}-prompt"
    local link="${themes_dir}/${name}.zsh-theme"

    ensure_directory "$themes_dir"

    if [[ -d "$target/.git" ]]; then
        log_info "Atualizando tema $name..."
        git -C "$target" pull --ff-only >/dev/null
    elif [[ -d "$target" && ! -d "$target/.git" ]]; then
        log_warn "Diretório $target já existe e não parece ser um clone git. Pulando."
    else
        log_info "Clonando tema $name..."
        git clone --depth=1 "$repo" "$target" >/dev/null
    fi

    if [[ ! -L "$link" ]]; then
        ln -sf "${target}/${name}.zsh-theme" "$link"
    fi
}

replace_or_append() {
    local prefix="$1"
    local newline="$2"
    local file="$3"
    local tmp
    tmp="$(mktemp)"

    awk -v pre="$prefix" -v line="$newline" '
        BEGIN { replaced = 0 }
        index($0, pre) == 1 && !replaced {
            print line
            replaced = 1
            next
        }
        { print }
        END {
            if (!replaced) {
                print line
            }
        }
    ' "$file" >"$tmp"

    mv "$tmp" "$file"
}

ensure_directory "$ZSH_CUSTOM/plugins"
ensure_directory "$ZSH_CUSTOM/themes"
ensure_zshrc_exists

ensure_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
ensure_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

if [[ "$THEME" == "spaceship" ]]; then
    ensure_theme "spaceship" "https://github.com/spaceship-prompt/spaceship-prompt.git"
fi

declare -a filtered_plugins=()
declare -A seen_plugins=()
for plugin in "${PLUGINS[@]}"; do
    [[ -n "$plugin" ]] || continue
    if [[ -z "${seen_plugins[$plugin]:-}" ]]; then
        filtered_plugins+=("$plugin")
        seen_plugins["$plugin"]=1
    fi
done

plugins_line="plugins=(${filtered_plugins[*]})"
replace_or_append "plugins=" "$plugins_line" "$ZSHRC"

theme_line="ZSH_THEME=\"${THEME}\""
replace_or_append "ZSH_THEME=" "$theme_line" "$ZSHRC"

log_info "Plugins e tema do zsh configurados."
