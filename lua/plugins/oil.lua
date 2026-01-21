-- ========================================
-- Oil Configuration (Modernized UI)
-- ========================================

return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "Oil",
	keys = {
		{ "<leader>e", "<CMD>Oil --float<CR>", desc = "Open file explorer" },
	},
	config = function()
		require("oil").setup({
			default_file_explorer = true,
			watch_for_changes = true,

			skip_confirm_for_simple_edits = true,

			columns = {
				"icon",
				-- "permissions", -- 権限表示
				-- "size",        -- サイズ表示
				-- "mtime",       -- 更新日時
			},

			-- ウィンドウの設定
			float = {
				padding = 4,
				max_width = 80,
				max_height = 0.7,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
			},

			view_options = {
				show_hidden = true,
				-- 隠しファイルの定義
				is_hidden_file = function(name, bufnr)
					return vim.startswith(name, ".")
				end,
				-- ファイル名のハイライトを有効化
				highlight_filenames = true,
			},

			-- Oilバッファ内のキーマップを微調整
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-v>"] = "actions.select_vsplit",
				["<C-h>"] = "actions.select_split",
				["<C-t>"] = "actions.select_tab",
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
			},

			cleanup_delay_ms = 2000,
		})

		-- ダッシュボードとOilの競合を防ぐためのオートコマンド
		local group = vim.api.nvim_create_augroup("oil_custom", { clear = true })

		-- Oilバッファに入るときにダッシュボードを閉じる
		vim.api.nvim_create_autocmd("BufEnter", {
			group = group,
			pattern = "oil://*",
			callback = function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.bo[buf].filetype == "dashboard" then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end
			end,
		})
	end,
}
