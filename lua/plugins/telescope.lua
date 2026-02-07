-- ========================================
-- Telescope Configuration
-- ========================================

local function get_telescope_keymaps()
	return {
		{
			"<leader>fr", -- find recent
			function()
				require("telescope.builtin").oldfiles()
			end,
			desc = "Recent files",
		},
		{
			"<leader>fb", -- find buffers
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fh", -- find help
			function()
				require("telescope.builtin").help_tags()
			end,
			desc = "Help tags",
		},
	}
end

local function get_telescope_config()
	return {
		defaults = {
			mappings = {
				i = {
					["<Esc>"] = function(...)
						return require("telescope.actions").close(...)
					end,
				},
			},
		},
	}
end

local function setup_telescope()
	require("telescope").setup(get_telescope_config())
end

return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = get_telescope_keymaps(),
	config = setup_telescope,
}
