-- ========================================
-- Colorscheme & UI Configuration (Kanagawa)
-- ========================================
return {
	-- Colorscheme: Kanagawa
	{
		"rebelot/kanagawa.nvim",
		event = "UIEnter",
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				transparent = true,
				theme = "wave",
			})

			-- choose colorscheme
			vim.cmd.colorscheme("kanagawa")

			-- Make gutter background transparent (line numbers, signs, folds)
			vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
			vim.api.nvim_set_hl(0, "LineNrAbove", { bg = "none" })
			vim.api.nvim_set_hl(0, "LineNrBelow", { bg = "none" })
			vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
			vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
			vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none" })
			vim.api.nvim_set_hl(0, "GitSignsAdd", { bg = "none" })
			vim.api.nvim_set_hl(0, "GitSignsChange", { bg = "none" })
			vim.api.nvim_set_hl(0, "GitSignsDelete", { bg = "none" })
			vim.api.nvim_set_hl(0, "DiagnosticSignError", { bg = "none" })
			vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { bg = "none" })
			vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { bg = "none" })
			vim.api.nvim_set_hl(0, "DiagnosticSignHint", { bg = "none" })

			-- Remove ~ from the end of the buffer
			vim.opt.fillchars:append({ eob = " " })
		end,
	},

	-- Statusline: Lualine
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		opts = {
			options = {
				theme = "auto",
				component_separators = { left = "│", right = "│" },
				section_separators = { left = "", right = "" }, -- fancy separators
				disabled_filetypes = {
					statusline = { "toggleterm", "dashboard", "Alpha" },
				},
				globalstatus = true,
			},
			sections = {
				lualine_x = {
					"encoding",
					{ "fileformat", icons_enabled = false },
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},
}
