return {
    "nvim-lualine/lualine.nvim",
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
                    statusline = {
                        "alpha",
                        "dashboard",
                        "ministarter",
                        "snacks_dashboard",
                    },
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch" },
                lualine_c = {
                    IS.project_name(),
                    {
                        "diagnostics",
                        icons_enabled = false,
                    },
                    {
                        function()
                            return " "
                        end,
                        separator = "",
                        padding = 0,
                    },
                    {
                        "filetype",
                        icon_only = true,
                        separator = "",
                        padding = 0,
                    },
                    {
                        IS.pretty_path,
                        padding = { left = 0, right = 1 },
                    },
                },
                lualine_x = {
                    Snacks.profiler.status(),
                    {
                        function()
                            return require("noice").api.status.mode.get()
                        end,
                        cond = function()
                            return (
                                package.loaded["noice"]
                                and require("noice").api.status.mode.has()
                            )
                        end,
                        color = function()
                            return {
                                fg = Snacks.util.color("Constant"),
                            }
                        end,
                    },
                    {
                        function()
                            return " " .. require("dap").status()
                        end,
                        cond = function()
                            return (
                                package.loaded["dap"]
                                and require("dap").status() ~= ""
                            )
                        end,
                        color = function()
                            return {
                                fg = Snacks.util.color("Debug"),
                            }
                        end,
                    },
                    {
                        require("lazy.status").updates,
                        cond = require("lazy.status").has_updates,
                        color = function()
                            return {
                                fg = Snacks.util.color("Special"),
                            }
                        end,
                    },
                    {
                        "diff",
                        source = function()
                            local gitsigns = vim.b.gitsigns_status_dict
                            if gitsigns then
                                return {
                                    added = gitsigns.added,
                                    modified = gitsigns.changed,
                                    removed = gitsigns.removed,
                                }
                            end
                        end,
                    },
                },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = { "branch" },
                lualine_c = {
                    IS.project_name(),
                    { "diagnostics", icons_enabled = false },
                    {
                        function()
                            return " "
                        end,
                        separator = "",
                        padding = 0,
                    },
                    {
                        "filetype",
                        icon_only = true,
                        separator = "",
                        padding = 0,
                    },
                    {
                        IS.pretty_path,
                        padding = { left = 0, right = 1 },
                    },
                },
            },
            extensions = { "neo-tree" },
        }

        if vim.g.trouble_lualine and LazyVim.has("trouble.nvim") then
            local trouble = require("trouble")
            local symbols = trouble.statusline({
                mode = "symbols",
                groups = {},
                title = false,
                filter = { range = true },
                format = "{kind_icon}{symbol.name:Normal}",
                hl_group = "lualine_c_normal",
            })
            table.insert(opts.sections.lualine_c, {
                symbols and symbols.get,
                cond = function()
                    return vim.b.trouble_lualine ~= false and symbols.has()
                end,
            })
        end
        return opts
    end,
}
