local api = vim.api

local M = {}

function M.setup(otps)
  api.nvim_create_user_command("OpenFloatingCmd", M.open, {})
  api.nvim_create_user_command("CloseFloatingCmd", M.close, {})
end

function M.open()
  local buf = api.nvim_create_buf(false, true)
  local ui = api.nvim_list_uis()[1]

  local width = 120
  local height = 1

  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  M.win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = 120,
    height = 1,
    row = row,
    col = col,
    zindex = 250,
    style = 'minimal',
    border = "rounded",
  })
end

function M.close()
  if api.nvim_win_is_valid(M.win) then
    api.nvim_win_close(M.win, true)
  end
end

return M
