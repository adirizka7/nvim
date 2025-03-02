local repo = os.getenv("HOME") .. "/GIT/zettelkasten"
local fleeting = repo .. "/fleeting"

local templates = repo .. "/templates"
local templates_fleeting = templates .. "/fleeting.md"

function create_fleeting_note(title)
    if not title or title == "" then
        print("Error: Title is required!")
        return
    end

    -- Format the filename using the title
    local sanitized_title = title:gsub("%s+", "-"):gsub("[^%w%-]", "")  -- Replace spaces with dashes & remove special chars
    local filename = fleeting .. "/" .. os.date("%Y-%m-%d") .. "-" .. sanitized_title .. ".md"

    -- Open the file in a new buffer
    vim.cmd("edit " .. filename)

    -- If the file is empty, load the template
    if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
        local template_file, err = io.open(templates_fleeting, "r")
        if template_file then
            local template_content = template_file:read("*a")
            template_file:close()

            -- Replace placeholders dynamically
            template_content = template_content:gsub("{{date}}", os.date("%Y-%m-%d"))
            template_content = template_content:gsub("{{title}}", titleize(title))

            -- Insert into buffer without saving
            vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template_content, "\n"))
        else
            print("Error: Template file not found!", err)
        end
    end
end

function prompt_fleeting_note()
    vim.ui.input({ prompt = "Enter note title: " }, function(title)
        if title and title ~= "" then
            create_fleeting_note(title)
        else
            print("Error: Title is required!")
        end
    end)
end

vim.api.nvim_set_keymap("n", "<leader>zc", ":lua prompt_fleeting_note()<CR>", { noremap = true, silent = true })

function open_todo()
  -- Ensure the repo path is absolute
  local abs_repo_path = vim.fn.fnamemodify(repo, "%:.")

  -- Get current window ID
  local win_id = vim.api.nvim_get_current_win()

  -- Change directory for the specific window
  vim.api.nvim_win_call(win_id, function()
    vim.cmd("cd " .. abs_repo_path)
  end)

  -- Open the `todo.md` file in the same window
  local todo_file = abs_repo_path .. "/todo.md"
  vim.cmd("edit " .. vim.fn.fnameescape(todo_file))
end

vim.api.nvim_set_keymap("n", "<leader>zt", ":lua open_todo()<CR>", { noremap = true, silent = true })
