local kind_filter = {
    lua = {
        "Package",
    },
}

local function symbols_filter(entry, ctx)
    if ctx.symbols_filter == nil then
        local ft = vim.bo[ctx.bufnr].filetype
        ctx.symbols_filter = kind_filter[ft] or false
    end
    if ctx.symbols_filter == false then
        return true
    end
    return not vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

local function ui_select(opts, items)
    local title = "Select"
    if opts.prompt then
        title = vim.trim(opts.prompt):gsub("%s*:", "")
    end
    local height = (#items + 4) / vim.o.lines
    height = math.min(math.max(height, 0.15), 0.7)
    return vim.tbl_deep_extend("force", opts, {
        prompt = "> ",
        winopts = {
            title = " " .. title .. " ",
            width = 0.5,
            height = height,
        },
    })
end

return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        opts = {
            fzf_colors = true,
            keymap = {
                fzf = {
                    ["ctrl-q"] = "select-all+accept",
                    ["ctrl-u"] = "half-page-up",
                    ["ctrl-d"] = "half-page-down",
                    ["ctrl-x"] = "jump",
                },
                builtin = {
                    ["<c-f>"] = "preview-page-down",
                    ["<c-b>"] = "preview-page-up",
                },
            },
            actions = {
                files = {
                    true,
                    ["ctrl-r"] = function(_, opts)
                        local o = vim.tbl_deep_extend(
                            "keep",
                            { resume = true },
                            opts.__call_opts
                        )
                        if o.root == false then
                            o.root = true
                            o.cwd = IS.root() or vim.uv.cwd()
                        elseif o.root == true then
                            o.root = false
                            o.cwd = nil
                        end
                        opts.__call_fn(o)
                    end,
                },
            },
        },
        init = function()
            LazyVim.on_very_lazy(function()
                vim.ui.select = function(...)
                    require("fzf-lua").register_ui_select(ui_select)
                    return vim.ui.select(...)
                end
            end)
        end,
        keys = {
            {
                "<c-j>",
                "<c-j>",
                ft = "fzf",
                mode = "t",
                nowait = true,
            },
            {
                "<c-k>",
                "<c-k>",
                ft = "fzf",
                mode = "t",
                nowait = true,
            },
            {
                "<leader>,",
                function()
                    require("fzf-lua").buffers({
                        sort_mru = true,
                        sort_lastused = true,
                    })
                end,
                desc = "Switch Buffer",
            },
            {
                "<leader>/",
                function()
                    require("fzf-lua").live_grep({
                        root = true,
                        cwd = IS.root() or vim.uv.cwd(),
                    })
                end,
                desc = "Grep (Root Dir)",
            },
            {
                "<leader>:",
                function()
                    require("fzf-lua").command_history()
                end,
                desc = "Command History",
            },
            {
                "<leader><space>",
                function()
                    require("fzf-lua").files({
                        root = true,
                        cwd = IS.root() or vim.uv.cwd(),
                    })
                end,
                desc = "Find Files (Root Dir)",
            },
            -- find
            {
                "<leader>fb",
                function()
                    require("fzf-lua").buffers({
                        sort_mru = true,
                        sort_lastused = true,
                    })
                end,
                desc = "Buffers",
            },
            {
                "<leader>fc",
                function()
                    require("fzf-lua").files({
                        cwd = vim.fn.stdpath("config"),
                    })
                end,
                desc = "Find Config File",
            },
            {
                "<leader>ff",
                function()
                    require("fzf-lua").files({
                        root = true,
                        cwd = IS.root() or vim.uv.cwd(),
                    })
                end,
                desc = "Find Files (Root Dir)",
            },
            {
                "<leader>fF",
                function()
                    require("fzf-lua").files({
                        root = false,
                    })
                end,
                desc = "Find Files (cwd)",
            },
            {
                "<leader>fg",
                function()
                    require("fzf-lua").git_files()
                end,
                desc = "Find Files (git-files)",
            },
            {
                "<leader>fr",
                function()
                    require("fzf-lua").oldfiles({
                        cwd_only = false,
                    })
                end,
                desc = "Recent",
            },
            {
                "<leader>fR",
                function()
                    require("fzf-lua").oldfiles({
                        cwd_only = true,
                    })
                end,
                desc = "Recent (cwd)",
            },
            -- git
            {
                "<leader>gc",
                function()
                    require("fzf-lua").git_commits({
                        cwd = IS.root() or vim.uv.cwd(),
                    })
                end,
                desc = "Commits",
            },
            {
                "<leader>gs",
                function()
                    require("fzf-lua").git_status({
                        cwd = IS.root() or vim.uv.cwd(),
                    })
                end,
                desc = "Status",
            },
            -- search
            {
                '<leader>s"',
                function()
                    require("fzf-lua").registers()
                end,
                desc = "Registers",
            },
            {
                "<leader>sa",
                function()
                    require("fzf-lua").autocmds()
                end,
                desc = "Auto Commands",
            },
            {
                "<leader>sb",
                function()
                    require("fzf-lua").grep_curbuf()
                end,
                desc = "Buffer",
            },
            {
                "<leader>sc",
                function()
                    require("fzf-lua").command_history()
                end,
                desc = "Command History",
            },
            {
                "<leader>sC",
                function()
                    require("fzf-lua").commands()
                end,
                desc = "Commands",
            },
            {
                "<leader>sd",
                function()
                    require("fzf-lua").diagnostics_document()
                end,
                desc = "Document Diagnostics",
            },
            {
                "<leader>sD",
                function()
                    require("fzf-lua").diagnostics_workspace()
                end,
                desc = "Workspace Diagnostics",
            },
            {
                "<leader>sg",
                function()
                    require("fzf-lua").live_grep({
                        root = true,
                        cwd = IS.root() or vim.uv.cwd(),
                    })
                end,
                desc = "Grep (Root Dir)",
            },
            {
                "<leader>sG",
                function()
                    require("fzf-lua").live_grep({
                        root = false,
                    })
                end,
                desc = "Grep (cwd)",
            },
            {
                "<leader>sh",
                function()
                    require("fzf-lua").help_tags()
                end,
                desc = "Help Pages",
            },
            {
                "<leader>sH",
                function()
                    require("fzf-lua").highlights()
                end,
                desc = "Search Highlight Groups",
            },
            {
                "<leader>sj",
                function()
                    require("fzf-lua").jumps()
                end,
                desc = "Jumplist",
            },
            {
                "<leader>sk",
                function()
                    require("fzf-lua").keymaps()
                end,
                desc = "Key Maps",
            },
            {
                "<leader>sl",
                function()
                    require("fzf-lua").loclist()
                end,
                desc = "Location List",
            },
            {
                "<leader>sM",
                function()
                    require("fzf-lua").man_pages()
                end,
                desc = "Man Pages",
            },
            {
                "<leader>sm",
                function()
                    require("fzf-lua").marks()
                end,
                desc = "Jump to Mark",
            },
            {
                "<leader>sR",
                function()
                    require("fzf-lua").resume()
                end,
                desc = "Resume",
            },
            {
                "<leader>sq",
                function()
                    require("fzf-lua").quickfix()
                end,
                desc = "Quickfix List",
            },
            {
                "<leader>sw",
                function()
                    require("fzf-lua").grep_cword({
                        root = true,
                        cwd = IS.root() or vim.uv.cwd(),
                    })
                end,
                desc = "Word (Root Dir)",
            },
            {
                "<leader>sW",
                function()
                    require("fzf-lua").grep_cword({
                        root = false,
                    })
                end,
                desc = "Word (cwd)",
            },
            {
                "<leader>sw",
                function()
                    require("fzf-lua").grep_visual({
                        root = true,
                        cwd = IS.root() or vim.uv.cwd(),
                    })
                end,
                mode = "v",
                desc = "Selection (Root Dir)",
            },
            {
                "<leader>sW",
                function()
                    require("fzf-lua").grep_visual({
                        root = false,
                    })
                end,
                mode = "v",
                desc = "Selection (cwd)",
            },
            {
                "<leader>uC",
                function()
                    require("fzf-lua").colorschemes()
                end,
                desc = "Colorscheme with Preview",
            },
            -- lsp
            {
                "<leader>sS",
                function()
                    require("fzf-lua").lsp_live_workspace_symbols({
                        regex_filter = symbols_filter,
                    })
                end,
                desc = "Goto Symbol (Workspace)",
            },
            {
                "gO",
                function()
                    require("fzf-lua").lsp_document_symbols({
                        regex_filter = symbols_filter,
                    })
                end,
            },
            {
                "gri",
                function()
                    require("fzf-lua").lsp_implementations()
                end,
            },
            {
                "grr",
                function()
                    require("fzf-lua").lsp_references()
                end,
            },
            {
                "gy",
                function()
                    require("fzf-lua").lsp_typedefs()
                end,
                desc = "Type Definition",
            },
        },
    },
}
