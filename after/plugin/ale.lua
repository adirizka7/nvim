-- LSP handles these languages, so disable duplicate diagnostics from ALE.
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'go', 'python' },
    callback = function()
        vim.b.ale_enabled = 0
    end,
})
