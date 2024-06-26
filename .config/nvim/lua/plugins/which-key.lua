return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        plugins = { spelling = true },
        defaults = {
            mode = { "n", "v" },
            ["g"] = { name = "+goto" },
            ["gd"] = { name = "Definition" },
            ["gD"] = { name = "Declaration" },
            ["z"] = { name = "+fold" },
            ["K"] = { name = "Keyword Lookup" },
            ["]"] = { name = "+next" },
            ["["] = { name = "+prev" },
            ["<leader>c"] = { name = "+code" },
            ["<leader>f"] = { name = "+find" },
            ["<leader>g"] = { name = "+git" },
            ["<leader>gh"] = { name = "+hunks" },
            ["<leader>s"] = { name = "+search" },
            ["<leader>u"] = { name = "+ui" },
        },
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
        wk.register(opts.defaults)
    end,
}
