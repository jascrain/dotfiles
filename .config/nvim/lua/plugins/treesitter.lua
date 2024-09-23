return {
    {
        "folke/which-key.nvim",
        opts = {
            spec = {
                { "<BS>", desc = "Decrement Selection", mode = "x" },
                { "<c-space>", desc = "Increment Selection", mode = { "x", "n" } },
            },
        },
    },
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
                        "diff",
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
                        ["]f"] = "@function.outer",
                        ["]c"] = "@class.outer",
                        ["]a"] = "@parameter.inner",
                    },
                    goto_next_end = {
                        ["]F"] = "@function.outer",
                        ["]C"] = "@class.outer",
                        ["]A"] = "@parameter.inner",
                    },
                    goto_previous_start = {
                        ["[f"] = "@function.outer",
                        ["[c"] = "@class.outer",
                        ["[a"] = "@parameter.inner",
                    },
                    goto_previous_end = {
                        ["[F"] = "@function.outer",
                        ["[C"] = "@class.outer",
                        ["[A"] = "@parameter.inner",
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
            if LazyVim.is_loaded("nvim-treesitter") then
                local opts = LazyVim.opts("nvim-treesitter")
                require("nvim-treesitter.configs").setup({
                    textobjects = opts.textobjects,
                })
            end

            -- When in diff mode, we want to use the default vim text objects
            -- c & C instead of the treesitter ones.
            local move = require("nvim-treesitter.textobjects.move")
            local configs = require("nvim-treesitter.configs")
            for name, fn in pairs(move) do
                if name:find("goto") == 1 then
                    move[name] = function(q, ...)
                        if vim.wo.diff then
                            local config = configs.get_module("textobjects.move")[name]
                            for key, query in pairs(config or {}) do
                                if q == query and key:find("[%]%[][cC]") then
                                    vim.cmd("normal! " .. key)
                                    return
                                end
                            end
                        end
                        return fn(q, ...)
                    end
                end
            end
        end,
    },
}
