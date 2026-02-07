-- ========================================
-- Colorscheme & UI Configuration (Catppuccin)
-- ========================================
return {
	-- Colorscheme: Catppuccin
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			local catppuccin = require("catppuccin")

			catppuccin.setup({
				flavour = "mocha",
				transparent_background = true,
				term_colors = true,
				compile = {
					enabled = true,
					path = vim.fn.stdpath("cache") .. "/catppuccin",
				},
				integrations = {
					cmp = true,
					gitsigns = true,
					treesitter = true,
					notify = true,
					dashboard = true,
					lsp_trouble = true,
					mason = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "undercurl" },
							warnings = { "underline" },
							hints = { "underdot" },
							information = { "underdot" },
						},
						inlay_hints = {
							background = true,
						},
					},
				},
				custom_highlights = function(colors)
					return {
						LspInlayHint = { fg = colors.overlay0, style = { "italic" } },
						CodeiumSuggestion = { fg = colors.overlay0 },
						OilHidden = { fg = colors.overlay0 },
						EndOfBuffer = { fg = colors.base },
					}
				end,
			})

			-- choose colorscheme
			vim.cmd.colorscheme("catppuccin")

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
				theme = "catppuccin",
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
