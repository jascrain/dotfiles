return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
        preset = "helix",
        delay = 500,
        spec = {
            {
                mode = { "n", "v" },
                { "<leader><tab>", group = "tabs" },
                { "<leader>c", group = "code" },
                { "<leader>d", group = "debug" },
                { "<leader>dp", group = "profiler" },
                { "<leader>f", group = "file/find" },
                { "<leader>g", group = "git" },
                { "<leader>gh", group = "hunks" },
                { "<leader>q", group = "quit/session" },
                { "<leader>s", group = "search" },
                {
                    "<leader>u",
                    group = "ui",
                    icon = { icon = "󰙵 ", color = "cyan" },
                },
                {
                    "<leader>x",
                    group = "diagnostics/quickfix",
                    icon = { icon = "󱖫 ", color = "green" },
                },
                { "K", desc = "Keyword Lookup" },
                { "[", group = "prev" },
                { "]", group = "next" },
                { "g", group = "goto" },
                { "gd", desc = "Definition" },
                { "gD", desc = "Declaration" },
                { "gO", desc = "Document Symbols" },
                { "gra", desc = "Code Action" },
                { "gri", desc = "Implementation" },
                { "grn", desc = "Rename" },
                { "grr", desc = "References" },
                { "gs", desc = "surround" },
                { "z", group = "fold" },
                {
                    "<leader>b",
                    group = "buffer",
                    expand = function()
                        return require("which-key.extras").expand.buf()
                    end,
                },
                {
                    "<leader>w",
                    group = "windows",
                    proxy = "<c-w>",
                    expand = function()
                        return require("which-key.extras").expand.win()
                    end,
                },
                { "gx", desc = "Open with system app" },
            },
        },
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Keymaps (which-key)",
        },
        {
            "<c-w><space>",
            function()
                require("which-key").show({ keys = "<c-w>", loop = true })
            end,
            desc = "Window Hydra Mode (which-key)",
        },
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
    end,
}
