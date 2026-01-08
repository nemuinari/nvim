local function set_transparency()
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
	{
		"shaunsingh/nord.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.nord_italic = false
			vim.cmd.colorscheme("nord")
			set_transparency()
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VimEnter",
		opts = {
			options = {
				theme = "nord",
				disabled_filetypes = {
					statusline = { "toggleterm" },
					winbar = { "toggleterm" },
				},
			},
		},
	},
}
