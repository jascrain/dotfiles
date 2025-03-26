local function have_compiler()
    return vim.fn.executable("cc") == 1
        or vim.fn.executable("gcc") == 1
        or vim.fn.executable("clang") == 1
end

return {
    {
        "folke/which-key.nvim",
        opts = {
            spec = {
                { "<BS>", desc = "Decrement Selection", mode = "x" },
                {
                    "<c-space>",
                    desc = "Increment Selection",
                    mode = { "x", "n" },
                },
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        version = false,
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
        opts_extend = { "ensure_installed" },
        ---@type TSConfig
        ---@diagnostic disable-next-line: missing-fields
        opts = {
            highlight = { enable = true },
            indent = { enable = true },
            ensure_installed = (function()
                if have_compiler() then
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
                else
                    return {}
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
            },
        },
        ---@param opts TSConfig
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = "VeryLazy",
        enabled = true,
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
                            local config =
                                configs.get_module("textobjects.move")[name]
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

    {
        "echasnovski/mini.ai",
        event = "VeryLazy",
        opts = function()
            local ai = require("mini.ai")
            return {
                n_lines = 500,
                custom_textobjects = {
                    -- code block
                    o = ai.gen_spec.treesitter({
                        a = {
                            "@block.outer",
                            "@conditional.outer",
                            "@loop.outer",
                        },
                        i = {
                            "@block.inner",
                            "@conditional.inner",
                            "@loop.inner",
                        },
                    }),
                    -- function
                    f = ai.gen_spec.treesitter({
                        a = "@function.outer",
                        i = "@function.inner",
                    }),
                    -- class
                    c = ai.gen_spec.treesitter({
                        a = "@class.outer",
                        i = "@class.inner",
                    }),
                    -- tags
                    t = {
                        "<([%p%w]-)%f[^<%w][^<>]->.-</%1>",
                        "^<.->().*()</[^/]->$",
                    },
                    -- digits
                    d = { "%f[%d]%d+" },
                    -- word with case
                    e = {
                        {
                            "%u[%l%d]+%f[^%l%d]",
                            "%f[%S][%l%d]+%f[^%l%d]",
                            "%f[%P][%l%d]+%f[^%l%d]",
                            "^[%l%d]+%f[^%l%d]",
                        },
                        "^().*()$",
                    },
                    -- buffer
                    g = LazyVim.mini.ai_buffer,
                    -- u for usage
                    u = ai.gen_spec.function_call(),
                    U = ai.gen_spec.function_call({
                        name_pattern = "[%w_]",
                    }),
                },
            }
        end,
        config = function(_, opts)
            require("mini.ai").setup(opts)
            LazyVim.on_load("which-key.nvim", function()
                vim.schedule(function()
                    LazyVim.mini.ai_whichkey(opts)
                end)
            end)
        end,
    },
}
