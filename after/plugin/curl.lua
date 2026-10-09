local curl = require("curl")
curl.setup({ open_with = "tab" })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    pattern = "*.curl",
    callback = function(args)
        vim.bo[args.buf].filetype = "curl"
    end,
})

vim.keymap.set("n", "<leader>clo", function()
    curl.open_global_tab()
    vim.bo.filetype = "curl"
end, { desc = "Open global Curl tab" })
