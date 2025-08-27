local api = vim.api
local map = vim.keymap.set
local default_opts = require("floating-cmd.opts")

local M = {}

local win
local buf
local original_win
local namespace = api.nvim_create_namespace("FloatingCmd")

---@param bufnr integer
---@param pattern string
---@param hl_group string
local function set_mark(bufnr, pattern, hl_group)
    vim.schedule(function()
        local lines = api.nvim_buf_get_lines(bufnr, 0, 1, false)
        local text = lines[1] or ""
        local start_col, end_col = text:find(pattern)
        if start_col and end_col then
            api.nvim_buf_set_extmark(bufnr, namespace, 0, start_col - 1, {
                end_col = end_col,
                hl_group = hl_group,
            })
        end
    end)
end

function M.setup(otps)
  require("floating-cmd.highlight-groups").setup()

	map({ "n", "v" }, ":", function()
    M.open_cmd(default_opts)
	end)
  -- TODO: Implement search later.
	-- map({ "n", "v" }, "/", function()
	--    M.open_search_down(default_opts)
	-- end)
	-- map({ "n", "v" }, "?", function()
	--    M.open_search_up(default_opts)
	-- end)
end

function M.open_cmd(opts)
  original_win = api.nvim_get_current_win()

  if not M.open_floating_window(opts) then
    return
  end

  M.setup_prompt(opts.modes.cmdline)
  M.set_prompt_callback(function(input)
    vim.cmd(input)
  end)
  api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, { buffer = buf, callback = function()
    local line = api.nvim_buf_get_lines(buf, 0, 1, false)[1]
    local prompt_length = opts.modes.cmdline.prompt:len()
    line = string.sub(line, prompt_length + 1, -1)

    for _, pattern in ipairs(opts.modes.lua.pattern) do
      if string.find(line, pattern) then
        M.setup_prompt(opts.modes.lua)
        M.set_prompt_callback(function(input)
          local fn = loadstring(input)
          if fn then
            fn()
          end
        end)
        break
      end
    end
  end })
end

function M.open_search_down(opts)
  original_win = api.nvim_get_current_win()

  if not M.open_floating_window(opts) then
    return
  end

  M.setup_prompt(opts.modes.search_down)
  M.set_prompt_callback(function(input)
    vim.fn.search(input, "w")
  end)
end

function M.open_search_up(opts)
  original_win = api.nvim_get_current_win()

  if not M.open_floating_window(opts) then
    return
  end

  M.setup_prompt(opts.modes.search_up)
  M.set_prompt_callback(function(input)
    vim.fn.search(input, "b")
  end)
end

function M.open_floating_window(opts)
	if win ~= nil then
		return false
	end

	buf = api.nvim_create_buf(false, true)
	local ui = api.nvim_list_uis()[1]

	local width = opts.width
	local height = opts.height

	local row = math.floor((ui.height - height) / 2)
	local col = math.floor((ui.width - width) / 2)

	win = api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		zindex = 250,
		style = "minimal",
		border = "rounded",
	})

	vim.bo[buf].buftype = "prompt"
	api.nvim_input("A")

	api.nvim_create_autocmd("InsertLeave", { buffer = buf, callback = M.close })
	api.nvim_create_autocmd("BufLeave", { buffer = buf, callback = M.close })

  return true
end

---@param mode mode
function M.setup_prompt(mode)
  local prompt = mode.prompt
  local hl = mode.hl

  vim.wo[win].winhl = "FloatBorder:".. hl
  set_mark(buf, prompt, hl)
	vim.fn.prompt_setprompt(buf, prompt)
end

---@param callback fun(input : string)
function M.set_prompt_callback(callback)
	vim.fn.prompt_setcallback(buf, function(input)
		if input and input ~= "" then
			api.nvim_set_current_win(original_win)
      callback(input)
		end
		M.close()
	end)
end

function M.close()
	if win ~= nil and api.nvim_win_is_valid(win) then
		api.nvim_win_close(win, true)
	end
	if buf ~= nil and api.nvim_buf_is_valid(buf) then
		api.nvim_buf_delete(buf, { force = true })
	end

	win = nil
	buf = nil
end

return M
