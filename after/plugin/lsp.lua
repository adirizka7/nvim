vim.lsp.config('gopls', {
  settings = {
    gopls = {
      buildFlags = { '-tags=integration' },
    },
  },
})

vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = {
        command = 'clippy',
      },
    },
  },
})

-- nvim-lspconfig provides server defaults; Neovim's native API enables them.
for _, server in ipairs({
  'phpactor',
  'pyright',
  'svelte',
  'terraformls',
  'denols',
  'gopls',
  'rust_analyzer',
  'yamlls',
}) do
  vim.lsp.enable(server)
end

-- Go format on save with goimports logic.
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    local client = vim.lsp.get_clients({ bufnr = 0, name = 'gopls' })[1]
    local encoding = client and client.offset_encoding or 'utf-16'
    local params = vim.lsp.util.make_range_params(0, encoding)
    params.context = { only = { 'source.organizeImports' } }

    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 3000)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({ async = false })
  end,
})

vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
