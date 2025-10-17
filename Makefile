SHELL := /bin/bash
REPO_ROOT := $(shell pwd)

.PHONY: lint shellcheck bats

lint: shellcheck bats

shellcheck:
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "==> shellcheck"; \
		shellcheck $(shell find . -type f -name '*.sh' -not -path './.git/*'); \
	else \
		echo "shellcheck não encontrado. Instale com 'sudo apt install -y shellcheck'"; \
	fi

bats:
	@if command -v bats >/dev/null 2>&1; then \
		echo "==> bats tests"; \
		bats tests; \
	else \
		echo "bats não encontrado. Instale com 'brew install bats-core' ou 'sudo apt install -y bats'"; \
	fi
