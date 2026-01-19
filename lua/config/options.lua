-- ========================================
-- Neovim Options Configuration
-- ========================================

local M = {}

-- ========================================
-- Platform-specific Configuration
-- ========================================

local function setup_platform()
	local ok, platform = pcall(require, "config.platform")
	if not ok then
		return
	end

	-- クリップボード設定
	local clip = platform.clipboard()
	if clip then
		vim.g.clipboard = clip
	end

	-- シェル設定
	local shell = platform.shell()
	if shell then
		vim.opt.shell = shell.shell
		vim.opt.shellcmdflag = shell.shellcmdflag
		vim.opt.shellredir = shell.shellredir
		vim.opt.shellpipe = shell.shellpipe
	end
end

-- ========================================
-- Display & UI Settings
-- ========================================

local function setup_display()
	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.cursorline = true
	vim.opt.laststatus = 3 -- グローバルステータスライン
	vim.opt.signcolumn = "yes" -- サインカラムを常に表示
	vim.opt.mouse = "a"
	vim.opt.guicursor = "n-v-c-i:block" -- カーソル形状の固定
end

-- ========================================
-- Indentation & Search
-- ========================================

local function setup_indentation()
	vim.opt.expandtab = true
	vim.opt.shiftwidth = 4
	vim.opt.tabstop = 4
	vim.opt.smartindent = true
	vim.opt.breakindent = true
end

local function setup_search()
	vim.opt.ignorecase = true
	vim.opt.smartcase = true
	vim.opt.hlsearch = true
	vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
end

-- ========================================
-- Editor Behavior & Encoding
-- ========================================

local function setup_editor()
	vim.opt.fileencoding = "utf-8"
	vim.opt.fileformats = "unix,dos"
	vim.opt.undofile = true -- 永続的なアンドゥ
	vim.opt.updatetime = 250 -- 遅延を減らす (デフォルト 4000ms)
	vim.opt.swapfile = false
	vim.opt.clipboard = "unnamedplus"
end

-- ========================================
-- Diagnostic Configuration
-- ========================================

local function setup_diagnostics()
	-- カスタムサインの定義
	local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = "󰋽 " }
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end

	vim.diagnostic.config({
		virtual_text = {
			prefix = "●",
			spacing = 4,
			severity = { min = vim.diagnostic.severity.WARN },
		},
		float = {
			focused = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
		signs = true,
		underline = true,
		update_in_insert = false,
		severity_sort = true,
	})
end

-- ========================================
-- Main Setup
-- ========================================

function M.setup()
	-- 各種設定の初期化
	setup_platform()
	setup_display()
	setup_indentation()
	setup_search()
	setup_editor()
	setup_diagnostics()
end

return M

