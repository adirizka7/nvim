vim.cmd('colorscheme spaceduck')

local function selection_highlights()
    -- Brighten the selection background without replacing syntax colors.
    vim.api.nvim_set_hl(0, 'Visual', {
        bg = '#414b65',
        ctermbg = 60,
        blend = 0,
    })
    vim.api.nvim_set_hl(0, 'VisualNOS', { link = 'Visual' })
end

vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('SpaceduckSelection', { clear = true }),
    pattern = 'spaceduck',
    callback = selection_highlights,
})
selection_highlights()

vim.api.nvim_set_hl(0, 'Comment', { fg = '#7178a0' })
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#5A6AC5' })
vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#0f111b' })
-- -- Follow terminal background color.
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#30365F", bg = "none" })
