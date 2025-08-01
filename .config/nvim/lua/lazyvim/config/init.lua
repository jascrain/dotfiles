_G.LazyVim = require("lazyvim.util")

---@class LazyVimConfig: LazyVimOptions
local M = {}

LazyVim.config = M

---@class LazyVimOptions
local defaults = {
  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = "",
    },
    dap = {
      Stopped             = { "󰁕", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint          = "",
      BreakpointCondition = "",
      BreakpointRejected  = { "", "DiagnosticError" },
      LogPoint            = ".>",
    },
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
      Snippet       = "󱄽",
      String        = "",
      Struct        = "󰆼",
      Supermaven    = "",
      TabNine       = "󰏚",
      Text          = "",
      TypeParameter = "",
      Unit          = "",
      Value         = "",
      Variable      = "󰀫",
    },
  },
}

---@type LazyVimOptions
local options

---@param opts? LazyVimOptions
function M.setup(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  local group = vim.api.nvim_create_augroup("LazyVim", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      vim.api.nvim_create_user_command("LazyHealth", function()
        vim.cmd([[Lazy! load all]])
        vim.cmd([[checkhealth]])
      end, { desc = "Load all plugins and run :checkhealth" })

      local health = require("lazy.health")
      vim.list_extend(health.valid, {
        "recommended",
        "desc",
        "vscode",
      })
    end,
  })

end

M.did_init = false
function M.init()
  if M.did_init then
    return
  end
  M.did_init = true

  -- delay notifications till vim.notify was replaced or after 500ms
  LazyVim.lazy_notify()

  LazyVim.plugin.setup()
end

setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    ---@cast options LazyVimConfig
    return options[key]
  end,
})

return M
