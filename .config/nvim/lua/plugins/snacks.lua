return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            indent = {
                enabled = true,
                animate = { enabled = false },
            },
            input = { enabled = true },
            notifier = { enabled = true },
            scope = { enabled = true },
            statuscolumn = { enabled = false },
            words = { enabled = true },
        },
        keys = {
            {
                "<leader>n",
                function()
                    Snacks.notifier.show_history()
                end,
                desc = "Notification History",
            },
            {
                "<leader>un",
                function()
                    Snacks.notifier.hide()
                end,
                desc = "Dismiss All Notifications",
            },
            {
                "<leader>.",
                function()
                    Snacks.scratch()
                end,
                desc = "Toggle Scratch Buffer",
            },
            {
                "<leader>S",
                function()
                    Snacks.scratch.select()
                end,
                desc = "Select Scratch Buffer",
            },
        },
        config = function(_, opts)
            local notify = vim.notify
            require("snacks").setup(opts)
            -- HACK: restore vim.notify after snacks setup and let noice.nvim
            -- take over this is needed to have early notifications show up
            -- in noice history
            if LazyVim.has("noice.nvim") then
                vim.notify = notify
            end
        end,
    },
}
