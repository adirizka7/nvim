.PHONY: setup check-prerequisites test

NVIM ?= nvim
REQUIRED_COMMANDS := $(NVIM) git curl make cc

test:
	$(NVIM) --headless -u NONE -l tests/diagnostics.lua

setup: check-prerequisites
	$(NVIM) --headless '+PlugInstall --sync' '+lua require("nvim-treesitter").install({ "bash", "go" }):wait(300000)' +qa

check-prerequisites:
	@for command in $(REQUIRED_COMMANDS); do \
		command -v "$$command" >/dev/null || { echo "Missing required command: $$command"; exit 1; }; \
	done
