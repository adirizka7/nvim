# nvim

Personal Neovim configuration.

## Prerequisites

- Neovim
- Git
- Curl
- Make
- A C compiler
- [Tree-sitter CLI](https://tree-sitter.github.io/tree-sitter/creating-parsers/1-getting-started.html#installation)

Verify the CLI is available before running setup:

```sh
tree-sitter --version
Homebrew users: install tree-sitter-cli, which provides the
tree-sitter executable required by nvim-treesitter.

brew install tree-sitter-cli

The tree-sitter Homebrew formula provides the library only; it does not
install the CLI executable.

## Setup

```sh
git clone https://github.com/adirizka7/nvim.git ~/.config/nvim
cd ~/.config/nvim
make setup
```

`make setup` installs the configured plugins, the Bash Treesitter parser required by `curl.nvim`, and the Go parser used by the Go test mapping.

Open Neovim after setup:

```sh
nvim
```

For optional plugin integrations, install the tools they use, such as `jq` for formatted Curl responses, language servers, formatters, and TeX tools for Vimtex.
