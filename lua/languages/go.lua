-- Go
local ts_utils = require('nvim-treesitter.ts_utils')

function alternate_test_file()
  -- get the current buffer's file path
  local filepath = vim.fn.expand('%:.')

  if string.match(filepath, "%_test.go$") then
    filepath = string.gsub(filepath, "%_test.go$", ".go")

    vim.cmd('edit ' .. filepath)
    return
  end

  -- TODO: Prevent opening a file if it doesn't exist.

  filepath = string.gsub(filepath, "%.go$", "_test.go")
  vim.cmd('edit ' .. filepath)
end

local function get_current_function_name()
    local node = ts_utils.get_node_at_cursor()
    while node do
        if node:type() == 'function_declaration' then
            local func_name_node = node:child(1)
            if func_name_node then
                return vim.treesitter.get_node_text(func_name_node, 0)
            end
        end
        node = node:parent()
    end
    return nil
end

function run_go_test_from_cursor()
  -- get the current buffer's file path
  local filepath = vim.fn.expand('%:.')
  
  -- Extract the directory path (up to the current file's directory)
  local subdir = vim.fn.fnamemodify(filepath, ":h")

  -- Get the function name under the cursor
  local cursor_line = vim.fn.getline('.')
  local test_function = get_current_function_name()

  -- If we couldn't find a test function, alert the user
  if not test_function then
    print("Not inside a test function.")
    return
  end

  -- Build the Go test command
  local cmd = "go test ./" .. subdir .. " -run " .. test_function .. " -coverprofile /tmp/cover.out"

  print(cmd)
  -- Run the command and capture its output
  -- TODO: Make it asynchronous
  local output = vim.fn.systemlist(cmd)

  -- If the command fails, alert the user
  if vim.v.shell_error ~= 0 then
    vim.cmd('redraw!')
    print("Looks like something needs some fixing 👀")
    -- Populate the quickfix list with the output
    vim.fn.setqflist({}, 'r', { title = 'Go Test Output', lines = output })

    -- Open the quickfix list
    vim.cmd("copen")
    return
  end

  vim.cmd('redraw!')
  vim.cmd('cclose')
  print("Looking good 🚀")

  -- TODO: Make it asynchronous
  cmd = "go tool cover -html /tmp/cover.out -o /tmp/cover.html"
  vim.fn.systemlist(cmd)
end

-- TODO: Make a generic function to open file in browser.
function open_coverage_in_browser()
  -- Build the Go test command
  local cmd = "open /tmp/cover.html"

  -- Run the command and capture its output
  -- TODO: Make it asynchronous
  local output = vim.fn.systemlist(cmd)

  -- If the command fails, alert the user
  if vim.v.shell_error ~= 0 then
    -- Populate the quickfix list with the output
    vim.fn.setqflist({}, 'r', { title = 'Coverage error', lines = output })

    -- Open the quickfix list
    vim.cmd("copen")
    return
  end

  vim.cmd('redraw!')
  print("Coverage opened in browser!")
end

-- Create an autocommand group to avoid duplicates.
vim.api.nvim_create_augroup("GoFileMappings", { clear = true })

-- Set the key mapping for Go file type.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",  -- This applies to Go files only.
    callback = function()
        -- Open alternate test file.
        vim.api.nvim_set_keymap('n', '<leader>alt', ':lua alternate_test_file()<enter>', { silent = true, noremap = true })

        -- Run go test for the test function under the cursor.
        vim.api.nvim_set_keymap('n', '<leader>gt', ':lua run_go_test_from_cursor()<enter>', { noremap = true, silent = true })

        -- Open coverage file in browser.
        vim.api.nvim_set_keymap('n', '<leader>cov', ':lua open_coverage_in_browser()<enter>', { noremap = true, silent = true })
    end,
    group = "GoFileMappings",
})
