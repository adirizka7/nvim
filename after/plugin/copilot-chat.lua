require("CopilotChat").setup {
  window = {
    layout = 'float',
    width = 0.75, 
    height = 0.75
  },
  auto_insert_mode = true
}

local chat = require("CopilotChat")

vim.keymap.set({'n', 'v'}, '<leader>cc', chat.toggle, {})
vim.keymap.set('n', '<leader>ccd', ':CopilotChatDocs<enter>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader>cct', ':CopilotChatTests<enter>', { silent = true, noremap = true })
