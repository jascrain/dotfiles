local LazyUtil = require("lazy.core.util")

local M = {}

setmetatable(M, {
    __index = function(t, k)
        if LazyUtil[k] then
            return LazyUtil[k]
        end
        t[k] = require("lazyvim.util." .. k)
        return t[k]
    end,
})

local lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }

local function lazy_file()
    -- This autocmd will only trigger when a file was loaded from the cmdline.
    -- It will render the file as quickly as possible.
    vim.api.nvim_create_autocmd("BufReadPost", {
        once = true,
        callback = function(event)
            -- Skip if we already entered vim
            if vim.v.vim_did_enter == 1 then
                return
            end

            -- Try to guess the filetype (may change later on during Neovim
            -- startup)
            local ft = vim.filetype.match({ buf = event.buf })
            if ft then
                -- Add treesitter highlights and fallback to syntax
                local lang = vim.treesitter.language.get_lang(ft)
                if not (lang and pcall(vim.treesitter.start, event.buf, lang)) then
                    vim.bo[event.buf].syntax = ft
                end

                -- Trigger early redraw
                vim.cmd([[redraw]])
            end
        end,
    })

    -- Add support for the LazyFile event
    local Event = require("lazy.core.handler.event")

    Event.mappings.LazyFile = { id = "LazyFile", event = lazy_file_events }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile
end


function M.setup(opts)
    require("lazyvim.config").setup(opts)
    lazy_file()
end

function M.is_win()
    return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

function M.get_plugin(name)
    return require("lazy.core.config").spec.plugins[name]
end

function M.has(plugin)
    return M.get_plugin(plugin) ~= nil
end

function M.opts(name)
    local plugin = M.get_plugin(name)
    if not plugin then
        return {}
    end
    local Plugin = require("lazy.core.plugin")
    return Plugin.values(plugin, "opts", false)
end

function M.is_loaded(name)
    local Config = require("lazy.core.config")
    return Config.plugins[name] and Config.plugins[name]._.loaded
end

function M.on_load(name, fn)
    if M.is_loaded(name) then
        fn(name)
    else
        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyLoad",
            callback = function(event)
                if event.data == name then
                    fn(name)
                    return true
                end
            end,
        })
    end
end


return M
