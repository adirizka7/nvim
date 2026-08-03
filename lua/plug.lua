-- vim-plug
local vim = vim
-- Keep Neovim plugins stable when parent commands override XDG_DATA_HOME.
local nvim_data_path = vim.fn.expand('~/.local/share/nvim')
local plug_path = nvim_data_path .. '/site/autoload/plug.vim'

if vim.fn.filereadable(plug_path) == 0 then
    local output = vim.fn.system({
        'curl', '-fLo', plug_path, '--create-dirs',
        'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
    })

    if vim.v.shell_error ~= 0 then
        error(('Unable to install vim-plug:\n%s'):format(output))
    end
end

vim.cmd('source ' .. vim.fn.fnameescape(plug_path))

local Plug = vim.fn['plug#']

vim.call('plug#begin', nvim_data_path .. '/plugged')

-- -- Git
Plug('airblade/vim-gitgutter')
Plug('tpope/vim-fugitive')

-- -- Telescope & deps
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag'] = 'v0.2.1' })
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

-- -- Diagrams
Plug('adirizka7/vim-puml')
Plug('jbyuki/venn.nvim')

-- -- LLMs.
Plug('CopilotC-Nvim/CopilotChat.nvim', { ['branch'] = 'main' })

-- -- Pasting Image
Plug('HakonHarnes/img-clip.nvim')

-- -- CURL
Plug('oysandvik94/curl.nvim')

-- -- Svelte
Plug('evanleck/vim-svelte', { ['branch'] = 'main' })
Plug('stevearc/conform.nvim')

-- -- Latex
Plug('lervag/vimtex')

vim.call('plug#end')

-- Plugin configs under after/plugin require these modules during startup.
for _, plugin in pairs(vim.g.plugs) do
    if vim.fn.isdirectory(plugin.dir) == 0 then
        vim.cmd('PlugInstall --sync')
        break
    end
end
