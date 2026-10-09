# nvim

Personal Neovim configuration.

## Setup

Requirements: Neovim, Git, curl, make, and a C compiler. Network access is required to download plugins and Treesitter parsers.

```sh
git clone https://github.com/adirizka7/nvim.git ~/.config/nvim
cd ~/.config/nvim
make setup
```

`make setup` installs the configured plugins and the Bash Treesitter parser required by `curl.nvim`.

Open Neovim after setup:

```sh
nvim
```

For optional plugin integrations, install the tools they use, such as `jq` for formatted Curl responses, language servers, formatters, and TeX tools for Vimtex.
