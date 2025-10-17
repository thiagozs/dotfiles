#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/lib/common.sh"

COMPONENT_MANIFEST="${ROOT_DIR}/config/components.sh"
declare -A COMPONENT_DESCRIPTIONS=()
declare -A COMPONENT_SCRIPTS=()
declare -A COMPONENT_FLAGS=()
declare -a COMPONENT_ORDER=()

USERNAME="${USER}"
DRY_RUN=false
declare -a OPTIONALS=()
declare -a EXTRA_ESSENTIAL_ARGS=()

SKIP_ESSENTIALS=false
SKIP_BREW=false
SKIP_ZSH=false
SKIP_ZSH_PLUGINS=false
SKIP_REGISTER=false
INCLUDE_AI_CLI=false
ONLY_AI_CLI=false

show_help() {
    cat <<'EOF'
Uso: ./dotfiles.sh [opções]

Opções principais:
  --username NOME           Usuário alvo para permissões sudo e ajustes (default: usuário atual)
  --with lista              Componentes opcionais separados por vírgula (ex.: fonts,slack,vscode,docker-cli)
  --skip-essentials         Não executa scripts/install_essentials.sh
  --skip-brew               Não executa scripts/install_brewpackages.sh
  --skip-zsh                Não executa scripts/install_zsh.sh
  --skip-zsh-plugins        Não executa scripts/install_zsh_plugins.sh
  --skip-register           Não executa tools/register_help_sources.sh
  --with-ai-cli             Atalho para instalar o componente opcional de CLIs de IA
  --only-ai-cli             Apenas instala os CLIs de IA (ignora demais componentes)
  --skip-docker             Repassa --skip-docker para install_essentials.sh
  --skip-docker-compose     Repassa --skip-docker-compose para install_essentials.sh
  --skip-sudoers            Repassa --skip-sudoers para install_essentials.sh
  --dry-run                 Apenas exibe os comandos que seriam executados
  -h, --help                Mostra esta ajuda

Exemplo:
  ./dotfiles.sh --username thiagozs --with fonts,slack,docker-cli
EOF

    if ((${#COMPONENT_ORDER[@]} > 0)); then
        echo
        echo "Componentes opcionais disponíveis:"
        local desc
        for component in "${COMPONENT_ORDER[@]}"; do
            desc="${COMPONENT_DESCRIPTIONS[$component]}"
            printf "  %-16s %s\n" "$component" "$desc"
        done
    fi
}

add_optional() {
    local input="$1"
    IFS=',' read -r -a items <<<"$input"
    for item in "${items[@]}"; do
        [[ -n "$item" ]] || continue
        OPTIONALS+=("$item")
    done
}

load_component_manifest() {
    if [[ ! -f "$COMPONENT_MANIFEST" ]]; then
        log_warn "Manifesto de componentes opcionais não encontrado em $COMPONENT_MANIFEST."
        return
    fi

    # shellcheck disable=SC1090
    source "$COMPONENT_MANIFEST"

    if declare -p DOTFILES_COMPONENT_DESCRIPTIONS >/dev/null 2>&1; then
        COMPONENT_DESCRIPTIONS=()
        for name in "${!DOTFILES_COMPONENT_DESCRIPTIONS[@]}"; do
            COMPONENT_DESCRIPTIONS["$name"]="${DOTFILES_COMPONENT_DESCRIPTIONS[$name]}"
        done
    fi

    if declare -p DOTFILES_COMPONENT_SCRIPTS >/dev/null 2>&1; then
        COMPONENT_SCRIPTS=()
        for name in "${!DOTFILES_COMPONENT_SCRIPTS[@]}"; do
            COMPONENT_SCRIPTS["$name"]="${DOTFILES_COMPONENT_SCRIPTS[$name]}"
        done
    fi

    if declare -p DOTFILES_COMPONENT_FLAGS >/dev/null 2>&1; then
        COMPONENT_FLAGS=()
        for name in "${!DOTFILES_COMPONENT_FLAGS[@]}"; do
            COMPONENT_FLAGS["$name"]="${DOTFILES_COMPONENT_FLAGS[$name]}"
        done
    fi

    if declare -p DOTFILES_COMPONENT_ORDER >/dev/null 2>&1; then
        COMPONENT_ORDER=("${DOTFILES_COMPONENT_ORDER[@]}")
    fi
}

load_component_manifest

while [[ $# -gt 0 ]]; do
    case "$1" in
        --username)
            shift
            USERNAME="${1:-}"
            ;;
        --with)
            shift
            add_optional "${1:-}"
            ;;
        --skip-essentials)
            SKIP_ESSENTIALS=true
            ;;
        --skip-brew)
            SKIP_BREW=true
            ;;
        --skip-zsh)
            SKIP_ZSH=true
            ;;
        --skip-zsh-plugins)
            SKIP_ZSH_PLUGINS=true
            ;;
        --skip-register)
            SKIP_REGISTER=true
            ;;
        --with-ai-cli)
            INCLUDE_AI_CLI=true
            ;;
        --only-ai-cli)
            INCLUDE_AI_CLI=true
            ONLY_AI_CLI=true
            ;;
        --skip-docker|--skip-docker-compose|--skip-sudoers)
            EXTRA_ESSENTIAL_ARGS+=("$1")
            ;;
        --dry-run)
            DRY_RUN=true
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

