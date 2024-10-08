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
