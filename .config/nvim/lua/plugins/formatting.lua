return {
    {
        "stevearc/conform.nvim",
        lazy = true,
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>cF",
                function()
                    require("conform").format({
                        formatters = { "injected" },
                    })
                end,
                mode = { "n", "v" },
                desc = "Format Injected Langs",
            },
            {
                "<leader>cf",
                function()
                    require("conform").format()
                end,
                mode = { "n", "v" },
                desc = "Format",
            },
        },
        ---@type conform.setupOpts
        opts = {
            default_format_opts = {
                timeout_ms = 3000,
                async = false,
                quiet = false,
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                lua = { "stylua" },
                fish = { "fish_indent" },
                sh = { "shfmt" },
            },
            formatters = {
                injected = {
                    options = {
                        ignore_errors = true,
                    },
                },
            },
        },
        init = function()
            vim.o.formatexpr = [[v:lua.require("conform").formatexpr()]]
        end,
    },
}
