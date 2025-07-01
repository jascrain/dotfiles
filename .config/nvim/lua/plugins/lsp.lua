local function setup_keymaps()
    vim.keymap.set("n", "gd", function()
        require("fzf-lua").lsp_definitions()
    end)
    vim.keymap.set("n", "gD", function()
        require("fzf-lua").lsp_declarations()
    end)
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
