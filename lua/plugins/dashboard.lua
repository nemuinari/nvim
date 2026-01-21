-- ========================================
-- Dashboard Configuration
-- ========================================

local M = {}

-- ========================================
-- Dashboard Header
-- ========================================

local function get_header()
	return require("config.dashboard_header")
end

-- ========================================
-- Dashboard Center Items
-- ========================================

local function get_center_items()
	return {
		{
			icon = "󰈔  ",
			icon_hl = "Title",
			desc = "New File",
			desc_hl = "String",
			key = "n",
			key_hl = "Number",
			action = "enew",
		},
		{
			icon = "󰈞  ",
			icon_hl = "Title",
			desc = "Find File",
			desc_hl = "String",
			key = "f",
			key_hl = "Number",
			action = "Oil --float",
		},
		{
			icon = "󰋚  ",
			icon_hl = "Title",
			desc = "Recent Files",
			desc_hl = "String",
			key = "r",
			key_hl = "Number",
			action = function()
				require("telescope.builtin").oldfiles()
			end,
		},
		{
			icon = "󰗼  ",
			icon_hl = "Title",
			desc = "Quit",
			desc_hl = "String",
			key = "q",
			key_hl = "Number",
			action = "quit",
		},
	}
end

-- ========================================
-- Dashboard Footer
-- ========================================

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

-- ========================================
-- Dashboard Setup
-- ========================================

local function get_dashboard_config()
	return {
		theme = "doom",
		config = {
			header = get_header(),
			center = get_center_items(),
			footer = get_footer,
		},
	}
end

-- ========================================
-- Plugin Specification
-- ========================================

return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	priority = 1000,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("dashboard").setup(get_dashboard_config())
	end,
}
