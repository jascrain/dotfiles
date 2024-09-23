local M = {}

function M.format(component, text, hl_group)
    text = text:gsub("%%", "%%%%")
    if not hl_group or hl_group == "" then
        return text
    end
    component.hl_cache = component.hl_cache or {}
    local lualine_hl_group = component.hl_cache[hl_group]
    if not lualine_hl_group then
        local utils = require("lualine.utils.utils")
        local gui = vim.tbl_filter(function(x)
            return x
        end, {
            utils.extract_highlight_colors(hl_group, "bold") and "bold",
            utils.extract_highlight_colors(hl_group, "italic") and "italic",
        })

        lualine_hl_group = component:create_hl({
            fg = utils.extract_highlight_colors(hl_group, "fg"),
            gui = #gui > 0 and table.concat(gui, ",") or nil,
        }, "LV_" .. hl_group)
        component.hl_cache[hl_group] = lualine_hl_group
    end
    return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
end

function M.pretty_path(opts)
    opts = vim.tbl_extend("force", {
        relative = "cwd",
        directory_hl = "",
        modified_sign = "",
        readonly_icon = "󰌾",
        unnamed = "[No Name]",
        length = 3,
    }, opts or {})

    return function(self)
        local sep = package.config:sub(1, 1)
        local path
        local parts

        if vim.bo.filetype == "help" then
            path = vim.fn.expand("%:t")
        else
            path = vim.fn.expand("%:p")
            local root = LazyVim.root.get({ normalize = true })
            local cwd = LazyVim.root.cwd()
            if opts.relative == "cwd" and path:find(cwd, 1, true) == 1 then
                path = path:sub(#cwd + 2)
            else
                path = path:sub(#root + 2)
            end
        end

        if path == "" then
            parts = { opts.unnamed }
        else
            parts = vim.split(path, "[\\/]")
        end

        if opts.length == 0 then
            parts = parts
        elseif #parts > opts.length then
            parts = {
                parts[1],
                "…",
                table.concat(
                    { unpack(parts, #parts - opts.length + 2, #parts) },
                    sep
                )
            }
        end

        if vim.bo.modified then
            parts[#parts] = M.format(self, parts[#parts], opts.modified_hl)
            if #opts.modified_sign > 0 then
                parts[#parts] = parts[#parts] .. " " .. opts.modified_sign
            end
        end

        local dir = ""
        if #parts > 1 then
            dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
            dir = M.format(self, dir .. sep, opts.directory_hl)
        end

        if vim.bo.readonly or not vim.bo.modifiable then
            if #opts.readonly_icon > 0 then
                parts[#parts] = parts[#parts] .. " " .. opts.readonly_icon
            end
        end
        return dir .. parts[#parts]
    end
end

M.root_dir = function(opts)
    opts = vim.tbl_extend("force", {
        cwd = false,
        subdirectory = true,
        parent = true,
        other = true,
        icon = "󱉭",
        color = LazyVim.ui.fg("Special"),
    }, opts or {})

    local function get()
        local cwd = LazyVim.root.cwd()
        local root = LazyVim.root.get({ normalize = true })
        local name = vim.fs.basename(root)

        if root == cwd then
            return opts.cwd and name
        elseif root:find(cwd, 1, true) == 1 then
            return opts.subdirectory and name
        elseif cwd:find(root, 1, true) == 1 then
            return opts.parent and name
        else
            return opts.other and name
        end
    end

    return {
        function()
            return (opts.icon and opts.icon .. " ") .. get()
        end,
        cond = function()
            return type(get()) == "string"
        end,
        color = opts.color,
    }
end

return M
