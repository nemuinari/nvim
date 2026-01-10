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
			watch_for_changes = true,  -- ファイルシステムの変更を監視
			keymaps = {
				["<C-t>"] = false,  -- ターミナルトグルとの競合を防ぐ
			},
			view_options = {
				show_hidden = true,
			},
			float = {
				padding = 0,
				max_width = 0,
				max_height = 0,
				border = "none",
			},
		})
		
		-- ファイルを開いたらoilを自動的に閉じる（ターミナルは除く）
		vim.api.nvim_create_autocmd("BufLeave", {
			pattern = "oil://*",
			callback = function()
				-- 次のバッファが通常のファイルならoilを閉じる
				vim.schedule(function()
					local current_buf = vim.api.nvim_get_current_buf()
					local bufname = vim.api.nvim_buf_get_name(current_buf)
					local buftype = vim.bo[current_buf].buftype
					
					-- ターミナルやスペシャルバッファの場合はoilを閉じない
					if buftype == "terminal" or buftype == "nofile" or buftype == "prompt" then
						return
					end
					
					-- 通常のファイルに移動した場合のみoilを閉じる
					if not bufname:match("^oil://") and bufname ~= "" then
						-- 全てのoilバッファを閉じる
						for _, buf in ipairs(vim.api.nvim_list_bufs()) do
							if vim.api.nvim_buf_is_valid(buf) then
								local name = vim.api.nvim_buf_get_name(buf)
								if name:match("^oil://") then
									pcall(vim.api.nvim_buf_delete, buf, { force = true })
								end
							end
						end
					end
				end)
			end,
		})
	end,
}
