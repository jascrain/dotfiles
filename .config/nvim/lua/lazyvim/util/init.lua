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
