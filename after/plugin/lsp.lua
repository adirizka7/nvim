require'lspconfig'.phpactor.setup{}
require'lspconfig'.pyright.setup{}
require'lspconfig'.gopls.setup{
  settings = {
    gopls = {
      buildFlags =  {"-tags=integration"}
    }
  }
}

-- Go format on save with goimports logic.
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({async = false})
  end
})

-- -- LSP Rename
vim.api.nvim_set_keymap('n', '<leader>rn', ':lua vim.lsp.buf.rename()<enter>', {})
