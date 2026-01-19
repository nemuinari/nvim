-- ========================================
-- Oil.nvim Configuration
-- ========================================

-- ========================================
-- Constants
-- ========================================

local SPECIAL_BUFFER_TYPES = {
	terminal = true,
	nofile = true,
	prompt = true,
	dashboard = true,
}

-- ========================================
-- Buffer Type Checks
-- ========================================

--- Oil バッファかどうかを判定
---@param bufnr number
---@return boolean
local function is_oil_buffer(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	return bufname:match("^oil://") ~= nil
end

--- 特殊バッファかどうかを判定
---@param bufnr number
---@return boolean
local function is_special_buffer(bufnr)
	local buftype = vim.bo[bufnr].buftype
	local filetype = vim.bo[bufnr].filetype
	return SPECIAL_BUFFER_TYPES[buftype] or SPECIAL_BUFFER_TYPES[filetype]
end

--- 通常のファイルバッファかどうかを判定
---@param bufnr number
---@return boolean
local function is_normal_file(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	return bufname ~= "" and not is_oil_buffer(bufnr) and not is_special_buffer(bufnr)
end

-- ========================================
-- Buffer Management
-- ========================================

--- ダッシュボードバッファを削除
local function close_dashboard_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "dashboard" then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
end

--- すべての Oil バッファを閉じる
local function close_all_oil_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and is_oil_buffer(buf) then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
end

-- ========================================
-- Event Handlers
-- ========================================

--- Oil バッファに入った時の処理
local function on_oil_enter()
	close_dashboard_buffers()
end

--- Oil バッファから離れた時の処理
local function on_oil_leave()
	local current_buf = vim.api.nvim_get_current_buf()

	if is_normal_file(current_buf) then
		close_all_oil_buffers()
	end
end

-- ========================================
-- Oil Configuration
-- ========================================

local function get_oil_config()
	return {
		default_file_explorer = true,
		watch_for_changes = true,
		keymaps = {
			["<C-t>"] = false,
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
	}
end

-- ========================================
-- Autocmd Setup
-- ========================================

local function setup_autocmds()
	local group = vim.api.nvim_create_augroup("oil_custom", { clear = true })

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		pattern = "oil://*",
		callback = on_oil_enter,
		desc = "Close dashboard when entering oil buffer",
	})

	vim.api.nvim_create_autocmd("BufLeave", {
		group = group,
		pattern = "oil://*",
		callback = on_oil_leave,
		desc = "Close oil buffers when leaving to normal file",
	})
end

-- ========================================
-- Plugin Specification
-- ========================================
return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },

	cmd = "Oil",
	keys = {
		{ "<leader>e", "<CMD>Oil --float<CR>", desc = "Open file explorer" },
	},
	config = function()
		require("oil").setup(get_oil_config())
		setup_autocmds()
	end,
}
