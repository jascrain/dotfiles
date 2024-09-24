local M = {}

function M.on_attach(on_attach, name)
    return vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local buffer = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and (not name or client.name == name) then
                return on_attach(client, buffer)
            end
        end,
    })
end

M._supports_method = {}

function M.setup()
    local register_capability = vim.lsp.handlers["client/registerCapability"]
    vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        local ret = register_capability(err, res, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
            for buffer in pairs(client.attached_buffers) do
                vim.api.nvim_exec_autocmds("User", {
                    pattern = "LspDynamicCapability",
                    data = { client_id = client.id, buffer = buffer },
                })
            end
        end
        return ret
    end
    M.on_attach(M._check_methods)
    M.on_dynamic_capability(M._check_methods)
end

function M._check_methods(client, buffer)
    -- don't trigger on invalid buffers
    if not vim.api.nvim_buf_is_valid(buffer) then
        return
    end
    -- don't trigger on non-listed buffers
    if not vim.bo[buffer].buflisted then
        return
    end
    -- don't trigger on nofile buffers
    if vim.bo[buffer].buftype == "nofile" then
        return
    end
    for method, clients in pairs(M._supports_method) do
        clients[client] = clients[client] or {}
        if not clients[client][buffer] then
            if client.supports_method then
                if client.supports_method(method, { bufnr = buffer }) then
                    clients[client][buffer] = true
                    vim.api.nvim_exec_autocmds("User", {
                        pattern = "LspSupportsMethod",
                        data = {
                            client_id = client.id,
                            buffer = buffer,
                            method = method
                        },
                    })
                end
            end
        end
    end
end

function M.on_dynamic_capability(fn, opts)
    return vim.api.nvim_create_autocmd("User", {
        pattern = "LspDynamicCapability",
        group = opts and opts.group or nil,
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            local buffer = args.data.buffer
            if client then
                return fn(client, buffer)
            end
        end,
    })
end

function M.on_supports_method(method, fn)
    M._supports_method[method] = (
        M._supports_method[method] or
        setmetatable({}, { __mode = "k" })
    )
    return vim.api.nvim_create_autocmd("User", {
        pattern = "LspSupportsMethod",
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            local buffer = args.data.buffer
            if client and method == args.data.method then
                return fn(client, buffer)
            end
        end,
    })
end

function M.rename_file()
    local buf = vim.api.nvim_get_current_buf()
    local old = assert(
        LazyVim.root.realpath(vim.api.nvim_buf_get_name(buf))
    )
    local root = assert(
        LazyVim.root.realpath(LazyVim.root.get({ normalize = true }))
    )
    assert(old:find(root, 1, true) == 1, "File not in project root")

    local extra = old:sub(#root + 2)

    vim.ui.input(
        {
            prompt = "New File Name: ",
            default = extra,
            completion = "file",
        },
        function(new)
            if not new or new == "" or new == extra then
                return
            end
            new = LazyVim.norm(root .. "/" .. new)
            vim.fn.mkdir(vim.fs.dirname(new), "p")
            M.on_rename(old, new, function()
                vim.fn.rename(old, new)
                vim.cmd.edit(new)
                vim.api.nvim_buf_delete(buf, { force = true })
                vim.fn.delete(old)
            end)
        end
    )
end

function M.on_rename(from, to, rename)
    local changes = {
        files = {
            {
                oldUri = vim.uri_from_fname(from),
                newUri = vim.uri_from_fname(to),
            }
        }
    }

    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
        if client.supports_method("workspace/willRenameFiles") then
            local resp = client.request_sync(
                "workspace/willRenameFiles",
                changes,
                1000,
                0
            )
            if resp and resp.result ~= nil then
                vim.lsp.util.apply_workspace_edit(
                    resp.result,
                    client.offset_encoding
                )
            end
        end
    end

    if rename then
        rename()
    end

    for _, client in ipairs(clients) do
        if client.supports_method("workspace/didRenameFiles") then
            client.notify("workspace/didRenameFiles", changes)
        end
    end
end

M.action = setmetatable({}, {
    __index = function(_, action)
        return function()
            vim.lsp.buf.code_action({
                apply = true,
                context = {
                    only = { action },
                    diagnostics = {},
                },
            })
        end
    end,
})

return M
