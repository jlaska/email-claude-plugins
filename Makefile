.PHONY: lint lint-fix setup install-hooks clean update help

help:
	@echo "Available targets:"
	@echo "  make lint          - Run all linters (claudelint, markdownlint, gitleaks)"
	@echo "  make lint-fix      - Run linters with auto-fix where possible"
	@echo "  make setup         - Install pre-commit hooks"
	@echo "  make install-hooks - Install pre-commit git hooks"
	@echo "  make clean         - Remove generated files"
	@echo "  make update        - Update the email-triage Claude plugin to latest version"

lint:
	uvx pre-commit run --all-files

lint-fix:
	npx claude-code-lint check-all --fix || true
	uvx pre-commit run markdownlint --all-files -- --fix || true
	uvx pre-commit run --all-files

setup: install-hooks

install-hooks:
	uvx pre-commit install

update:
	claude plugins update email-triage@email-claude-plugins

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
