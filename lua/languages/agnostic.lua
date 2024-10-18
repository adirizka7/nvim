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

-- -- Open the current file name and line number in Github UI.
vim.api.nvim_set_keymap('n', '<leader>ogh', ':lua open_current_line_in_github_ui()<enter>', { noremap = true, silent = true })

function get_file_name_with_line_number()
    local filename = vim.fn.expand('%:.')
    local linenumber = vim.fn.line('.')
    local result = filename .. ':' .. linenumber
    vim.fn.setreg('*', result)
    vim.api.nvim_out_write(result .. "\n")
end

-- -- Show file name with line number and copy to clipboard.
vim.api.nvim_set_keymap('n', '<C-g>', ':lua get_file_name_with_line_number()<enter>', { noremap = true, silent = true })
