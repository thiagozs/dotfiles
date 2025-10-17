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

@test "dotfiles.sh rejeita componente inválido" {
    run ./dotfiles.sh --dry-run --username testuser --with foo
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Componente opcional desconhecido 'foo' ignorado" ]]
}
