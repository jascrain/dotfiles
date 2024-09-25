local M = {}

function M.snippet_replace(snippet, fn)
    return snippet:gsub("%$%b{}", function(m)
        local n, name = m:match("^%${(%d+):(.+)}$")
        return n and fn({ n = n, text = name }) or m
    end) or snippet
end

function M.snippet_preview(snippet)
    local ok, parsed = pcall(function()
        return vim.lsp._snippet_grammar.parse(snippet)
    end)
    return ok and tostring(parsed)
        or M.snippet_replace(snippet, function(placeholder)
            return M.snippet_preview(placeholder.text)
        end):gsub("%$0", "")
end

function M.add_missing_snippet_docs(window)
    local cmp = require("cmp")
    local kind = cmp.lsp.CompletionItemKind
    local entries = window:get_entries()
    for _, entry in ipairs(entries) do
        if entry:get_kind() == kind.Snippet then
            local item = entry:get_completion_item()
            if not item.documentation and item.insertText then
                item.documentation = {
                    kind = cmp.lsp.MarkupKind.Markdown,
                    value = string.format(
                        "```%s\n%s\n```",
                        vim.bo.filetype,
                        M.snippet_preview(item.insertText)
                    )
                }
            end
        end
    end
end

function M.visible()
    local cmp = package.loaded["cmp"]
    return cmp and cmp.core.view:visible()
end

return M
