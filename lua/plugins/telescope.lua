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
	}
end

local function get_telescope_config()
	return {
		defaults = {
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--hidden",
				"--glob",
				"!**/.git/*",
			},
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "top",
					preview_width = 0.55,
				},
			},
			sorting_strategy = "ascending",
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
