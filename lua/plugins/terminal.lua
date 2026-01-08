return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			shell = vim.o.shell,
			size = 6,
			open_mapping = "<C-t>",
			direction = "horizontal",
		})

		vim.keymap.set("t", "<C-j>", [[<C-\><C-n>:resize -1<CR>i]], {
			desc = "terminal: shrink height",
			silent = true,
		})

		vim.keymap.set("t", "<C-k>", [[<C-\><C-n>:resize +1<CR>i]], {
			desc = "terminal: grow height",
			silent = true,
		})

		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*#toggleterm#*",
			callback = function()
				vim.b.lualine_disable_statusline = true
				vim.b.lualine_disable_winbar = true
				vim.opt_local.statusline = ""
				vim.opt_local.winbar = ""
			end,
		})
	end,
}