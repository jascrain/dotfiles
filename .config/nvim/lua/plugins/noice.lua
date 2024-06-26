return {
    {
        "folke/noice.nvim",
        dependencies = {
            "nui.nvim",
            "nvim-notify",
        },
        event = "VeryLazy",
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = false,
                lsp_doc_border = true,
            },
        },
    },
    {
        "MunifTanjim/nui.nvim",
        lazy = true,
    },
    {
        "rcarriga/nvim-notify",
        lazy = true,
        opts = {
            stages = "static",
            timeout = 3000,
            max_height = function()
                return math.floor(vim.o.lines * 0.75)
            end,
            max_width = function()
                return math.floor(vim.o.columns *  0.75)
            end,
            on_open = function(win)
                vim.api.nvim_win_set_config(win, { zindex = 100 })
            end,
        },
    },
}
