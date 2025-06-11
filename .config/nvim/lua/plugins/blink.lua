return {
    {
        "saghen/blink.cmp",
        version = "*",
        opts_extend = {
            "sources.completion.enabled_providers",
            "sources.compat",
            "sources.default",
        },
        dependencies = "rafamadriz/friendly-snippets",
        event = "InsertEnter",
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            appearance = {
                -- sets the fallback highlight groups to nvim-cmp's highlight groups
                -- useful for when your theme doesn't support blink.cmp
                -- will be removed in a future release, assuming themes add support
                use_nvim_cmp_as_default = false,
                -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- adjusts spacing to ensure icons are aligned
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
            cmdline = {
                enabled = false,
            },
            keymap = {
                preset = "enter",
                ["<C-y>"] = { "select_and_accept", "fallback" },
                ["<C-p>"] = { "show", "select_prev", "fallback" },
                ["<C-n>"] = { "show", "select_next", "fallback" },
            },
        },
    },

    -- add icons
    {
        "saghen/blink.cmp",
        opts = function(_, opts)
            opts.appearance = opts.appearance or {}
            opts.appearance.kind_icons = vim.tbl_extend(
                "force",
                opts.appearance.kind_icons or {},
                LazyVim.config.icons.kinds
            )
        end,
    },

    -- lazydev
    {
        "saghen/blink.cmp",
        opts = {
            sources = {
                -- add lazydev to your completion providers
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
}
