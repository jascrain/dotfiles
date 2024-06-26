return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "LazyFile", "VeryLazy" },
        -- load early when opening a file from the cmdline
        lazy = vim.fn.argc(-1) == 0,
        init = function(plugin)
            -- PERF: add nvim-treesitter queries to the rtp and it's custom
            -- query predicates early. This is needed because a bunch of
            -- plugins no longer `require("nvim-treesitter")`, which no longer
            -- trigger the **nvim-treesitter** module to be loaded in time.
            -- Luckily, the only things that those plugins need are the custom
            -- queries, which we make available during startup.
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        keys = {
            { "<c-space>", desc = "Increment Selection" },
            { "<bs>", desc = "Decrement Selection", mode = "x" },
        },
        opts = {
            highlight = { enable = true },
            indent = { enable = true },
            ensure_installed = (function()
                if not (vim.fn.executable("cc") == 1 or
                        vim.fn.executable("gcc") == 1 or
                        vim.fn.executable("clang") == 1) then
                    return {}
                else
                    return {
                        "bash",
                        "lua",
                        "markdown",
                        "markdown_inline",
                        "regex",
                        "vim",
                        "vimdoc",
                    }
                end
            end)(),
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
            textobjects = {
                move = {
                    enable = true,
                    goto_next_start = {
                        ["]f"] = {
                            query = "@function.outer",
                            desc = "Next function start",
                        },
                        ["]c"] = {
                            query = "@class.outer",
                            desc = "Next class start",
                        },
                    },
                    goto_next_end = {
                        ["]F"] = {
                            query = "@function.outer",
                            desc = "Next function end",
                        },
                        ["]C"] = {
                            query = "@class.outer",
                            desc = "Next class end",
                        }
                    },
                    goto_previous_start = {
                        ["[f"] = {
                            query = "@function.outer",
                            desc = "Previous function start",
                        },
                        ["[c"] = {
                            query = "@class.outer",
                            desc = "Previous class start",
                        },
                    },
                    goto_previous_end = {
                        ["[F"] = {
                            query = "@function.outer",
                            desc = "Previous function end",
                        },
                        ["[C"] = {
                            query = "@class.outer",
                            desc = "Previous class end",
                        },
                    },
                },
                select = {
                    enable = true,
                    lookahead = true,
                    include_surrounding_whitespace = true,
                    keymaps = {
                        ["af"] = {
                            query = "@function.outer",
                            desc = "a function",
                        },
                        ["if"] = {
                            query = "@function.inner",
                            desc = "inner function",
                        },
                        ["ac"] = {
                            query = "@class.outer",
                            desc = "a class",
                        },
                        ["ic"] = {
                            query = "@class.inner",
                            desc = "inner class",
                        },
                    },
                    selection_modes = {
                        ["@function.inner"] = "V",
                    }
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = "VeryLazy",
        config = function()
            -- If treesitter is already loaded, we need to run config again for
            -- textobjects
            LazyVim = require("lazyvim")
            if LazyVim.is_loaded("nvim-treesitter") then
                local opts = LazyVim.opts("nvim-treesitter")
                require("nvim-treesitter.configs").setup({
                    textobjects = opts.textobjects,
                })
            end
        end,
    },
}
