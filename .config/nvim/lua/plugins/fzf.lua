local function wrap(command, opts)
    opts = opts or {}
    return function()
        opts = vim.deepcopy(opts)
        if not opts.cwd and opts.root ~= false then
            opts.cwd = IS.root()
        end
        require("fzf-lua")[command](opts)
    end
end

local function symbols_filter(entry, ctx)
    if ctx.symbols_filter == nil then
        ctx.symbols_filter = LazyVim.config.get_kind_filter(ctx.bufnr) or false
    end
    if ctx.symbols_filter == false then
        return true
    end
    return vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        opts = function(_, _)
            local config = require("fzf-lua.config")
            local actions = require("fzf-lua.actions")

            -- Quickfix
            config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
            config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
            config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
            config.defaults.keymap.fzf["ctrl-x"] = "jump"
            config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
            config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
            config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
            config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

            -- Trouble
            if LazyVim.has("trouble.nvim") then
                config.defaults.actions.files["ctrl-t"] =
                    require("trouble.sources.fzf").actions.open
            end

            -- Toggle root dir / cwd
            config.defaults.actions.files["ctrl-r"] = function(_, ctx)
                local o = vim.deepcopy(ctx.__call_opts)
                o.root = o.root == false
                o.cwd = nil
                o.buf = ctx.__CTX.bufnr
                wrap(ctx.__INFO.cmd, o)()
            end
            config.defaults.actions.files["alt-c"] =
                config.defaults.actions.files["ctrl-r"]
            config.set_action_helpstr(
                config.defaults.actions.files["ctrl-r"],
                "toggle-root-dir"
            )

            return {
                "default-title",
                fzf_colors = true,
                fzf_opts = {
                    ["--no-scrollbar"] = true,
                },
                defaults = {
                    formatter = "path.dirname_first",
                },
                ui_select = function(fzf_opts, items)
                    return vim.tbl_deep_extend("force", fzf_opts, {
                        prompt = " ",
                        winopts = {
                            title = " "
                                .. vim.trim(
                                    (fzf_opts.prompt or "Select"):gsub(
                                        "%s*:%s*$",
                                        ""
                                    )
                                )
                                .. " ",
                            title_pos = "center",
                        },
                    }, fzf_opts.kind == "codeaction" and {
                        winopts = {
                            layout = "vertical",
                            -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
                            height = math.floor(
                                math.min(vim.o.lines * 0.8 - 16, #items + 2)
                                    + 0.5
                            ) + 16,
                            width = 0.5,
                            preview = not vim.tbl_isempty(
                                        LazyVim.lsp.get_clients({
                                            bufnr = 0,
                                            name = "vtsls",
                                        })
                                    )
                                    and {
                                        layout = "vertical",
                                        vertical = "down:15,border-top",
                                        hidden = "hidden",
                                    }
                                or {
                                    layout = "vertical",
                                    vertical = "down:15,border-top",
                                },
                        },
                    } or {
                        winopts = {
                            width = 0.5,
                            -- height is number of items, with a max of 80% screen height
                            height = math.floor(
                                math.min(vim.o.lines * 0.8, #items + 2) + 0.5
                            ),
                        },
                    })
                end,
                winopts = {
                    width = 0.8,
                    height = 0.8,
                    row = 0.5,
                    col = 0.5,
                    preview = {
                        scrollchars = { "┃", "" },
                    },
                },
                files = {
                    cwd_prompt = false,
                    actions = {
                        ["alt-i"] = { actions.toggle_ignore },
                        ["alt-h"] = { actions.toggle_hidden },
                    },
                },
                grep = {
                    actions = {
                        ["alt-i"] = { actions.toggle_ignore },
                        ["alt-h"] = { actions.toggle_hidden },
                    },
                },
                lsp = {
                    symbols = {
                        symbol_hl = function(s)
                            return "TroubleIcon" .. s
                        end,
                        symbol_fmt = function(s)
                            return s:lower() .. "\t"
                        end,
                        child_prefix = false,
                    },
                    code_actions = {
                        previewer = vim.fn.executable("delta") == 1
                                and "codeaction_native"
                            or nil,
                    },
                },
            }
        end,
        config = function(_, opts)
            if opts[1] == "default-title" then
                -- use the same prompt for all pickers for profile `default-title` and
                -- profiles that use `default-title` as base profile
                local function fix(t)
                    t.prompt = t.prompt ~= nil and " " or nil
                    for _, v in pairs(t) do
                        if type(v) == "table" then
                            fix(v)
                        end
                    end
                    return t
                end
                opts = vim.tbl_deep_extend(
                    "force",
                    fix(require("fzf-lua.profiles.default-title")),
                    opts
                )
                opts[1] = nil
            end
            require("fzf-lua").setup(opts)
        end,
        init = function()
            LazyVim.on_very_lazy(function()
                vim.ui.select = function(...)
                    require("lazy").load({ plugins = { "fzf-lua" } })
                    local opts = LazyVim.opts("fzf-lua") or {}
                    require("fzf-lua").register_ui_select(opts.ui_select or nil)
                    return vim.ui.select(...)
                end
            end)
        end,
        keys = {
            {
                "<leader>,",
                wrap("buffers", { sort_mru = true, sort_lastused = true }),
                desc = "Switch Buffer",
            },
            {
                "<leader>/",
                wrap("live_grep"),
                desc = "Grep (Root Dir)",
            },
            {
                "<leader>:",
                wrap("command_history"),
                desc = "Command History",
            },
            {
                "<leader><space>",
                wrap("files"),
                desc = "Find Files (Root Dir)",
            },
            -- find
            {
                "<leader>fb",
                wrap("buffers", { sort_mru = true, sort_lastused = true }),
                desc = "Buffers",
            },
            {
                "<leader>fc",
                wrap("files", { cwd = vim.fn.stdpath("config") }),
                desc = "Find Config File",
            },
            {
                "<leader>ff",
                wrap("files"),
                desc = "Find Files (Root Dir)",
            },
            {
                "<leader>fF",
                wrap("files", { root = false }),
                desc = "Find Files (cwd)",
            },
            {
                "<leader>fg",
                wrap("git_files"),
                desc = "Find Files (git-files)",
            },
            {
                "<leader>fr",
                wrap("oldfiles"),
                desc = "Recent",
            },
            {
                "<leader>fR",
                wrap("oldfiles", { cwd = vim.uv.cwd() }),
                desc = "Recent (cwd)",
            },
            -- git
            {
                "<leader>gc",
                wrap("git_commits"),
                desc = "Commits",
            },
            {
                "<leader>gs",
                wrap("git_status"),
                desc = "Status",
            },
            -- search
            {
                '<leader>s"',
                wrap("registers"),
                desc = "Registers",
            },
            {
                "<leader>sa",
                wrap("autocmds"),
                desc = "Auto Commands",
            },
            {
                "<leader>sb",
                wrap("grep_curbuf"),
                desc = "Buffer",
            },
            {
                "<leader>sc",
                wrap("command_history"),
                desc = "Command History",
            },
            {
                "<leader>sC",
                wrap("commands"),
                desc = "Commands",
            },
            {
                "<leader>sd",
                wrap("diagnostics_document"),
                desc = "Document Diagnostics",
            },
            {
                "<leader>sD",
                wrap("diagnostics_workspace"),
                desc = "Workspace Diagnostics",
            },
            {
                "<leader>sg",
                wrap("live_grep"),
                desc = "Grep (Root Dir)",
            },
            {
                "<leader>sG",
                wrap("live_grep", { root = false }),
                desc = "Grep (cwd)",
            },
            {
                "<leader>sh",
                wrap("help_tags"),
                desc = "Help Pages",
            },
            {
                "<leader>sH",
                wrap("highlights"),
                desc = "Search Highlight Groups",
            },
            {
                "<leader>sj",
                wrap("jumps"),
                desc = "Jumplist",
            },
            {
                "<leader>sk",
                wrap("keymaps"),
                desc = "Key Maps",
            },
            {
                "<leader>sl",
                wrap("loclist"),
                desc = "Location List",
            },
            {
                "<leader>sM",
                wrap("man_pages"),
                desc = "Man Pages",
            },
            {
                "<leader>sm",
                wrap("marks"),
                desc = "Jump to Mark",
            },
            {
                "<leader>sR",
                wrap("resume"),
                desc = "Resume",
            },
            {
                "<leader>sq",
                wrap("quickfix"),
                desc = "Quickfix List",
            },
            {
                "<leader>sw",
                wrap("grep_cword"),
                desc = "Word (Root Dir)",
            },
            {
                "<leader>sW",
                wrap("grep_cword", { root = false }),
                desc = "Word (cwd)",
            },
            {
                "<leader>sw",
                wrap("grep_visual"),
                mode = "v",
                desc = "Selection (Root Dir)",
            },
            {
                "<leader>sW",
                wrap("grep_visual", { root = false }),
                mode = "v",
                desc = "Selection (cwd)",
            },
            {
                "<leader>uC",
                wrap("colorschemes"),
                desc = "Colorscheme with Preview",
            },
            {
                "<leader>ss",
                wrap("lsp_document_symbols", { regex_filter = symbols_filter }),
                desc = "Goto Symbol",
            },
            {
                "<leader>sS",
                wrap(
                    "lsp_live_workspace_symbols",
                    { regex_filter = symbols_filter }
                ),
                desc = "Goto Symbol (Workspace)",
            },
        },
    },
}
