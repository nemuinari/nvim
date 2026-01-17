-- ========================================
-- Telescope Configuration
-- ========================================

-- ========================================
-- Keymaps
-- ========================================

local function get_telescope_keymaps()
	return {
		{
			'<leader>ff',
			function()
				require('telescope.builtin').find_files()
			end,
			desc = 'Find files',
		},
		{
			'<leader>fg',
			function()
				require('telescope.builtin').live_grep()
			end,
			desc = 'Live grep',
		},
		{
			'<leader>fb',
			function()
				require('telescope.builtin').buffers()
			end,
			desc = 'Buffers',
		},
		{
			'<leader>fh',
			function()
				require('telescope.builtin').help_tags()
			end,
			desc = 'Help tags',
		},
	}
end

-- ========================================
-- Telescope Setup
-- ========================================

local function get_telescope_config()
	return {
		defaults = {
			layout_strategy = 'horizontal',
			mappings = {
				i = {
					['<Esc>'] = function(...)
						return require('telescope.actions').close(...)
					end,
				},
			},
		},
		extensions = {
			file_browser = {
				hijack_netrw = false,
				respect_gitignore = true,
				hidden = true,
				grouped = true,
			},
		},
	}
end

local function setup_telescope()
	local telescope = require('telescope')
	telescope.setup(get_telescope_config())
	pcall(telescope.load_extension, 'file_browser')
end

-- ========================================
-- Plugin Specification
-- ========================================

return {
	'nvim-telescope/telescope.nvim',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-telescope/telescope-file-browser.nvim',
	},
	keys = get_telescope_keymaps(),
	config = setup_telescope,
}