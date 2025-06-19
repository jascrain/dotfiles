local function setup_keymaps(client, _)
    local keys = {
        {
            "<leader>cl",
            "<cmd>LspInfo<cr>",
            desc = "LspInfo",
        },
        {
            "gd",
            "<cmd>FzfLua lsp_definitions jump1=true ignore_current_line=true<cr>",
            has = "textDocument/definition",
        },
        {
            "grr",
            "<cmd>FzfLua lsp_references jump1=true ignore_current_line=true<cr>",
            desc = "References",
            nowait = true,
        },
        {
            "gri",
            "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>",
            desc = "Goto Implementation",
        },
        {
            "gy",
            "<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>",
            desc = "Goto Type Definition",
        },
        {
            "gD",
            vim.lsp.buf.declaration,
        },
        {
            "K",
            vim.lsp.buf.hover,
        },
        {
            "gK",
            vim.lsp.buf.signature_help,
            desc = "Signature Help",
        },
        {
            "gO",
            "<cmd>FzfLua lsp_document_symbols<cr>",
            desc = "Document Symbol",
        },
        {
            "<leader>cc",
            vim.lsp.codelens.run,
            desc = "Run Codelens",
            mode = { "n", "v" },
        },
        {
            "<leader>cC",
            vim.lsp.codelens.refresh,
            desc = "Refresh Codelens",
        },
        {
            "<leader>cR",
            Snacks.rename.rename_file,
            desc = "Rename File",
        },
        {
            "<leader>cA",
            LazyVim.lsp.action.source,
            desc = "Source Action",
        },
        {
            "]]",
            function()
                Snacks.words.jump(vim.v.count1)
            end,
            desc = "Next Reference",
            has = "textDocument/documentHighlight",
            cond = function()
                return Snacks.words.is_enabled()
            end,
        },
        {
            "[[",
            function()
                Snacks.words.jump(-vim.v.count1)
            end,
            desc = "Prev Reference",
            has = "textDocument/documentHighlight",
            cond = function()
                return Snacks.words.is_enabled()
            end,
        },
        {
            "<a-n>",
            function()
                Snacks.words.jump(vim.v.count1, true)
            end,
            desc = "Next Reference",
            has = "textDocument/documentHighlight",
            cond = function()
                return Snacks.words.is_enabled()
            end,
        },
        {
            "<a-p>",
            function()
                Snacks.words.jump(-vim.v.count1, true)
            end,
            desc = "Prev Reference",
            has = "textDocument/documentHighlight",
            cond = function()
                return Snacks.words.is_enabled()
            end,
        },
    }

    for _, k in pairs(keys) do
        if
            (not k.cond or k.cond())
            and (not k.has or client:supports_method(k.has))
        then
            vim.keymap.set(k.mode or "n", k[1], k[2], {
                desc = k.desc,
            })
        end
    end
end

