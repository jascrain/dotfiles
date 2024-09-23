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

return M
