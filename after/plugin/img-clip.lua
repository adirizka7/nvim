require('img-clip').setup{
  default = {
    dir_path = function()
      return vim.fn.expand("%:p:h") .. "/assets"
    end
  }
}

vim.api.nvim_set_keymap('n', '<leader>pi', ':PasteImage<enter>', { noremap = true, silent = true })
