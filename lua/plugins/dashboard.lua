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
	-- change highlight groups here: "Normal, Title, String, Constant, Comment"
	local my_hl = "Comment" -- This variable to set highlight group

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
			-- Recently opened files (Telescope)
			icon = "󰈭  ",
			icon_hl = my_hl,
			desc = "Recent files",
			desc_hl = my_hl,
			key = "r",
			key_hl = my_hl,
			action = function()
				require("lazy").load({ plugins = { "telescope.nvim" } })
				require("telescope.builtin").oldfiles({
					attach_mappings = function(prompt_bufnr)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selection = action_state.get_selected_entry()
							if not selection then
								return
							end
							local path = selection.path or selection.filename or selection[1]
							if not path then
								return
							end
							vim.cmd("edit " .. vim.fn.fnameescape(path))
							vim.cmd("filetype detect")
							vim.cmd("syntax enable")
							vim.cmd("doautocmd BufReadPost")
							vim.cmd("doautocmd FileType")
						end)
						return true
					end,
				})
			end,
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
