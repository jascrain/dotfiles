vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy_setup").setup()

local opt = vim.opt

opt.breakindent = true
opt.expandtab = true      -- use spaces instead of tabs
opt.foldlevel = 99
opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"
opt.formatoptions = "jcroqlnt"
opt.ignorecase = true
opt.linebreak = true      -- Wrap lines at convenient points
opt.list = true           -- show some invisible characters (tabs...
opt.number = true         -- show line numbers
opt.pumblend = 10         -- popup blend
opt.pumheight = 10        -- maximum number of entries in a popup
opt.shiftwidth = 4
opt.signcolumn = "yes"    -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true      -- don't ignore case with capitals
opt.smartindent = true    -- Insert indents automatically
opt.softtabstop = 4
opt.splitbelow = true     -- put new windows below current
opt.splitright = true     -- put new windows right of current
opt.termguicolors = true  -- true color support
opt.undofile = true       -- persistant undo
opt.undolevels = 10000
opt.updatetime = 200      -- save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode

if vim.fn.has("nvim-0.10") == 1 then
    opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
    opt.foldmethod = "expr"
    opt.foldtext = ""
end

vim.g.markdown_recommended_style = 0

require("lazy").setup("plugins")

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
