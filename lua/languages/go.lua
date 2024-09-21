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

vim.api.nvim_set_keymap('n', '<leader>alt', ':lua alternate_test_file()<enter>', { silent = true })

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
    -- Populate the quickfix list with the output
    vim.fn.setqflist({}, 'r', { title = 'Go Test Output', lines = output })

    -- Open the quickfix list
    vim.cmd("copen")
    return
  end

  vim.cmd('redraw!')
  print("Looks good man!")

  -- TODO: Make it asynchronous
  cmd = "go tool cover -html /tmp/cover.out -o /tmp/cover.html"
  vim.fn.systemlist(cmd)
end

vim.api.nvim_set_keymap('n', '<leader>gt', ':lua run_go_test_from_cursor()<enter>', { noremap = true, silent = true })

function open_coverage_in_browser()
  -- Build the Go test command
  local cmd = "open /tmp/cover.html"

  print(cmd)
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

vim.api.nvim_set_keymap('n', '<leader>cov', ':lua open_coverage_in_browser()<enter>', { noremap = true, silent = true })

-- Miscs

-- -- Show file name with line number and copy to clipboard.
vim.api.nvim_set_keymap('n', '<C-g>', ':lua get_file_name_with_line_number()<enter>', { noremap = true, silent = true })

function get_file_name_with_line_number()
    local filename = vim.fn.expand('%:.')
    local linenumber = vim.fn.line('.')
    local result = filename .. ':' .. linenumber
    vim.fn.setreg('*', result)
    vim.api.nvim_out_write(result .. "\n")
end

-- -- Open the current file name and line number in Github UI.
vim.api.nvim_set_keymap('n', '<leader>ogh', ':lua open_current_line_in_github_ui()<enter>', { noremap = true, silent = true })

function open_current_line_in_github_ui()
    -- Get the current file name and line number
    local filename = vim.fn.expand('%:.')
    local linenumber = vim.fn.line('.')
    
    -- Use vim.loop.spawn for asynchronous execution
    vim.loop.spawn("gh", {
        args = {"browse", filename .. ":" .. linenumber}
    }, function(code, signal)
        -- Notify the user after the command is completed
        if code == 0 then
            vim.schedule(function()
                vim.api.nvim_out_write("Opened in browser: " .. filename .. " at line " .. linenumber .. "\n")
            end)
            return
        end

        vim.schedule(function()
            vim.api.nvim_err_writeln("Error opening GitHub link")
        end)
    end)

    vim.api.nvim_out_write("Opening in browser: " .. filename .. " at line " .. linenumber .. "\n")
end
