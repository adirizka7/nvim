local curl = require("curl")
curl.setup({ open_with = "tab" })

vim.keymap.set("n", "<leader>clo", curl.open_global_tab, { desc = "Open global Curl tab" })
