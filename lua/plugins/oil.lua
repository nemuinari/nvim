return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,  -- 起動時に即読み込み
	keys = {
		{ "<leader>e", "<CMD>Oil --float<CR>", desc = "Open file explorer" },
	},
	config = function()
		require("oil").setup({
			default_file_explorer = true,
		})
	end,
}
