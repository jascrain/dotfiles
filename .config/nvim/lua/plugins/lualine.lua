return {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-web-devicons",
    event = "VeryLazy",
    init = function()
        vim.g.lualine_laststatus = vim.o.laststatus
        if vim.fn.argc(-1) > 0 then
            -- set an empty statusline till lualine loads
            vim.o.statusline = " "
        else
            -- hide the statusline on the starter page
            vim.o.laststatus = 0
        end
    end,
    opts = function()
        -- PERF: we don't need this lualine require madness 🤷
        local lualine_require = require("lualine_require")
        lualine_require.require = require

        vim.o.laststatus = vim.g.lualine_laststatus

        local opts = {
            options = {
                theme = "auto",
                globalstatus = vim.o.laststatus == 3,
                disabled_filetypes = {
                    statusline = { "dashboard", "alpha", "starter" },
                },
            },
            sections = {
                lualine_b = {
                    "branch",
                    "diff",
                    { "diagnostics", icons_enabled = false },
                },
                lualine_x = {
                    "encoding",
                    { "fileformat", icons_enabled = false },
                    { "filetype", icons_enabled = false },
                },
            },
        }
        return opts
    end,
}
