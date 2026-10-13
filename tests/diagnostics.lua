-- Run with: nvim --headless -u NONE -l tests/diagnostics.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
require('languages.agnostic')

local api = vim.api
local namespace = api.nvim_create_namespace('diagnostics-regression')
local paths = {}

local function unloaded_file(lines)
  local path = vim.fn.tempname()
  paths[#paths + 1] = path
  vim.fn.writefile(lines, path)
  local bufnr = vim.fn.bufadd(path)
  assert(not api.nvim_buf_is_loaded(bufnr))
  return bufnr, path
end

local function diagnostic(lnum)
  return {
    lnum = lnum,
    col = 0,
    end_lnum = lnum,
    end_col = 3,
    severity = vim.diagnostic.severity.ERROR,
    message = 'Cached diagnostic',
  }
end

local function underlines(bufnr)
  local ns = vim.diagnostic.get_namespace(namespace).user_data.underline_ns
  return ns and api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true }) or {}
end

local ok, err = xpcall(function()
  -- A rename loads an unopened file with a cached diagnostic past its EOF.
  local bufnr, path = unloaded_file({ 'old name', 'second line' })
  vim.diagnostic.set(namespace, bufnr, { diagnostic(20) })
  vim.lsp.util.apply_workspace_edit({
    changes = {
      [vim.uri_from_fname(path)] = {
        {
          range = {
            start = { line = 0, character = 0 },
            ['end'] = { line = 0, character = 3 },
          },
          newText = 'new',
        },
      },
    },
  }, 'utf-16')
  assert(api.nvim_buf_get_lines(bufnr, 0, 1, true)[1] == 'new name', 'Rename did not apply')
  assert(#underlines(bufnr) > 0, 'Diagnostics should be underlined after loading')
  assert(underlines(bufnr)[1][1] == 1, 'Out-of-range diagnostic should be clamped to EOF')
  assert(vim.diagnostic.get(bufnr, { namespace = namespace })[1].lnum == 20,
    'Rendering must not change the cached diagnostic')

  -- In-range diagnostics must also appear when a file is opened normally.
  local valid_bufnr = unloaded_file({ 'first line', 'second line' })
  vim.diagnostic.set(namespace, valid_bufnr, { diagnostic(1) })
  vim.fn.bufload(valid_bufnr)
  assert(#underlines(valid_bufnr) > 0, 'Valid diagnostics disappeared on load')

  -- Already-loaded buffers still use normal diagnostic rendering and clamping.
  vim.diagnostic.set(namespace, valid_bufnr, { diagnostic(30) })
  assert(underlines(valid_bufnr)[1][1] == 1, 'Loaded-buffer diagnostics should be clamped')
  vim.diagnostic.reset(namespace, valid_bufnr)
  assert(#underlines(valid_bufnr) == 0, 'Reset should remove underlines')

  -- Do not resurrect diagnostics cleared or disabled before a buffer loads.
  local cleared_bufnr = unloaded_file({ 'first line' })
  vim.diagnostic.set(namespace, cleared_bufnr, { diagnostic(20) })
  vim.diagnostic.reset(namespace, cleared_bufnr)
  vim.fn.bufload(cleared_bufnr)
  assert(#underlines(cleared_bufnr) == 0, 'Cleared diagnostics reappeared on load')

  local disabled_bufnr = unloaded_file({ 'first line' })
  vim.diagnostic.enable(false, { bufnr = disabled_bufnr, ns_id = namespace })
  vim.diagnostic.set(namespace, disabled_bufnr, { diagnostic(20) })
  vim.fn.bufload(disabled_bufnr)
  assert(#underlines(disabled_bufnr) == 0, 'Disabled diagnostics reappeared on load')
  vim.diagnostic.enable(true, { bufnr = disabled_bufnr, ns_id = namespace })
  assert(#underlines(disabled_bufnr) > 0, 'Re-enabled diagnostics should be visible')

  -- Reloading the configuration must not duplicate the redraw callback.
  dofile('lua/languages/agnostic.lua')
  assert(#api.nvim_get_autocmds({ group = 'LoadedBufferDiagnostics' }) == 1,
    'Reload duplicated the diagnostic autocmd')
end, debug.traceback)

for _, path in ipairs(paths) do
  vim.fn.delete(path)
end

if not ok then
  error(err)
end
print('Diagnostic regression tests passed')
