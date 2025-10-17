#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/lib/common.sh"

COMPONENT_MANIFEST="${ROOT_DIR}/config/components.json"
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

show_help() {
    cat <<'EOF'
Uso: ./dotfiles.sh [opções]

Opções principais:
  --username NOME           Usuário alvo para permissões sudo e ajustes (default: usuário atual)
  --with lista              Componentes opcionais separados por vírgula (ex.: fonts,slack,vscode,docker-desktop)
  --skip-essentials         Não executa scripts/install_essentials.sh
  --skip-brew               Não executa scripts/install_brewpackages.sh
  --skip-zsh                Não executa scripts/install_zsh.sh
  --skip-zsh-plugins        Não executa scripts/install_zsh_plugins.sh
  --skip-register           Não executa tools/register_help_sources.sh
  --skip-docker             Repassa --skip-docker para install_essentials.sh
  --skip-docker-compose     Repassa --skip-docker-compose para install_essentials.sh
  --skip-sudoers            Repassa --skip-sudoers para install_essentials.sh
  --with-docker-desktop     Repassa --with-docker-desktop para install_essentials.sh
  --dry-run                 Apenas exibe os comandos que seriam executados
  -h, --help                Mostra esta ajuda

Exemplo:
  ./dotfiles.sh --username thiagozs --with fonts,slack --with-docker-desktop
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

    ensure_command python3 "instale python3 (sudo apt install -y python3)"

    local kind name value
    while IFS=$'\t' read -r kind name value; do
        case "$kind" in
            ENTRY)
                COMPONENT_DESCRIPTIONS["$name"]="$value"
                COMPONENT_ORDER+=("$name")
                ;;
            SCRIPT)
                if [[ -n "${COMPONENT_SCRIPTS[$name]+x}" ]]; then
                    COMPONENT_SCRIPTS["$name"]+=$'\n'"$value"
                else
                    COMPONENT_SCRIPTS["$name"]="$value"
                fi
                ;;
            FLAG)
                if [[ -n "${COMPONENT_FLAGS[$name]+x}" ]]; then
                    COMPONENT_FLAGS["$name"]+=$'\n'"$value"
                else
                    COMPONENT_FLAGS["$name"]="$value"
                fi
                ;;
        esac
    done < <(python3 - "$COMPONENT_MANIFEST" <<'PY'
import json, sys, pathlib
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
for name, attrs in data.items():
    desc = attrs.get("description", "")
    print("ENTRY", name, desc, sep="\t")
    for script in attrs.get("scripts") or []:
        print("SCRIPT", name, script, sep="\t")
    for flag in attrs.get("forward_flags") or []:
        print("FLAG", name, flag, sep="\t")
PY
    )
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
        --skip-docker|--skip-docker-compose|--skip-sudoers|--with-docker-desktop)
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
            done <<<"${COMPONENT_FLAGS[$component]}"
        fi
    done
fi

if ! $SKIP_ESSENTIALS; then
    run_step_command \
        "Instalando componentes essenciais" \
        "${ROOT_DIR}/scripts/install_essentials.sh" \
        --username "$USERNAME" \
        "${EXTRA_ESSENTIAL_ARGS[@]}"
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
    done <<<"${COMPONENT_SCRIPTS[$component]}"
done

log_info "Fluxo de configuração finalizado."
