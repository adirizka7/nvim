-- vim-plug
local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- -- Git
Plug('airblade/vim-gitgutter')
Plug('tpope/vim-fugitive')

-- -- Telescope & deps
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.8' })
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })

-- -- Install the default 'sensible' config plugin for Nvim LSP Client.
Plug('neovim/nvim-lspconfig')

-- -- Install the default 'sensible' config plugin for Nvim Treesitter.
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate'})

-- -- Linter(s)
Plug('dense-analysis/ale')

-- -- Theme(s)
Plug('pineapplegiant/spaceduck')
Plug('nvim-lualine/lualine.nvim')
-- -- Icons
Plug('nvim-tree/nvim-web-devicons')

-- -- Language packs
Plug('sheerun/vim-polyglot')

-- -- PlantUML
Plug('adirizka7/vim-puml')

-- -- Copilot
Plug('zbirenbaum/copilot.lua')
Plug('CopilotC-Nvim/CopilotChat.nvim', { ['branch'] = 'main' })

-- -- Pasting Image
Plug('HakonHarnes/img-clip.nvim')

vim.call('plug#end')
