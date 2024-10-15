local M = {}

_G.IS = M

function M.pretty_path()
    local opts = {
        unnamed = "[No Name]",
        length = 3,
    }
    local sep = package.config:sub(1, 1)

    return function()
        local path
        local parts

        if #vim.bo.buftype > 0 then
            path = vim.fn.expand("%:t")
            if #path == 0 then
                return opts.unnamed
            end
            return path
        end

        path = vim.api.nvim_buf_get_name(0)
        if path == "" then
            return opts.unnamed
        end

        local root = M.root()
        local cwd = vim.uv.cwd()
        local homedir = vim.uv.os_homedir()
        if
            root and #root > 1 and path:find(root, 1, true) == 1
            and not (homedir and root:find(homedir, 1, true) ~= 1
                and path:find(homedir, 1, true) == 1)
        then
            path = path:sub(#root + 2)
        elseif
            cwd and #cwd > 1 and path:find(cwd, 1, true) == 1
            and not (homedir and cwd:find(homedir, 1, true) ~= 1
                and path:find(homedir, 1, true) == 1)
        then
            path = path:sub(#cwd + 2)
        elseif
            homedir and path:find(homedir, 1, true) == 1
        then
            path = vim.fs.joinpath("~", path:sub(#homedir + 2))
        end

        parts = vim.split(path, "[\\/]")
        if parts[#parts] == "" then
            -- allow the last part to end with `sep` for netrw, without
            -- counting against limit
            table.remove(parts)
            parts[#parts] = parts[#parts] .. sep
        end

        if (parts[1] == "~" or parts[1] == "") and #parts > 1 then
            -- allow extra leading item if path starts with ~ or `sep`
            parts[2] = parts[1] .. sep .. parts[2]
            table.remove(parts, 1)
        end

        if opts.length > 0 and #parts > opts.length then
            local parts_trunc = {
                parts[1],
                "…",
            }
            vim.list_extend(
                parts_trunc,
                parts,
                #parts - opts.length + 2,
                #parts)
            parts = parts_trunc
        end

        if vim.bo.modified then
            parts[#parts] = parts[#parts] .. " [+]"
        end

        if vim.bo.readonly or not vim.bo.modifiable then
            parts[#parts] = parts[#parts] .. " [-]"
        end

        return table.concat(parts, sep)
    end
end

function M.project_name()
    local function get()
        if vim.b.project_name then
            return vim.b.project_name
        end

        local bname = vim.api.nvim_buf_get_name(0)
        if not bname or #bname == 0 then
            vim.b.project_name = ""
            return ""
        end

        local name = M.root()
        if name and #name > 0 then
            name = vim.fs.basename(name)
        end

        name = name or ""
        vim.b.project_name = name
        return name
    end

    return {
        function()
            local name = get()
            if name and #name > 0 then
                return "󱉭 " .. name
            end
            return ""
        end,
        cond = function()
            local name = get()
            return name and #name > 0
        end,
        color = LazyVim.ui.fg("Special"),
    }
end

local root_cache = {}

function M.root()
    local buf = vim.api.nvim_get_current_buf()
    local ret = root_cache[buf]
    if ret then return ret end

    if #vim.bo.buftype > 0 then
        return nil
    end

    local path

    for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
        if client.root_dir then
            path = client.root_dir
            break
        end
    end

    if not path then
        local bname = vim.api.nvim_buf_get_name(buf)
        path = vim.fs.root(bname, {
            ".git",
            "lua",
        })
    end

    path = path or ""
    root_cache[buf] = path
    return path
end

return M
