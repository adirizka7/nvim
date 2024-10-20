-- Create an autocommand group to avoid duplicates.
vim.api.nvim_create_augroup("PUMLFileMappings", { clear = true })

-- Set the key mapping for Go file type.
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.puml",  -- This applies to PUML files only.
    callback = function()
        -- Open alternate test file.
        vim.api.nvim_set_keymap('n', '<leader>g', ':PUMLGenerate<enter>', { silent = true, noremap = true })

        -- Open alternate test file.
        vim.api.nvim_set_keymap('n', '<leader>o', ':PUMLOpen<enter>', { silent = true, noremap = true })
    end,
    group = "PUMLFileMappings",
})
