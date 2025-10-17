# Dotfiles 😝

Coleção de scripts para inicializar rapidamente um ambiente de desenvolvimento, instalando dependências, fontes e registrando aliases/paths personalizados.

## Requisitos

- Distribuição Linux baseada em Debian/Ubuntu (algumas partes funcionam no macOS, mas o suporte principal é Linux).
- `sudo` configurado para o usuário que executa o script.
- Dependências básicas: `curl`, `git`, `wget`, `unzip`, `fc-cache` (instaladas automaticamente quando possível).

## Uso rápido

```sh
./dotfiles.sh --username SEU_USUARIO
```

Por padrão o script:

1. Ajusta permissões sudo (opcional), instala Homebrew e Docker (`scripts/install_essentials.sh`).
2. Processa a lista de pacotes Homebrew descrita em `tools/brew_packages.txt`.
3. Instala e configura `zsh`, plugins e tema.
4. Cria symlinks dos arquivos em `paths/` e `aliases/` para `~/.dotfiles`, garantindo que sejam carregados no `.zshrc`.

## Componentes opcionais

Os componentes extras são descritos de forma declarativa em `config/components.sh`. Execute `./dotfiles.sh --help` para listar a descrição atualizada. Por enquanto os seguintes nomes estão disponíveis:

- `fonts` - instala Font Awesome e Fira Code.
- `slack` - instala Slack Desktop.
- `vscode` - instala Visual Studio Code a partir do repositório oficial.
- `docker-cli` - instala o Docker CLI e adiciona o usuário ao grupo `docker`.
- `docker-compose` - instala o plugin Docker Compose v2.
- `cli-utilities` - adiciona ferramentas produtivas de terminal (fzf, bat, ripgrep, exa, zoxide, monitores, tldr, Gemini CLI).
- `language-managers` - instala `nvm` (Node.js) e `gvm` (Go).

Exemplo:

```sh
./dotfiles.sh --username thiagozs --with fonts,slack,docker-cli,docker-compose
```

## Ajustes finos

- `--skip-essentials`, `--skip-brew`, `--skip-zsh`, `--skip-zsh-plugins`, `--skip-register` permitem pular etapas específicas.
- `--skip-docker`, `--skip-docker-compose`, `--skip-sudoers` controlam subtarefas de `install_essentials.sh`.
- `--dry-run` mostra os comandos sem executá-los.

Veja `./dotfiles.sh --help` para a lista completa de parâmetros.

## Manifestos e templates

- `config/components.sh` controla quais componentes opcionais estão disponíveis, quais scripts são executados e quais flags extras são repassadas aos essenciais.
- `templates/zshrc` fornece um modelo base para novos ambientes. Se ainda não existir um `.zshrc`, o template é copiado automaticamente durante a instalação dos plugins.

## Estrutura dos scripts

- `scripts/install_essentials.sh` - gerencia sudo, Homebrew e Docker (engine/compose).
- `scripts/install_brewpackages.sh` - lê `tools/brew_packages.txt` e garante a instalação via Homebrew.
- `scripts/install_zsh.sh` e `scripts/install_zsh_plugins.sh` - cuidam de zsh, Oh My Zsh, plugins e tema.
- `scripts/install_docker_cli.sh` e `scripts/install_docker_compose.sh` - instaladores dedicados para Docker CLI/Compose (reutilizados no componente `docker-cli`/`docker-compose`).
- `scripts/install_fzf.sh`, `scripts/install_bat.sh`, `scripts/install_ripgrep.sh`, `scripts/install_exa.sh`, `scripts/install_zoxide.sh`, `scripts/install_monitoring_tools.sh`, `scripts/install_tldr.sh`, `scripts/install_gemini_cli.sh` - utilitários de terminal opcionais.
- `scripts/install_nvm.sh` e `scripts/install_gvm.sh` - gerenciam as instalações do `nvm` e `gvm`.
- `tools/register_help_sources.sh` - cria symlinks e garante o `source` no `.zshrc`.

Cada script utiliza helpers compartilhados em `scripts/lib/common.sh`, garantindo logs consistentes e idempotência.

## Testes e lint

- `make shellcheck` executa o lint das shells scripts (usa `shellcheck`).
- `make bats` executa os cenários de dry-run definidos em `tests/install_flow.bats`.
- `make lint` roda ambos. O workflow do GitHub (`.github/workflows/ci.yml`) garante que essas verificações sejam executadas em cada push/PR.

## Validação manual recomendada

Além dos testes automatizados, sugere-se validar manualmente em ambientes limpos:

1. **Ubuntu Desktop/WSL** - rodar `./dotfiles.sh --username <user> --dry-run`, depois sem `--dry-run`, verificando instalação de Docker/Fontes/VS Code conforme desejado.
2. **Ubuntu Server headless** - repetir testes com `--skip-docker` e `--skip-docker-compose` para evitar pacotes extras.
3. **macOS** - executar somente etapas de Homebrew/zsh (`--skip-essentials --skip-docker --skip-docker-compose`) e confirmar se os aliases são vinculados corretamente.

Use `--dry-run` sempre que quiser inspecionar os comandos antes da execução real.

### Subindo uma VM rápida via linha de comando

Para validar em um ambiente realmente limpo, você pode usar o [Multipass](https://multipass.run/), que funciona em Linux, macOS e Windows:

1. Instale o Multipass (ex.: `sudo snap install multipass --classic` no Ubuntu).
2. Crie uma VM Ubuntu:  
   ```sh
   multipass launch --name dotfiles-test --memory 4G --disk 20G
   ```
3. Acesse a VM:  
   ```sh
   multipass shell dotfiles-test
   ```
4. Dentro da VM, baixe este repositório e execute o instalador:  
   ```sh
   git clone https://github.com/thiagozs/dotfiles.git
   cd dotfiles
   ./dotfiles.sh --username ubuntu --with fonts,vscode --dry-run
   ./dotfiles.sh --username ubuntu --with fonts,vscode
   ```
5. Quando terminar, remova a VM:  
   ```sh
   multipass delete dotfiles-test
   multipass purge
   ```

Alternativa com Vagrant (caso já utilize VirtualBox ou libvirt):

```sh
vagrant init ubuntu/jammy64
vagrant up
vagrant ssh
```

Depois da validação, use `vagrant destroy` para remover a VM.

### Usando Docker (Imagem Ubuntu)

Para uma validação rápida sem máquina virtual completa, dá para usar Docker com a imagem oficial do Ubuntu:

```sh
docker run --rm -it --name dotfiles-test \
  -v "$PWD":"$PWD" -w "$PWD" \
  ubuntu:22.04 bash
```

Dentro do container:

```sh
apt-get update && apt-get install -y git sudo curl wget unzip fontconfig shellcheck bats
useradd -m dotuser && echo 'dotuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
su - dotuser
cd "$OLDPWD"
./dotfiles.sh --username dotuser --with fonts --dry-run
./dotfiles.sh --username dotuser --with fonts
```

Ao sair do container (`exit`), tudo é descartado automaticamente graças ao `--rm`.

## Versionamento e licença

Seguimos [Semantic Versioning](https://semver.org/). Consulte as [tags do repositório](https://github.com/thiagozs/dotfiles/tags) para versões disponíveis e veja a [LICENSE](LICENSE) para detalhes legais.

**2023-2025**, thiagozs
