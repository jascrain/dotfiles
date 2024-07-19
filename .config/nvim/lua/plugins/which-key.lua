return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        plugins = { spelling = true },
        defaults = {
            {
                mode = { "n", "v" },
                { "<leader>c", group = "code" },
                { "<leader>f", group = "find" },
                { "<leader>g", group = "git" },
                { "<leader>h", group = "hunks" },
                { "<leader>s", group = "search" },
                { "<leader>u", group = "ui" },
                { "K", desc = "Keyword Lookup" },
                { "[", group = "prev" },
                { "]", group = "next" },
                { "g", group = "goto" },
                { "gD", desc = "Declaration" },
                { "gd", desc = "Definition" },
                { "z", group = "fold" },
            },
        },
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
        wk.add(opts.defaults)
    end,
}
