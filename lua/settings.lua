-- show relative number
vim.wo.number = true
vim.wo.relativenumber = true

-- tab & indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- open split on the right side
vim.opt.splitright = true

-- map jk to escape key
vim.keymap.set('i', 'jk', '<Esc>', options)
vim.keymap.set('i', 'JK', '<Esc>', options)

-- Quickfix mapping.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.keymap.set('n', 'J', '<cmd>cnext<CR>\'"<C-w>w', { noremap = true, silent = true, buffer = true })
        vim.keymap.set('n', 'K', '<cmd>cprev<CR>\'"<C-w>w', { noremap = true, silent = true, buffer = true })
    end
})

-- share with system clipboard
vim.opt.clipboard = 'unnamed,unnamedplus'

-- search cases
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Persistent Undo
vim.opt.undofile = true  -- Maintain undo history between sessions
vim.opt.undodir = vim.fn.expand("~/.config/nvim/undodir")  -- Set undo directory

-- -- Get the undo directory.
local undodir = vim.opt.undodir:get()[1]

-- -- Create undo directory if it doesn't exist
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end

-- Reload NVIM Config from anywhere
vim.api.nvim_create_user_command('ReloadConfig', function()
    vim.cmd("source " .. vim.env.MYVIMRC)
    vim.notify("Neovim config reloaded!", vim.log.levels.INFO)
end, {})

-- Open link under the cursor
vim.keymap.set("n", "gl", ":silent !open <cfile><CR>", { noremap = true, silent = true })
