.PHONY: help lint lint-yaml lint-markdown lint-all clean init check

# Default target
help:
	@echo "Available targets:"
	@echo "  help           - Show this help message"
	@echo "  install-tools  - Install development dependencies"
	@echo "  lint           - Run all linters"
	@echo "  lint-yaml      - Lint YAML files"
	@echo "  lint-markdown  - Lint Markdown files"
	@echo "  check          - Run all checks (same as lint)"
	@echo "  clean          - Clean temporary files"

# Install development tools
init:
	@echo "Installing development tools..."
	@command -v yamllint >/dev/null 2>&1 || pip install yamllint
	@command -v markdownlint >/dev/null 2>&1 || npm install -g markdownlint-cli
	@echo "Done."

# Lint YAML files
lint-yaml:
	@echo "Linting YAML files..."
	yamllint action.yml .github/

# Lint Markdown files
lint-markdown:
	@echo "Linting Markdown files..."
	markdownlint '**/*.md' --ignore node_modules || true

# Run all linters
lint: lint-yaml lint-markdown

# Alias for lint
check: lint

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	rm -rf node_modules/
	rm -rf __pycache__/
	rm -rf .pytest_cache/
	rm -rf target/
	rm -f *.out
	rm -f *.test
	@echo "Done."
