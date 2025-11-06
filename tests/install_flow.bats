#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
    cd "$REPO_ROOT"
}

@test "dotfiles.sh executa dry-run padrão" {
    run ./dotfiles.sh --dry-run --username testuser
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Instalando componentes essenciais" ]]
}

@test "dotfiles.sh aceita componentes opcionais declarados" {
    run ./dotfiles.sh --dry-run --username testuser --with fonts,slack
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Executando componente opcional 'fonts'" ]]
    [[ "${output}" =~ "Executando componente opcional 'slack'" ]]
}

@test "dotfiles.sh aceita componentes docker opcionais" {
    run ./dotfiles.sh --dry-run --username testuser --with docker-cli,docker-compose
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Executando componente opcional 'docker-cli'" ]]
    [[ "${output}" =~ "Executando componente opcional 'docker-compose'" ]]
}

@test "dotfiles.sh aceita componente cli-utilities" {
    run ./dotfiles.sh --dry-run --username testuser --with cli-utilities
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Executando componente opcional 'cli-utilities'" ]]
}

@test "dotfiles.sh aceita componente ai-cli" {
    run ./dotfiles.sh --dry-run --username testuser --with ai-cli
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Executando componente opcional 'ai-cli'" ]]
}

@test "dotfiles.sh aceita atalho --with-ai-cli" {
    run ./dotfiles.sh --dry-run --username testuser --with-ai-cli
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Executando componente opcional 'ai-cli'" ]]
}

@test "dotfiles.sh --only-ai-cli executa apenas CLIs de IA" {
    run ./dotfiles.sh --dry-run --username testuser --only-ai-cli
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Pulando componentes essenciais" ]]
    [[ "${output}" =~ "Executando componente opcional 'ai-cli'" ]]
}

@test "dotfiles.sh aceita componente language-managers" {
    run ./dotfiles.sh --dry-run --username testuser --with language-managers
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Executando componente opcional 'language-managers'" ]]
}

@test "dotfiles.sh rejeita componente inválido" {
    run ./dotfiles.sh --dry-run --username testuser --with foo
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Componente opcional desconhecido 'foo' ignorado" ]]
}

@test "docker_resolve_apt_codename aplica fallback (unit)" {
    run bash -lc 'export DOTFILES_TEST_FAKE_CODENAME=no-such-codename-xyz; source ./scripts/lib/common.sh; source ./scripts/lib/docker.sh; docker_resolve_apt_codename'
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "jammy" ]]
    [[ "${output}" =~ "WARN" ]]
}
