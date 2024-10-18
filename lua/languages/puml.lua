local generated_png_file = "/tmp/puml.generated.png"
local generated_html_file = "/tmp/puml.generated.html"

function generate_puml()
    -- Get the current buffer's file path in Neovim
    local current_file = vim.api.nvim_buf_get_name(0)

    -- Ensure the file is a PlantUML file
    if not current_file:match("%.puml$") then
        error("The current file is not a PlantUML (.puml) file")
    end

    -- Command to execute node-plantuml CLI
    local command = string.format("puml generate -p %s -o %s", current_file, generated_png_file)

    local output = vim.fn.systemlist(command)

    -- If the command fails, alert the user
    if vim.v.shell_error ~= 0 then
      -- Populate the quickfix list with the output
      vim.fn.setqflist({}, 'r', { title = 'PUML Generate Output', lines = output })

      -- Open the quickfix list
      vim.cmd("copen")
      return
    end

    vim.cmd('redraw!')
    print("PlantUML Image is generated!")
end

function open_puml_in_browser()
    local html_puml = [[
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>vim-puml</title>
        <style>
            body {
                display: flex;
                justify-content: center;
                align-items: center;
                margin: 0;
            }
        </style>
    </head>
    <body>
        <img src="/tmp/puml.generated.png" alt="A centered image">
    </body>
    </html>
    ]]

    -- Open the file in write mode
    local file = io.open(generated_html_file, "w")
    if not file then
        error("Unable to open file for writing: " .. generated_html_file)
    end

    -- Write the content to the file
    file:write(html_puml)
    
    -- Close the file
    file:close()

    -- Build the Go test command
    local cmd = string.format("open %s", generated_html_file)

    -- Run the command and capture its output
    -- TODO: Make it asynchronous
    local output = vim.fn.systemlist(cmd)

    -- If the command fails, alert the user
    if vim.v.shell_error ~= 0 then
      -- Populate the quickfix list with the output
      vim.fn.setqflist({}, 'r', { title = 'Error opening Generated PUML', lines = output })

      -- Open the quickfix list
      vim.cmd("copen")
      return
    end

    vim.cmd('redraw!')
    print("Generated PUML is opened in browser!")
end

-- Create an autocommand group to avoid duplicates.
vim.api.nvim_create_augroup("PUMLFileMappings", { clear = true })

-- Set the key mapping for Go file type.
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.puml",  -- This applies to PUML files only.
    callback = function()
        -- Open alternate test file.
        vim.api.nvim_set_keymap('n', '<leader>g', ':lua generate_puml()<enter>', { silent = true, noremap = true })

        -- Open alternate test file.
        vim.api.nvim_set_keymap('n', '<leader>o', ':lua open_puml_in_browser()<enter>', { silent = true, noremap = true })
    end,
    group = "PUMLFileMappings",
})
