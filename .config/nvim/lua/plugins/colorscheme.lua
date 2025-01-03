return {
    {
        "gruvbox-community/gruvbox",
        lazy = false,
        config = function()
            vim.g.gruvbox_italic = 1
            vim.g.gruvbox_contrast_dark = "hard"
            vim.g.gruvbox_colors = { dark0_hard = { "#000000", 0 } }
        end,
    },
    {
        "navarasu/onedark.nvim",
        lazy = true,
        opts = {
            style = "darker",
        },
        config = function(_, opts)
            require("onedark").setup(opts)
            require("onedark").load()
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = true,
    },
    {
        "catppuccin/nvim",
        lazy = true,
        name = "catppuccin",
        opts = {
            integrations = {
                aerial = true,
                alpha = true,
                cmp = true,
                dashboard = true,
                flash = true,
                fzf = true,
                grug_far = true,
                gitsigns = true,
                headlines = true,
                illuminate = true,
                indent_blankline = { enabled = true },
                leap = true,
                lsp_trouble = true,
                mason = true,
                markdown = true,
                mini = true,
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = { "undercurl" },
                        hints = { "undercurl" },
                        warnings = { "undercurl" },
                        information = { "undercurl" },
                    },
                },
                navic = { enabled = true, custom_bg = "lualine" },
                neotest = true,
                neotree = true,
                noice = true,
                notify = true,
                semantic_tokens = true,
                snacks = true,
                telescope = true,
                treesitter = true,
                treesitter_context = true,
                which_key = true,
            },
        },
        specs = {
            {
                "akinsho/bufferline.nvim",
                optional = true,
                opts = function(_, opts)
                    if (vim.g.colors_name or ""):find("catppuccin") then
                        opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
                    end
                end,
            },
        },
    },
}
