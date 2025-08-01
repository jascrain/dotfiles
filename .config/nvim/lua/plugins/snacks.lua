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
            scroll = { enabled = false },
            statuscolumn = { enabled = true },
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
            {
                "<leader>gb",
                function()
                    Snacks.git.blame_line()
                end,
                desc = "Git Blame Line",
            },
            {
                "<leader>dps",
                function()
                    Snacks.profiler.scratch()
                end,
                desc = "Profiler Scratch Buffer",
            },
            {
                "<leader>cR",
                function()
                    Snacks.rename.rename_file()
                end,
                desc = "Rename File",
            },
            {
                "<a-n>",
                function()
                    Snacks.words.jump(vim.v.count1, true)
                end,
                desc = "Next Reference",
            },
            {
                "<a-p>",
                function()
                    Snacks.words.jump(-vim.v.count1, true)
                end,
                desc = "Previous Reference",
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
            Snacks.toggle.zoom():map("<leader>uZ")
            Snacks.toggle.zen():map("<leader>uz")
        end,
    },
}
