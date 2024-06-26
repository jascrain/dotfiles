return {
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-web-devicons",
        event = "VeryLazy",
        keys = {
            { "<M-h>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
            { "<M-l>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
        },
        opts = {
            options = {
                always_show_bufferline = false,
                mode = "tabs",
            },
        },
    },
}
