-- ========================================
-- Dashboard Configuration
-- ========================================
local M = {}

-- Dashboard Header
local function get_header()
	return require("config.dashboard_header")
end

-- Dashboard Center Items
local function get_center_items()
	-- change highlight groups here:
	-- "Normal, String, Constant, Comment"
	-- "DashboardCenter": original color

	local my_hl = "String" -- This variable to set highlight group

	return {
		{
			icon = "󰈔  ",
			icon_hl = my_hl,
			desc = "New file",
			desc_hl = my_hl,
			key = "n",
			key_hl = my_hl,
			action = "enew",
		},
		{
			icon = "󰈞  ",
			icon_hl = my_hl,
			desc = "Find file",
			desc_hl = my_hl,
			key = "f",
			key_hl = my_hl,
			action = "Oil --float",
		},
		{
			icon = "󰒲  ",
			icon_hl = my_hl,
			desc = "Lazy manager",
			desc_hl = my_hl,
			key = "l",
			key_hl = my_hl,
			action = "Lazy",
		},
		{
			icon = "󰗼  ",
			icon_hl = my_hl,
			desc = "Quit",
			desc_hl = my_hl,
			key = "q",
			key_hl = my_hl,
			action = "quit",
		},
	}
end

-- Dashboard Footer
local function get_footer()
	local stats = require("lazy").stats()
	local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
	local date = os.date(" %Y-%m-%d")
	local time = os.date(" %H:%M:%S")

	return {
		"",
		date .. " " .. time,
		string.format("loaded in %.2f ms", ms),
	}
end

-- Dashboard Setup
local function get_dashboard_config()
	return {
		theme = "doom",
		hide = {
			statusline = true,
			tabline = true,
			winbar = true,
		},
		config = {
			header = get_header(),
			center = get_center_items(),
			footer = get_footer,
		},
	}
end

-- Plugin Specification
return {
	"nvimdev/dashboard-nvim",
	event = "UIEnter",
	priority = 1000,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("dashboard").setup(get_dashboard_config())
	end,
}
