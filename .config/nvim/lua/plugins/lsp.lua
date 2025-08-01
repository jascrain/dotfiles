local function setup_keymaps(ev)
    vim.keymap.set("n", "gd", function()
        require("fzf-lua").lsp_definitions()
    end)
    vim.keymap.set("n", "gD", function()
        require("fzf-lua").lsp_declarations()
    end)

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "pyright" then
        -- filter out pyright's not accessed messages
        vim.lsp.handlers["textDocument/publishDiagnostics"] = function(
            _,
            params,
            ctx
        )
            local diagnostics = {}
            for _, diag in ipairs(params.diagnostics) do
                if
                    diag.severity ~= 4
                    or diag.code ~= nil
                    or not string.match(diag.message, '"_.+" is not accessed')
                then
                    diagnostics[#diagnostics + 1] = diag
                end
            end
            params.diagnostics = diagnostics
            vim.lsp.diagnostic.on_publish_diagnostics(_, params, ctx)
        end
    end
end

return {
    {
        "neovim/nvim-lspconfig",
        event = "LazyFile",
        cmd = {
            "LspInfo",
            "LspRestart",
            "LspStart",
            "LspStop",
        },
        keys = {
            {
                "<leader>cl",
                "<cmd>LspInfo<cr>",
                desc = "Lsp Info",
            },
        },
        config = function()
            vim.api.nvim_create_autocmd(
                "LspAttach",
                { callback = setup_keymaps }
            )
            vim.lsp.config("clangd", {
                root_markers = {
                    {
                        ".git",
                        "build.ninja",
                        "compile_commands.json",
                        "compile_flags.txt",
                        "configure.ac",
                        "configure.in",
                    },
                },
            })
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            disable = { "missing-fields" },
                        },
                    },
                },
            })
        end,
    },
    {
        "williamboman/mason.nvim",
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonLog",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonUpdate",
        },
        keys = {
            { "<leader>cm", "<Cmd>Mason<CR>", desc = "Mason" },
        },
        opts = {},
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        cmd = {
            "LspInstall",
            "LspUninstall",
        },
        event = "LazyFile",
        opts = {},
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
