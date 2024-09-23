local function on_lsp_attach(args, opts)
    vim.keymap.set(
        "n",
        "gd",
        vim.lsp.buf.definition)
    vim.keymap.set("n",
        "gr",
        vim.lsp.buf.references,
        { desc = "References" })
    vim.keymap.set("n",
        "gI",
        vim.lsp.buf.implementation,
        { desc = "Implementation" })
    vim.keymap.set("n",
        "gy",
        vim.lsp.buf.type_definition,
        { desc = "Type Definition" })
    vim.keymap.set("n",
        "gD",
        vim.lsp.buf.declaration)
    vim.keymap.set("n",
        "K",
        vim.lsp.buf.hover)
    vim.keymap.set(
        { "n", "v" },
        "<leader>ca",
        vim.lsp.buf.code_action,
        { desc = "Code Action" })
    vim.keymap.set(
        { "n", "v" },
        "<leader>cc",
        vim.lsp.codelens.run,
        { desc = "Codelens" })
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if
        vim.tbl_get(opts, "inlay_hints", "enabled")
        and client
        and client.supports_method("textDocument/inlayHint")
        and vim.lsp.inlay_hint -- new in neovim 0.10.0
        and not vim.tbl_contains(
            opts.inlay_hints.exclude or {},
            vim.bo[args.buf].filetype)
    then
        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    if
        vim.tbl_get(opts, "codelens", "enabled")
        and client
        and client.supports_method("textDocument/codeLens")
        and vim.lsp.codelens
    then
        vim.lsp.codelens.refresh()
        vim.api.nvim_create_autocmd(
            { "BufEnter", "CursorHold", "InsertLeave" },
            {
                buffer = args.buf,
                callback = vim.lsp.codelens.refresh,
            })
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
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    on_lsp_attach(args, opts or {})
                end,
            })

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
