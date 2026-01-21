-- ========================================
-- Colorscheme & UI Configuration
-- ========================================
local function setup_transparency()
	local group = vim.api.nvim_create_augroup("TransparentBG", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		pattern = "*",
		callback = function()
			local hl_groups = {
				"Normal",
				"NormalFloat",
				"LineNr",
				"Folded",
				"NonText",
				"SpecialKey",
				"VertSplit",
				"SignColumn",
				"EndOfBuffer",
			}
			for _, group_name in ipairs(hl_groups) do
				vim.api.nvim_set_hl(0, group_name, { bg = "none", ctermbg = "none" })
			end

			vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#0c0c0c" })
			vim.api.nvim_set_hl(0, "OilHidden", { link = "Comment" })

			-- ========================================
			-- LSP Inlay Hints & Codeium
			-- ========================================
			vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })
			vim.api.nvim_set_hl(0, "CodeiumSuggestion", { link = "Comment" })
		end,
	})
end

return {
	-- Colorscheme: Nord
	{
		"shaunsingh/nord.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.nord_italic = false
			vim.g.nord_bold = true
			vim.g.nord_borders = true

			setup_transparency()
			vim.cmd.colorscheme("nord")

			vim.opt.fillchars = { eob = " " }
		end,
	},

	-- Statusline: Lualine
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		opts = {
			options = {
				theme = "nord",
				component_separators = { left = "│", right = "│" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = { "toggleterm", "dashboard", "Alpha" },
				},
				globalstatus = true,
			},
		},
	},
}
