-- show relative number
vim.wo.number = true
vim.wo.relativenumber = true

-- map jk to escape key
vim.keymap.set('i', 'jk', '<Esc>', options)
vim.keymap.set('i', 'JK', '<Esc>', options)

-- tab & indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- share with system clipboard
vim.opt.clipboard = 'unnamed,unnamedplus'

-- search cases
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- vim-plug
local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- -- Git
Plug('airblade/vim-gitgutter')

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

-- -- Prettier file formatting.
Plug('prettier/vim-prettier', { ['do'] = 'yarn install --frozen-lockfile --production' })

-- -- Language packs
Plug('sheerun/vim-polyglot')

vim.call('plug#end')

-- Plugin Configs

-- -- Telescope
local actions = require('telescope.actions')

require('telescope').setup{
  defaults = {
    mappings = {
      n = {
        ['qq'] = actions.close
      }
    },
  },
}
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<C-k>', builtin.lsp_implementations, {})
vim.keymap.set('n', '<C-j>', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- -- LSP
require'lspconfig'.phpactor.setup{}
require'lspconfig'.gopls.setup{}

-- -- -- Format on save.
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({async = false})
  end
})

-- -- -- LSP Rename
vim.api.nvim_set_keymap('n', '<leader>rename', ':lua vim.lsp.buf.rename()<enter>', {})

-- -- Treesitter
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or 'all' (the listed parsers MUST always be installed)
  ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline' },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    enable = true,
  },
}

-- Themes
vim.cmd('colorscheme spaceduck')
vim.api.nvim_set_hl(0, 'Visual', { bg = '#2b2c46' })
vim.api.nvim_set_hl(0, 'Comment', { fg = '#7178a0' })
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#5A6AC5' })
vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#0f111b' })
-- -- Follow terminal background color.
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })

-- Status Line
require('lualine').setup{
  options = {
    icons_enabled = true,
    theme = 'spaceduck',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  },
}

-- Go
local ts_utils = require('nvim-treesitter.ts_utils')

function alternate_test_file()
  -- get the current buffer's file path
  local filepath = vim.fn.expand('%:.')

  if string.match(filepath, "%_test.go$") then
    filepath = string.gsub(filepath, "%_test.go$", ".go")

    vim.cmd('edit ' .. filepath)
    return
  end

  -- TODO: Prevent opening a file if it doesn't exist.

  filepath = string.gsub(filepath, "%.go$", "_test.go")
  vim.cmd('edit ' .. filepath)
end

vim.api.nvim_set_keymap('n', '<leader>alt', ':lua alternate_test_file()<enter>', { silent = true })

local function get_current_function_name()
    local node = ts_utils.get_node_at_cursor()
    while node do
        if node:type() == 'function_declaration' then
            local func_name_node = node:child(1)
            if func_name_node then
                return vim.treesitter.get_node_text(func_name_node, 0)
            end
        end
        node = node:parent()
    end
    return nil
end

function run_go_test_from_cursor()
  -- get the current buffer's file path
  local filepath = vim.fn.expand('%:.')
  
  -- Extract the directory path (up to the current file's directory)
  local subdir = vim.fn.fnamemodify(filepath, ":h")

  -- Get the function name under the cursor
  local cursor_line = vim.fn.getline('.')
  local test_function = get_current_function_name()

  -- If we couldn't find a test function, alert the user
  if not test_function then
    print("Not inside a test function.")
    return
  end

  -- Build the Go test command
  local cmd = "go test ./" .. subdir .. " -run " .. test_function .. " -coverprofile /tmp/cover.out"

  print(cmd)
  -- Run the command and capture its output
  -- TODO: Make it asynchronous
  local output = vim.fn.systemlist(cmd)

  -- If the command fails, alert the user
  if vim.v.shell_error ~= 0 then
    -- Populate the quickfix list with the output
    vim.fn.setqflist({}, 'r', { title = 'Go Test Output', lines = output })

    -- Open the quickfix list
    vim.cmd("copen")
    return
  end

  vim.cmd('redraw!')
  print("Looks good man!")

  -- TODO: Make it asynchronous
  cmd = "go tool cover -html /tmp/cover.out -o /tmp/cover.html"
  vim.fn.systemlist(cmd)
end

vim.api.nvim_set_keymap('n', '<leader>gt', ':lua run_go_test_from_cursor()<enter>', { noremap = true, silent = true })

function open_coverage_in_browser()
  -- Build the Go test command
  local cmd = "open /tmp/cover.html"

  print(cmd)
  -- Run the command and capture its output
  -- TODO: Make it asynchronous
  local output = vim.fn.systemlist(cmd)

  -- If the command fails, alert the user
  if vim.v.shell_error ~= 0 then
    -- Populate the quickfix list with the output
    vim.fn.setqflist({}, 'r', { title = 'Coverage error', lines = output })

    -- Open the quickfix list
    vim.cmd("copen")
    return
  end

  vim.cmd('redraw!')
  print("Coverage opened in browser!")
end

vim.api.nvim_set_keymap('n', '<leader>cov', ':lua open_coverage_in_browser()<enter>', { noremap = true, silent = true })

-- Miscs

-- -- Show file name with line number and copy to clipboard.
vim.api.nvim_set_keymap('n', '<C-g>', ':lua get_file_name_with_line_number()<enter>', { noremap = true, silent = true })

function get_file_name_with_line_number()
    local filename = vim.fn.expand('%:.')
    local linenumber = vim.fn.line('.')
    local result = filename .. ':' .. linenumber
    vim.fn.setreg('*', result)
    vim.api.nvim_out_write(result .. "\n")
end

-- -- Open the current file name and line number in Github UI.
vim.api.nvim_set_keymap('n', '<leader>ogh', ':lua open_current_line_in_github_ui()<enter>', { noremap = true, silent = true })

function open_current_line_in_github_ui()
    -- Get the current file name and line number
    local filename = vim.fn.expand('%:.')
    local linenumber = vim.fn.line('.')
    
    -- Use vim.loop.spawn for asynchronous execution
    vim.loop.spawn("gh", {
        args = {"browse", filename .. ":" .. linenumber}
    }, function(code, signal)
        -- Notify the user after the command is completed
        if code == 0 then
            vim.schedule(function()
                vim.api.nvim_out_write("Opened in browser: " .. filename .. " at line " .. linenumber .. "\n")
            end)
            return
        end

        vim.schedule(function()
            vim.api.nvim_err_writeln("Error opening GitHub link")
        end)
    end)

    vim.api.nvim_out_write("Opening in browser: " .. filename .. " at line " .. linenumber .. "\n")
end

-- Persistent Undo
vim.opt.undofile = true  -- Maintain undo history between sessions
vim.opt.undodir = vim.fn.expand("~/.config/nvim/undodir")  -- Set undo directory

-- -- Get the undo directory.
local undodir = vim.opt.undodir:get()[1]

-- -- Create undo directory if it doesn't exist
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
