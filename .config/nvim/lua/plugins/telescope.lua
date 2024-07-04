local function fzf_build_cmd()
    if vim.fn.executable("cmake") == 1 then
        return "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && \z
            cmake --build build --config Release"
    elseif vim.fn.executable("make") == 1 then
        return "make"
    else
        return nil
    end
end

local function twrap(command, opts)
    return function()
        require("telescope.builtin")[command](opts)
    end
end

return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "plenary.nvim",
            "telescope-fzf-native.nvim",
        },
        cmd = "Telescope",
        keys = {
            {
                "<leader>,",
                twrap("buffers", { sort_mru = true, sort_lastused = true }),
                desc = "Switch Buffer",
            },
            {
                "<leader>/",
                twrap("live_grep"),
                desc = "Grep (Root Dir)",
            },
            {
                "<leader>:",
                twrap("command_history"),
                desc = "Command History",
            },
            {
                "<leader> ",
                twrap("find_files"),
                desc = "Find Files (Root Dir)",
            },
            -- find
            {
                "<leader>fb",
                twrap("buffers", { sort_mru = true, sort_lastused = true }),
                desc = "Buffers",
            },
            {
                "<leader>ff",
                twrap("find_files"),
                desc = "Find Files (Root Dir)",
            },
            {
                "<leader>fF",
                twrap("find_files", { root = false }),
                desc = "Find Files (cwd)",
            },
            {
                "<leader>fg",
                twrap("git_files"),
                desc = "Find Files (git)",
            },
            {
                "<leader>fr",
                twrap("oldfiles"),
                desc = "Recent",
            },
            {
                "<leader>fR",
                twrap("oldfiles", { cwd = vim.uv.cwd() }),
                desc = "Recent (cwd)",
            },
            -- git
            {
                "<leader>gc",
                twrap("git_commits"),
                desc = "Commits",
            },
            {
                "<leader>gs",
                twrap("git_status"),
                desc = "Status",
            },
            -- search
            {
                '<leader>s"',
                twrap("registers"),
                desc = "Registers",
            },
            {
                "<leader>sa",
                twrap("autocommands"),
                desc = "Auto Commands",
            },
            {
                "<leader>sb",
                twrap("current_buffer_fuzzy_find"),
                desc = "Buffer",
            },
            {
                "<leader>sB",
                twrap("builtin"),
                desc = "Telescope Builtins",
            },
            {
                "<leader>sc",
                twrap("command_history"),
                desc = "Command History",
            },
            {
                "<leader>sC",
                twrap("commands"),
                desc = "Commands",
            },
            {
                "<leader>sd",
                twrap("diagnostics", { bufnr = 0 }),
                desc = "Document Diagnostics",
            },
            {
                "<leader>sD",
                twrap("diagnostics"),
                desc = "Workspace Diagnostics",
            },
            {
                "<leader>sg",
                twrap("live_grep"),
                desc = "Grep (Root Dir)",
            },
            {
                "<leader>sG",
                twrap("live_grep", { root = false }),
                desc = "Grep (cwd)",
            },
            {
                "<leader>sh",
                twrap("help_tags"),
                desc = "Help Pages",
            },
            {
                "<leader>sH",
                twrap("highlights"),
                desc = "Search Highlight Groups",
            },
            {
                "<leader>sj",
                twrap("jumplist"),
                desc = "Jumplists",
            },
            {
                "<leader>sk",
                twrap("keymaps"),
                desc = "Key Maps",
            },
            {
                "<leader>sl",
                twrap("loclist"),
                desc = "Location List",
            },
            {
                "<leader>sM",
                twrap("man_pages"),
                desc = "Man Pages",
            },
            {
                "<leader>sm",
                twrap("marks"),
                desc = "Jump to Mark",
            },
            {
                "<leader>so",
                twrap("vim_options"),
                desc = "Options",
            },
            {
                "<leader>sq",
                twrap("quickfix"),
                desc = "Quickfix List",
            },
            {
                "<leader>sR",
                twrap("resume"),
                desc = "Resume",
            },
            {
                "<leader>sw",
                twrap("grep_string", { word_match = "-w" }),
                desc = "Word (Root Dir)",
            },
            {
                "<leader>sW",
                twrap("grep_string", { word_match = "-w", root = false }),
                desc = "Word (cwd)",
            },
            {
                "<leader>sw",
                twrap("grep_string"),
                mode = "v",
                desc = "Selection (Root Dir)",
            },
            {
                "<leader>sW",
                twrap("grep_string", { root = false }),
                mode = "v",
                desc = "Selection (cwd)",
            },
            {
                "<leader>uC",
                twrap("colorscheme", { enable_preview = true }),
                desc = "Colorscheme with Preview",
            },
        },
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        lazy = true,
        build = fzf_build_cmd(),
        cond = function()
            if not (vim.fn.executable("make") == 1 or
                    vim.fn.executable("cmake") == 1) then
                return false
            end

            if not (vim.fn.executable("gcc") == 1 or
                    vim.fn.executable("clang") == 1) then
                return false
            end

            return true
        end,
        config = function(plugin)
            LazyVim = require("lazyvim")
            LazyVim.on_load("telescope.nvim", function()
                local lib = plugin.dir .. "/build/libfzf." .. (LazyVim.is_win() and "dll" or "so")
                if not vim.uv.fs_stat(lib) then
                    print("Rebuilding telescope-fzf-native")
                    require("lazy").build({ plugins = { plugin }, show = false }):wait()
                end
                local ok, err = pcall(require("telescope").load_extension, "fzf")
                if not ok then
                    print("Could not build telescope-fzf-native: " .. err)
                end
            end)
        end,
    },
}
