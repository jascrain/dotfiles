local function on_lsp_attach(client, _)
    local keys = {
        {
            "<leader>cl",
            "<cmd>LspInfo<cr>",
            desc = "LspInfo",
        },
        {
            "gd",
            vim.lsp.buf.definition,
            has = "textDocument/definition",
        },
        {
            "gr",
            vim.lsp.buf.references,
            desc = "References",
        },
        {
            "gI",
            vim.lsp.buf.implementation,
            desc = "Implementation",
        },
        {
            "gy",
            vim.lsp.buf.type_definition,
            desc = "Type Definition",
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
            "<c-k>",
            vim.lsp.buf.signature_help,
            desc = "Signature Help",
            mode = "i",
        },
        {
            "<leader>ca",
            vim.lsp.buf.code_action,
            desc = "Code Action",
            mode = { "n", "v" },
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
            LazyVim.lsp.rename_file,
            desc = "Rename File",
        },
        {
            "<leader>cr",
            vim.lsp.buf.rename,
            desc = "Rename",
        },
        {
            "<leader>cA",
            LazyVim.lsp.action.source,
            desc = "Source Action",
        },
    }

    for _, k in pairs(keys) do
        local has = true

        if k.has then
            has = client.supports_method(k.has)
        end

        if has then
            local opts = {
                desc = k.desc,
            }
            vim.keymap.set(k.mode or "n", k[1], k[2], opts)
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
        opts = {
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                },
                severity_sort = true,
            },
            inlay_hints = {
                enabled = false,
                exclude = { "vue" },
            },
            codelens = {
                enabled = false,
            },
            capabilities = {
            },
            servers = {
            },
        },
        config = function(_, opts)
            LazyVim.lsp.on_attach(on_lsp_attach)
            LazyVim.lsp.setup()

            if vim.tbl_get(opts, "inlay_hints", "enabled") then
                LazyVim.lsp.on_supports_method("textDocument/inlayHint", function(_, buffer)
                    if
                        vim.api.nvim_buf_is_valid(buffer)
                        and vim.bo[buffer].bufftype == ""
                            and not vim.tbl_contains(
                                opts.inlay_hints.exclude or {},
                                vim.bo[buffer].filetype)
                    then
                        vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
                    end
                end)
            end

            if
                vim.tbl_get(opts, "codelens", "enabled")
                and vim.lsp.codelens
            then
                LazyVim.lsp.on_supports_method(
                    "textDocument/codeLens",
                    function(client, buffer)
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
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                has_cmp and cmp_nvim_lsp.default_capabilities() or {},
                opts.capabilities or {}
            )

            local function setup(server)
                local server_opts = vim.tbl_deep_extend("force", {
                    capabilities = vim.deepcopy(capabilities),
                }, servers[server] or {})
                require("lspconfig")[server].setup(server_opts)
            end

            local have_mason, mlsp = pcall(require, "mason-lspconfig")
            if have_mason then
                mlsp.setup({ handlers = { setup } })
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
        opts = {
            ensure_installed = {
                -- "stylua",
                -- "shfmt",
            },
        },
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
        "williamboman/mason-lspconfig.nvim",
        dependencies = "mason.nvim",
        lazy = true,
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        cond = vim.fn.has("nvim-0.10.0") == 1,
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
                { path = "lazy.nvim" },
            },
        },
    },
    {
        -- Manage libuv types with lazy. Plugin will never be loaded.
        "Bilal2453/luvit-meta",
        lazy = true,
    },
    -- {
    --     "folke/trouble.nvim",
    --     cmd = "Trouble",
    --     config = true,
    -- },
}
