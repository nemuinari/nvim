-- ========================================
-- Colorscheme & UI Configuration
-- ========================================
local function setup_transparency()
	local group = vim.api.nvim_create_augroup("TransparentBG", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		pattern = "*",
		callback = function()
			-- 背景の透明化
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

			-- EndOfBuffer の透明化
			vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#0c0c0c" })

			-- Oil プラグインの隠しファイル表示をコメント色に設定
			vim.api.nvim_set_hl(0, "OilHidden", { link = "Comment" })

			-- ========================================
			-- 型表示 (Inlay Hints) をコメント色にする
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
