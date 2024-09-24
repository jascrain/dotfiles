_G.LazyVim = require("lazyvim.util")

local M = {}

LazyVim.config = M

M.icons = {
    diagnostics = {
      Error = "",
      Warn  = "",
      Hint  = "",
      Info  = "",
    },
    git = {
      added    = "",
      modified = "",
      removed  = "",
    },
    kinds = {
      Array         = "",
      Boolean       = "󰨙",
      Class         = "",
      Codeium       = "󰘦",
      Color         = "",
      Control       = "",
      Collapsed     = "",
      Constant      = "󰏿",
      Constructor   = "",
      Copilot       = "",
      Enum          = "",
      EnumMember    = "",
      Event         = "",
      Field         = "",
      File          = "",
      Folder        = "",
      Function      = "󰊕",
      Interface     = "",
      Key           = "",
      Keyword       = "",
      Method        = "󰊕",
      Module        = "",
      Namespace     = "󰦮",
      Null          = "",
      Number        = "󰎠",
      Object        = "",
      Operator      = "",
      Package       = "",
      Property      = "",
      Reference     = "",
      Snippet       = "",
      String        = "",
      Struct        = "󰆼",
      TabNine       = "󰏚",
      Text          = "",
      TypeParameter = "",
      Unit          = "",
      Value         = "",
      Variable      = "󰀫",
    },
}

function M.setup(_)
    local group = vim.api.nvim_create_augroup("LazyVim", { clear = true })
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "VeryLazy",
        callback = function()
            vim.api.nvim_create_user_command("LazyHealth", function()
                vim.cmd([[Lazy! load all]])
                vim.cmd([[checkhealth]])
            end, { desc = "Load all plugins and run :checkhealth" })
        end,
    })

    LazyVim.plugin.setup()
end

return M
