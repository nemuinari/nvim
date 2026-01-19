-- ========================================
-- Languages & Formatting Configuration
-- ========================================

local M = {}

-- ========================================
-- Constants & Settings
-- ========================================

local INDENTS = {
	c = 4,
	cpp = 4,
	rust = 4,
	python = 4,
	lua = 2,
	javascript = 2,
	typescript = 2,
	json = 2,
}

local FILE_PATTERNS = {
	clang = { "*.c", "*.cc", "*.cpp", "*.h", "*.hh", "*.hpp" },
	rust = { "*.rs" },
}

-- ========================================
-- Helper Functions
-- ========================================

--- インデントの自動適用
local function setup_indent()
	local group = vim.api.nvim_create_augroup("LangIndent", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = vim.tbl_keys(INDENTS),
		callback = function(ev)
			local sw = INDENTS[ev.match]
			vim.opt_local.shiftwidth = sw
			vim.opt_local.tabstop = sw
			vim.opt_local.expandtab = true
		end,
	})
end

--- 外部コマンドによるフォーマット実行
local function format_buffer(bin, args)
	if vim.fn.executable(bin) ~= 1 then
		return
	end
	local view = vim.fn.winsaveview()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local out = vim.fn.systemlist(vim.list_extend({ bin }, args), lines)
	if vim.v.shell_error == 0 then
		vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
	end
	vim.fn.winrestview(view)
end

-- ========================================
-- Formatting Logic
-- ========================================

local function setup_manual_format()
	local group = vim.api.nvim_create_augroup("ManualFormat", { clear = true })

	-- Clang Format
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		pattern = FILE_PATTERNS.clang,
		callback = function()
			format_buffer("clang-format", { "--style=file", "--assume-filename=" .. vim.api.nvim_buf_get_name(0) })
		end,
	})

	-- Rust Format
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		pattern = FILE_PATTERNS.rust,
		callback = function()
			format_buffer("rustfmt", { "--emit=stdout", "--quiet" })
		end,
	})
end

-- ========================================
-- Main Setup
-- ========================================

function M.setup()
	setup_indent()

	-- Check if Conform is used for formatting
	local use_conform = vim.g.use_conform ~= false
	if not use_conform then
		setup_manual_format()
	end
end

return M
