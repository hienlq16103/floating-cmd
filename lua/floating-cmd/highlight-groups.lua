local M = { }

M.hl_groups = {
  normal = "FloatingCmdNormal",
  search = "FloatingCmdSearch",
  lua = "FloatingCmdLua"
}

function M.setup()
  vim.api.nvim_set_hl(0, M.hl_groups.normal, { fg = "#5cc6c8" })
  vim.api.nvim_set_hl(0, M.hl_groups.search, { fg = "#dbc074" })
  vim.api.nvim_set_hl(0, M.hl_groups.lua, { fg = "#719cd6" })
end

return M
