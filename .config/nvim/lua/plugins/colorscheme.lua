return {
    {
        "gruvbox-community/gruvbox",
        lazy = false,
        config = function()
            vim.g.gruvbox_italic = 1
            vim.g.gruvbox_contrast_dark = "hard"
            vim.g.gruvbox_colors = { dark0_hard = { "#000000", 0 } }
        end,
    },
    {
        "navarasu/onedark.nvim",
        lazy = true,
        opts = {
            style = "darker",
        },
        config = function(_, opts)
            require("onedark").setup(opts)
            require("onedark").load()
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = true,
    },
}
