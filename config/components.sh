# shellcheck shell=bash
# Manifesto de componentes opcionais do dotfiles.
# Cada componente possui uma descrição, lista de scripts e flags encaminhadas.

# shellcheck disable=SC2034
declare -A DOTFILES_COMPONENT_DESCRIPTIONS=(
  [fonts]="Instala as fontes Font Awesome e Fira Code"
  [slack]="Instala o cliente Slack Desktop"
  [vscode]="Instala o Visual Studio Code a partir do repositório oficial"
  [docker-cli]="Instala o Docker CLI e adiciona o usuário ao grupo docker"
  [docker-compose]="Instala o plugin Docker Compose v2"
  [cli-utilities]="Instala utilitários avançados de terminal (fzf, bat, ripgrep, exa, zoxide, atuin, monitores, tldr)"
  [ai-cli]="Instala CLIs de IA (Claude, OpenAI, Gemini)"
  [language-managers]="Instala gerenciadores de versões para Node.js e Go (nvm, nodenv, gvm, goenv)"
)

# shellcheck disable=SC2034
declare -A DOTFILES_COMPONENT_SCRIPTS=(
  [fonts]=$'scripts/install_fontawesome.sh\nscripts/install_fontfiracode.sh'
  [slack]="scripts/install_slackclient.sh"
  [vscode]="scripts/install_vscode.sh"
  [docker-cli]="scripts/install_docker_cli.sh"
  [docker-compose]="scripts/install_docker_compose.sh"
  [cli-utilities]=$'scripts/install_fzf.sh\nscripts/install_bat.sh\nscripts/install_ripgrep.sh\nscripts/install_exa.sh\nscripts/install_zoxide.sh\nscripts/install_atuin.sh\nscripts/install_monitoring_tools.sh\nscripts/install_tldr.sh'
  [ai-cli]=$'scripts/install_claude_cli.sh\nscripts/install_codex_cli.sh\nscripts/install_gemini_cli.sh'
  [language-managers]=$'scripts/install_nvm.sh\nscripts/install_nodenv.sh\nscripts/install_gvm.sh\nscripts/install_goenv.sh'
)

# shellcheck disable=SC2034
declare -A DOTFILES_COMPONENT_FLAGS=()

# shellcheck disable=SC2034
DOTFILES_COMPONENT_ORDER=(
  fonts
  slack
  vscode
  docker-cli
  docker-compose
  cli-utilities
  ai-cli
  language-managers
)
