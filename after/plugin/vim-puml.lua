-- Create an autocommand group to avoid duplicates.
vim.api.nvim_create_augroup("PUMLFileMappings", { clear = true })

-- Set the key mapping for .puml file.
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.puml",  -- This applies to PUML files only.
    callback = function()
        -- Generate the PlantUML diagram.
        vim.api.nvim_set_keymap('n', '<leader>g', ':PUMLGenerate<enter>', { silent = true, noremap = true })

        -- Open the generated PlantUML diagram.
        vim.api.nvim_set_keymap('n', '<leader>o', ':PUMLOpen<enter>', { silent = true, noremap = true })

        -- Share PlantUML server url for the current buffer.
        vim.api.nvim_set_keymap('n', '<leader>s', ':PUMLShare<enter>', { silent = true, noremap = true })
    end,
    group = "PUMLFileMappings",
})
