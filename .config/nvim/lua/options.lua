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
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
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