if [[ "$ONLY_AI_CLI" == true ]]; then
    if ((${#OPTIONALS[@]} > 0)); then
        log_warn "--only-ai-cli ignora componentes adicionais informados via --with."
    fi
    SKIP_ESSENTIALS=true
    SKIP_BREW=true
    SKIP_ZSH=true
    SKIP_ZSH_PLUGINS=true
    SKIP_REGISTER=true
    OPTIONALS=("ai-cli")
elif [[ "$INCLUDE_AI_CLI" == true ]]; then
    OPTIONALS+=("ai-cli")
fi

[[ -n "$USERNAME" ]] || fail "Informe um usuário via --username."

if ((${#OPTIONALS[@]} > 0)); then
    declare -A uniq_optionals=()
    declare -a filtered_optionals=()
    for item in "${OPTIONALS[@]}"; do
        [[ -n "$item" ]] || continue
        if [[ -z "${COMPONENT_DESCRIPTIONS[$item]+x}" ]]; then
            log_warn "Componente opcional desconhecido '${item}' ignorado."
            continue
        fi
        if [[ -z "${uniq_optionals[$item]+x}" ]]; then
            uniq_optionals["$item"]=1
            filtered_optionals+=("$item")
        fi
    done
    OPTIONALS=("${filtered_optionals[@]}")
fi

run_step_command() {
    local description="$1"
    shift
    local cmd=("$@")

    log_info "$description"
    log_info "Comando: ${cmd[*]}"

    if $DRY_RUN; then
        log_info "[dry-run] passo ignorado."
        return 0
    fi

    "${cmd[@]}"
}

if ((${#OPTIONALS[@]} > 0)); then
    for component in "${OPTIONALS[@]}"; do
        if [[ -n "${COMPONENT_FLAGS[$component]:-}" ]]; then
            while IFS= read -r flag; do
                [[ -n "$flag" ]] || continue
                EXTRA_ESSENTIAL_ARGS+=("$flag")
            done <<<"$(printf '%s\n' "${COMPONENT_FLAGS[$component]}")"
        fi
    done
fi

if ! $SKIP_ESSENTIALS; then
    cmd_args=(
        "${ROOT_DIR}/scripts/install_essentials.sh"
        --username "$USERNAME"
    )
    if ((${#EXTRA_ESSENTIAL_ARGS[@]} > 0)); then
        cmd_args+=("${EXTRA_ESSENTIAL_ARGS[@]}")
    fi

    run_step_command \
        "Instalando componentes essenciais" \
        "${cmd_args[@]}"
else
    log_info "Pulando componentes essenciais (--skip-essentials)."
fi

if ! $SKIP_BREW; then
    run_step_command \
        "Instalando fórmulas Homebrew" \
        "${ROOT_DIR}/scripts/install_brewpackages.sh"
else
    log_info "Pulando Homebrew (--skip-brew)."
fi

if ! $SKIP_ZSH; then
    run_step_command \
        "Configurando zsh" \
        "${ROOT_DIR}/scripts/install_zsh.sh"
else
    log_info "Pulando instalação/configuração do zsh (--skip-zsh)."
fi

if ! $SKIP_ZSH_PLUGINS; then
    run_step_command \
        "Instalando plugins e tema do zsh" \
        "${ROOT_DIR}/scripts/install_zsh_plugins.sh"
else
    log_info "Pulando plugins de zsh (--skip-zsh-plugins)."
fi

if ! $SKIP_REGISTER; then
    run_step_command \
        "Registrando aliases e paths personalizados" \
        "${ROOT_DIR}/tools/register_help_sources.sh"
else
    log_info "Pulando registro de aliases/paths (--skip-register)."
fi

for component in "${OPTIONALS[@]}"; do
    if [[ -z "${COMPONENT_SCRIPTS[$component]:-}" ]]; then
        continue
    fi

    while IFS= read -r script_path; do
        [[ -n "$script_path" ]] || continue
        run_step_command \
            "Executando componente opcional '${component}' (${COMPONENT_DESCRIPTIONS[$component]})" \
            "${ROOT_DIR}/${script_path}"
    done <<<"$(printf '%s\n' "${COMPONENT_SCRIPTS[$component]}")"
done

log_info "Fluxo de configuração finalizado."
