-- ========================================
-- Oil.nvim Configuration
-- ========================================

-- 特殊バッファタイプ（Oil バッファを閉じない対象）
local SPECIAL_BUFFER_TYPES = {
	terminal = true,
	nofile = true,
	prompt = true,
}

-- ========================================
-- Helper Functions
-- ========================================

-- Oil バッファかどうかを判定
local function is_oil_buffer(bufname)
	return bufname:match("^oil://") ~= nil
end

-- 特殊バッファかどうかを判定
local function is_special_buffer(bufnr)
	local buftype = vim.bo[bufnr].buftype
	return SPECIAL_BUFFER_TYPES[buftype] == true
end

-- すべての Oil バッファを閉じる
local function close_all_oil_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) then
			local bufname = vim.api.nvim_buf_get_name(buf)
			if is_oil_buffer(bufname) then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end
	end
end

-- Oil バッファから離れた時の処理
local function on_oil_buffer_leave()
	vim.schedule(function()
		local current_buf = vim.api.nvim_get_current_buf()
		local bufname = vim.api.nvim_buf_get_name(current_buf)

		-- 特殊バッファの場合は何もしない
		if is_special_buffer(current_buf) then
			return
		end

		-- 通常のファイルバッファに移動した場合のみ Oil バッファを閉じる
		if not is_oil_buffer(bufname) and bufname ~= "" then
			close_all_oil_buffers()
		end
	end)
end

-- ========================================
-- Oil Setup Configuration
-- ========================================
local function get_oil_config()
	return {
		default_file_explorer = true,
		watch_for_changes = true,

		-- キーマップの設定
		keymaps = {
			["<C-t>"] = false, -- ターミナルトグルとの競合を防ぐ
		},

		-- 表示オプション
		view_options = {
			show_hidden = true,
		},

		-- フローティングウィンドウの設定
		float = {
			padding = 0,
			max_width = 0,
			max_height = 0,
			border = "none",
		},
	}
end

-- ========================================
-- Autocmd Setup
-- ========================================
local function setup_autocmds()
	vim.api.nvim_create_autocmd("BufLeave", {
		pattern = "oil://*",
		callback = on_oil_buffer_leave,
		desc = "Close oil buffers when leaving to normal file",
	})
end

-- ========================================
-- Plugin Specification
-- ========================================
return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,

	-- キーマップ
	keys = {
		{
			"<leader>e",
			"<CMD>Oil --float<CR>",
			desc = "Open file explorer",
		},
	},

	-- セットアップ
	config = function()
		local ok, oil = pcall(require, "oil")
		if not ok then
			vim.notify("Failed to load oil.nvim", vim.log.levels.ERROR)
			return
		end

		oil.setup(get_oil_config())
		setup_autocmds()
	end,
}
