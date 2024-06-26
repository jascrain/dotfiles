return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        cmd = "Neotree",
        keys = {
            {
                "<leader>fe",
                function()
                    require("neo-tree.command").execute({
                        toggle = true,
                        dir = (function()
                            local fname = vim.api.nvim_buf_get_name(0)
                            if fname and fname ~= "" then
                                return vim.fs.dirname(fname)
                            end
                            return vim.uv.cwd()
                        end)(),
                    })
                end,
                desc = "Explorer NeoTree (Root Dir)",
            },
            {
                "<leader>fE",
                function()
                    require("neo-tree.command").execute({
                        toggle = true,
                        dir = vim.uv.cwd()
                    })
                end,
                desc = "Explorer NeoTree (cwd)",
            },
            {
                "<leader>ge",
                function()
                    require("neo-tree.command").execute({
                        source = "git_status",
                        tobble = true,
                    })
                end,
                desc = "Git Explorer",
            },
            {
                "<leader>be",
                function()
                    require("neo-tree.command").execute({
                        source = "buffers",
                        toggle = true,
                    })
                end,
                desc = "Buffer Explorer",
            },
        },
        deactivate = function()
            vim.cmd([[Neotree close]])
        end,
        init = function()
            -- FIX: use `autocmd` for layz-loading neo-tree instead of directly
            -- requiring it, because `cwd` is not set up properly.
            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup(
                    "Neotree_start_directory",
                    { clear = true }),
                desc = "Start Neo-tree with directory",
                once = true,
                callback = function()
                    if package.loaded["neo-tree"] then
                        return
                    else
                        local stats = vim.uv.fs_stat(vim.fn.argv(0))
                        if stats and stats.type == "directory" then
                            require("neo-tree")
                        end
                    end
                end,
            })
        end,
        opts = {
            sources = {
                "filesystem",
                "buffers",
                "git_status",
                "document_symbols",
            },
            open_files_do_not_replace_types = {
                "terminal",
                "Trouble",
                "trouble",
                "qf",
                "Outline",
            },
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
            },
            default_component_configs = {
                indent = {
                    with_expanders = true,
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
                git_status = {
                    symbols = {
                        unstaged = "󰄱",
                        staged = "󰱒",
                    },
                },
            },
        },
        config = function(_, opts)
            local function on_move(data)
                local changes = {
                    files = {
                        oldUri = vim.uri_from_fname(data.source),
                        newUri = vim.uri_from_fname(data.destination),
                    },
                }
                local clients = vim.lsp.get_clients()
                for _, client in ipairs(clients) do
                    if client.supports_method("workspace/willRenameFiles") then
                        local resp = client.request_sync(
                            "workspace/willRenameFiles",
                            changes,
                            1000,
                            0)
                        if resp and resp.result ~= nil then
                            vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
                        end
                    end
                end
            end

            local events = require("neo-tree.events")
            opts.event_handlers = opts.event_handlers or {}
            vim.list_extend(opts.event_handlers, {
                { event = events.FILE_MOVED, handler = on_move },
                { event = events.FILE_RENAMED, handler = on_move},
            })
            require("neo-tree").setup(opts)
            vim.api.nvim_create_autocmd("TermClose", {
                pattern = "*lazygit",
                callback = function()
                    if package.loaded["neo-tree.sources.git_status"] then
                    require("neo-tree.sources.git_status").refresh()
                    end
                end,
            })
        end,
    },
}
