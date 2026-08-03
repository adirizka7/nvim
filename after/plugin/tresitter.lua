-- Use regular syntax highlighting for CSS and Svelte.
local disabled_filetypes = {
  css = true,
  svelte = true,
}

-- Reloading the config should replace this setup, not add another copy.
local group = vim.api.nvim_create_augroup('NativeTreesitter', { clear = true })

-- The plugin installs parsers, but Neovim must turn highlighting on for each file.
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    if filetype == '' or disabled_filetypes[filetype] then
      return
    end

    -- If no parser is installed for this file type, do nothing.
    pcall(vim.treesitter.start, args.buf)
  end,
})
