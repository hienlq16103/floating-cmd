local hl_groups = require("floating-cmd.highlight-groups").hl_groups

---@class mode
---@field prompt string
---@field pattern string
---@field hl string

local opts = {
	width = 85,
	height = 1,
  ---@type mode[]
	modes = {
		cmdline = { prompt = "   ", pattern = "^:", hl = hl_groups.normal },
		search_down = { prompt = "   ", pattern = "^/", hl = hl_groups.search },
		search_up = { prompt = "   ", pattern = "^%?", hl = hl_groups.search },
		lua = { prompt = "   ", pattern = { "%s*lua%s+", "%s*lua%s*=%s*", "%s*=%s*" }, hl = hl_groups.lua },
		help = { prompt = " 󰘥  ", pattern = "%s*he?l?p?%s+" },
	},
}

return opts
