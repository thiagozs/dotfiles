# Changelog - alterações recentes

## 2025-11-06 — Melhorias no instalador

- Tornei a execução dos scripts mais tolerante a arquivos sem o bit executável: o `dotfiles.sh` agora invoca scripts com `bash` quando necessário, evitando falhas com código 126 (Permission denied).
- Adicionei fallback para codenames do Ubuntu/Distribuições no instalador do Docker (quando o codename não existir no repositório oficial do Docker, mapear para `jammy` ou outro fallback configurado). Use a variável de ambiente `DOTFILES_TEST_FAKE_CODENAME` em testes para simular codenames não suportados.
- Tornamos o instalador de pacotes Homebrew resiliente a fórmulas ausentes: entradas inválidas agora são reportadas com WARN e puladas, não abortando o fluxo completo.

## Notas técnicas e como testar

- Simular codename não suportado (ex.: `noble`) durante testes:

```sh
export DOTFILES_TEST_FAKE_CODENAME=noble
./dotfiles.sh --username ubuntu --dry-run
```

- Ver as fórmulas falhadas após execução real do instalador (ex.: `codegpt`): examine a saída do instalador ou verifique o log no terminal; as entradas comentadas em `tools/brew_packages.txt` foram mantidas para revisão manual.

- Arquivos/patches aplicados:
  - `dotfiles.sh` — execução defensiva de scripts não-executáveis
  - `scripts/lib/docker.sh` — fallback de codename (resolução remota)
  - `scripts/install_brewpackages.sh` — continua em caso de falhas individuais
  - `tools/brew_packages.txt` — remoções/comentários de fórmulas obsoletas/substituições sugeridas (ex.: `youtube-dl` → `yt-dlp`)

## Próximos passos sugeridos

1. Revisar manualmente as entradas comentadas em `tools/brew_packages.txt` e confirmar substituições (por exemplo: `codegpt` → `code2prompt`).
2. Tornar executáveis os scripts em `tools/` no repositório (feito nesta mudança).
3. Adicionar um relatório final de fórmulas falhadas ao final da execução do instalador para auditoria automática.

---

Arquivo gerado automaticamente durante a sessão de manutenção do instalador.

## 2025-11-07 — CI e validação

- Adicionado workflow de validação (em PR) para executar os testes Bats em PRs e evitar regressões no instalador.
- Adicionado um workflow (em PR) que executa o passo de instalação do Homebrew em runners Ubuntu e publica um comentário no PR com um resumo de quaisquer fórmulas que falharem — isso automatiza a mesma lógica de relatório que o instalador já escreve em `~/.dotfiles/install-failures.log`.
- Validações finais foram executadas em VM (dotfiles-test): testes Bats passaram (10/10), o instalador rodou, e nenhum erro de Homebrew foi registrado no log de falhas.
