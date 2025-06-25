-- Resize window using <ctrl> arrow keys
vim.keymap.set(
    "n",
    "<C-Up>",
    "<cmd>resize +2<cr>",
    { desc = "Increase Window Height" }
)
vim.keymap.set(
    "n",
    "<C-Down>",
    "<cmd>resize -2<cr>",
    { desc = "Decrease Window Height" }
)
vim.keymap.set(
    "n",
    "<C-Left>",
    "<cmd>vertical resize -2<cr>",
    { desc = "Decrease Window Width" }
)
vim.keymap.set(
    "n",
    "<C-Right>",
    "<cmd>vertical resize +2<cr>",
    { desc = "Increase Window Width" }
)

-- Clear search on escape
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
    vim.cmd("noh")
    return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

vim.keymap.set("n", "<leader>gb", function()
    Snacks.git.blame_line()
end, { desc = "Git Blame Line" })

-- windows
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
Snacks.toggle.zen():map("<leader>uz")

-- lsp
vim.keymap.set(
    { "n", "v" },
    "<leader>cc",
    vim.lsp.codelens.run,
    { desc = "Run Codelens" }
)
vim.keymap.set(
    { "n", "v" },
    "<leader>cC",
    vim.lsp.codelens.refresh,
    { desc = "Refresh Codelens" }
)
vim.keymap.set(
    "n",
    "gK",
    vim.lsp.buf.signature_help,
    { desc = "Signature Help" }
)
