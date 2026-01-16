return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
	},
	keys = {
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files()
			end,
			desc = "Find files",
		},
		{
			"<leader>fg",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>fb",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fh",
			function()
				require("telescope.builtin").help_tags()
			end,
			desc = "Help tags",
		},
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			defaults = { layout_strategy = "horizontal" },
			extensions = {
				file_browser = {
					hijack_netrw = false, -- do not override netrw
					respect_gitignore = true,
					hidden = true,
					grouped = true,
				},
			},
		})

		-- Load file browser extension
		pcall(telescope.load_extension, "file_browser")
	end,
}
