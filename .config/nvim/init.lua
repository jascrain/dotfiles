vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazyvim").setup()
require("lazy").setup("plugins")
require("is")

vim.o.breakindent = true
vim.o.expandtab = true      -- use spaces instead of tabs
vim.o.foldlevel = 99
vim.o.ignorecase = true
vim.o.list = true           -- show some invisible characters (tabs...
vim.o.number = true         -- show line numbers
vim.o.pumblend = 10         -- popup blend
vim.o.pumheight = 10        -- maximum number of entries in a popup
vim.o.shiftwidth = 4
vim.o.smartcase = true      -- don't ignore case with capitals
vim.o.softtabstop = 4
vim.o.splitbelow = true     -- put new windows below current
vim.o.splitright = true     -- put new windows right of current
vim.o.termguicolors = true  -- true color support
vim.o.undofile = true       -- persistant undo
vim.o.updatetime = 200      -- save swap file and trigger CursorHold
vim.o.virtualedit = "block"

if vim.fn.has("nvim-0.10") == 1 then
    vim.opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
    vim.opt.foldmethod = "expr"
    vim.opt.foldtext = ""
end

vim.g.markdown_recommended_style = 0
vim.cmd.colorscheme("gruvbox")

local function diagnostic_icon(diagnostic)
    local icons = LazyVim.config.icons.diagnostics
    local severity = vim.diagnostic.severity[diagnostic.severity]
    local key = severity:sub(1, 1) .. severity:sub(2):lower()
    return icons[key] or "●"
end

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
        prefix = vim.fn.has("nvim-0.10.0") == 1 and diagnostic_icon or "●",
        source = "if_many",
        spacing = 4,
    },
})
