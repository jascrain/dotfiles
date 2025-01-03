return {
    {
        "saghen/blink.cmp",
        version = "*",
        opts_extend = {
            "sources.completion.enabled_providers",
            "sources.compat",
            "sources.default",
        },
        dependencies = "friendly-snippets",
        event = { "InsertEnter", "CmdlineEnter" },
        opts = {
            appearance = {
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = false,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
            },
            completion = {
                menu = {
                    auto_show = false,
                    draw = {
                        treesitter = { "lsp" },
                    },
                },
                documentation = {
                    window = {
                        border = "single",
                    },
                },
            },
            sources = {
                default = {
                    "lsp",
                    "path",
                    "snippets",
                    "buffer",
                },
            },
            keymap = {
                ["<C-e>"] = { "hide", "fallback" },
                ["<C-y>"] = { "select_and_accept", "fallback" },
                ["<C-p>"] = { "show", "select_prev" },
                ["<C-n>"] = { "show", "select_next" },
                ["<Tab>"] = {
                    "show",
                    function(cmp)
                        if cmp.snippet_active() then return cmp.accept()
                        else return cmp.select_and_accept() end
                    end,
                    "snippet_forward",
                    "fallback",
                },
                cmdline = {
                    ["<C-p>"] = { "select_prev", "fallback" },
                    ["<C-n>"] = { "select_next", "fallback" },
                },
            },
        },
    },

    -- lazydev
    {
        "saghen/blink.cmp",
        opts = {
            sources = {
                default = { "lazydev" },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100, -- show at a higher priority than lsp
                    },
                },
            },
        },
    },

    -- catppuccin support
    {
        "catppuccin",
        optional = true,
        opts = {
            integrations = { blink_cmp = true },
        },
    },
    {
        "rafamadriz/friendly-snippets",
        lazy = true,
    },
}