return {
    {
        "neovim/nvim-lspconfig",
        event = "LazyFile",
        dependencies = {
            "mason.nvim",
            "mason-lspconfig.nvim",
        },
        ---@class PluginLspOpts
        opts = {
            inlay_hints = {
                enabled = false,
                exclude = { "vue" },
            },
            codelens = {
                enabled = false,
            },
            document_highlight = {
                enabled = true,
            },
            capabilities = {},
            servers = {},
            setup = {},
        },
        ---@param opts PluginLspOpts
        config = function(_, opts)
            LazyVim.lsp.on_attach(setup_keymaps)
            LazyVim.lsp.setup()
            LazyVim.lsp.on_dynamic_capability(setup_keymaps)

            -- inlay hints
            if vim.tbl_get(opts, "inlay_hints", "enabled") then
                LazyVim.lsp.on_supports_method(
                    "textDocument/inlayHint",
                    function(_, buffer)
                        if
                            vim.api.nvim_buf_is_valid(buffer)
                            and vim.bo[buffer].buftype == ""
                            and not vim.tbl_contains(
                                opts.inlay_hints.exclude or {},
                                vim.bo[buffer].filetype
                            )
                        then
                            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
                        end
                    end
                )
            end

            -- code lens
            if
                vim.tbl_get(opts, "codelens", "enabled")
                and vim.lsp.codelens
            then
                LazyVim.lsp.on_supports_method(
                    "textDocument/codeLens",
                    function(_, buffer)
                        vim.lsp.codelens.refresh()
                        vim.api.nvim_create_autocmd(
                            { "BufEnter", "CursorHold", "InsertLeave" },
                            {
                                buffer = buffer,
                                callback = vim.lsp.codelens.refresh,
                            }
                        )
                    end
                )
            end

            local servers = (opts and opts.servers) or {}
            local has_blink, blink = pcall(require, "blink.cmp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                has_blink and blink.get_lsp_capabilities() or {},
                opts.capabilities or {}
            )

            local function setup(server)
                local server_opts = vim.tbl_deep_extend("force", {
                    capabilities = vim.deepcopy(capabilities),
                }, servers[server] or {})
                if server_opts.enabled == false then
                    return
                end

                if opts and opts.setup then
                    if opts.setup[server] then
                        if opts.setup[server](server, server_opts) then
                            return
                        end
                    elseif opts.setup["*"] then
                        if opts.setup["*"](server, server_opts) then
                            return
                        end
                    end
                end
                require("lspconfig")[server].setup(server_opts)
            end

            -- get all the servers that are available through mason-lspconfig
            local have_mason, mlsp = pcall(require, "mason-lspconfig")
            local all_mslp_servers = {}
            if have_mason then
                all_mslp_servers = vim.tbl_keys(
                    require("mason-lspconfig.mappings.server").lspconfig_to_package
                )
            end

            local ensure_installed = {} ---@type string[]
            for server, server_opts in pairs(servers) do
                if server_opts then
                    server_opts = server_opts == true and {} or server_opts
                    if server_opts.enabled ~= false then
                        -- run manual setup if mason=false or if this is a
                        -- server that cannot be installed with mason-lspconfig
                        if
                            server_opts.mason == false
                            or not vim.tbl_contains(all_mslp_servers, server)
                        then
                            setup(server)
                        else
                            ensure_installed[#ensure_installed + 1] = server
                        end
                    end
                end
            end

            if have_mason then
                mlsp.setup({
                    ensure_installed = vim.tbl_deep_extend(
                        "force",
                        ensure_installed,
                        LazyVim.opts("mason-lspconfig.nvim").ensure_installed
                            or {}
                    ),
                    automatic_installation = false,
                    handlers = { setup },
                })
            end
        end,
    },
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = {
            { "<leader>cm", "<Cmd>Mason<CR>", desc = "Mason" },
        },
        build = ":MasonUpdate",
        opts_extend = { "ensure_installed" },
        opts = {
            ensure_installed = {},
        },
        ---@param opts MasonSettings | {ensure_installed: string[]}
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require("mason-registry")
            mr:on("package:install:success", function()
                vim.defer_fn(function()
                    -- trigger FileType event to possibly load this newly
                    -- installed LSP server
                    require("lazy.core.handler.event").trigger({
                        event = "FileType",
                        buf = vim.api.nvim_get_current_buf(),
                    })
                end, 100)
            end)

            mr.refresh(function()
                local ensure_installed = opts and opts.ensure_installed
                for _, tool in ipairs(ensure_installed) do
                    local p = mr.get_package(tool)
                    if not p:is_installed() then
                        p:install()
                    end
                end
            end)
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = "mason.nvim",
        lazy = true,
        config = function() end,
        version = "^1.0.0",
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "LazyVim", words = { "LazyVim" } },
                { path = "snacks.nvim", words = { "Snacks" } },
                { path = "lazy.nvim", words = { "LazyVim" } },
            },
        },
    },
}
