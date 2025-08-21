local api = vim.api
local map = vim.keymap.set
local default_opts = require("floating-cmd.opts")

local M = {}

local win
local buf
local namespace = api.nvim_create_namespace("FloatinCmd")
local prefix_to_prompt = {
  [":"] = { prompt = "   ", hl = "FloatingCmdNormal" },
  ["/"] = { prompt = "   ", hl = "FloatingCmdSearch" },
  ["?"] = { prompt = "   ", hl = "FloatingCmdSearch" },
}

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
  require("floating-cmd.highlight-groups")
	map({ "n", "v" }, ":", function()
		M.open(":", default_opts)
	end)
	map({ "n", "v" }, "/", function()
		M.open("/", default_opts)
	end)
	map({ "n", "v" }, "?", function()
		M.open("?", default_opts)
	end)
end

--- @param prefix string
function M.open(prefix, opts)
	if win ~= nil then
		return
	end

	local original_win = api.nvim_get_current_win()

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

  local prompt = prefix_to_prompt[prefix].prompt
  local hl = prefix_to_prompt[prefix].hl

  vim.wo[win].winhl = "FloatBorder:".. hl
  set_mark(buf, prompt, hl)
	vim.fn.prompt_setprompt(buf, prompt)
	api.nvim_input("A")

	api.nvim_create_autocmd("InsertLeave", { buffer = buf, callback = M.close })
	api.nvim_create_autocmd("BufLeave", { buffer = buf, callback = M.close })

	vim.fn.prompt_setcallback(buf, function(input)
		if input and input ~= "" then
			api.nvim_set_current_win(original_win)
			vim.cmd(input) -- Run the command
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
