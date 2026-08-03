require("CopilotChat").setup {
  window = {
    layout = 'float',
    width = 0.75, 
    height = 0.75
  },
  model = 'gpt-5.4',
  auto_insert_mode = true,
}

local chat = require("CopilotChat")

vim.keymap.set({'n', 'v'}, '<leader>cco', chat.toggle, {})

vim.api.nvim_create_autocmd('BufEnter', {
    pattern = 'copilot-*',
    callback = function()
        vim.opt_local.relativenumber = true
    end
})
