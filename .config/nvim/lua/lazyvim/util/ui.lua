local M = {}

function M.fg(name)
    local color = M.color(name)
    return color and { fg = color } or nil
end

function M.color(name, bg)
    local hl = (
        vim.api.nvim_get_hl
        and vim.api.nvim_get_hl(0, { name = name, link = false })
    )
    local color = nil
    if hl then
        if bg then
            color = hl.bg
        else
            color = hl.fg
        end
    end
    return color and string.format("#%06x", color) or nil
end

M.skip_foldexpr = {}
local skip_check = assert(vim.uv.new_check())

function M.foldexpr()
    local buf = vim.api.nvim_get_current_buf()

    if M.skip_foldexpr[buf] then
        return "0"
    end

    if vim.bo[buf].buftype ~= "" then
        return "0"
    end

    if vim.bo[buf].filetype == "" then
        return "0"
    end

    local ok = pcall(vim.treesitter.get_parser, buf)

    if ok then
        return vim.treesitter.foldexpr()
    end

    -- no parser available, so mark it as skip
    -- in the next tick, all skip marks will be reset
    M.skip_foldexpr[buf] = true
    skip_check:start(function()
        M.skip_foldexpr = {}
        skip_check:stop()
    end)
    return "0"
end

return M
