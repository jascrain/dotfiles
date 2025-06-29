vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy_setup").setup()
require("options")
require("lazy").setup("plugins")
require("keymaps")

vim.cmd.colorscheme("gruvbox")

vim.diagnostic.config({
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
        },
    },
    underline = true,
    update_in_insert = false,
    virtual_text = {
        prefix = function(diagnostic)
            local icons = LazyVim.config.icons.diagnostics
            local severity = vim.diagnostic.severity[diagnostic.severity]
            local key = severity:sub(1, 1) .. severity:sub(2):lower()
            return icons[key] or "●"
        end,
        source = "if_many",
        spacing = 4,
    },
})
