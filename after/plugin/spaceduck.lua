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

-- GitGutter signs reveal Spaceduck's otherwise hidden dark sign background.
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })

local git_gutter_highlights = {
    GitGutterAdd = '#5ccc96',
    GitGutterChange = '#e39400',
    GitGutterDelete = '#e33400',
    GitGutterChangeDelete = '#e39400',
}
for group, fg in pairs(git_gutter_highlights) do
    vim.api.nvim_set_hl(0, group, { fg = fg, bg = 'none' })
end
-- -- Follow terminal background color.
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#30365F", bg = "none" })

-- Rebuild lualine after the colorscheme has reset its highlights.
require('lualine').setup()
vim.api.nvim_set_hl(0, 'StatusLine', { fg = '#686f9a', bg = 'none' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = '#686f9a', bg = 'none' })
