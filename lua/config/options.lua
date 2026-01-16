-- ========================================
-- Platform-specific Configuration
-- ========================================
local function setup_platform()
	local ok, platform = pcall(require, "config.platform")
	if not ok or not platform then
		return
	end

	-- Clipboard configuration
	if type(platform.clipboard) == "function" then
		local clip = platform.clipboard()
		if clip then
			vim.g.clipboard = clip
		end
	end

	-- Shell configuration
	if type(platform.shell) == "function" then
		local shell = platform.shell()
		if shell then
			vim.opt.shell = shell.shell
			vim.opt.shellcmdflag = shell.shellcmdflag
			vim.opt.shellredir = shell.shellredir
			vim.opt.shellpipe = shell.shellpipe
		end
	end
end

-- ========================================
-- Display Settings
-- ========================================
local function setup_display()
	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.cursorline = true
	vim.opt.termguicolors = true
	vim.opt.laststatus = 3
	vim.opt.signcolumn = "yes"
end

-- ========================================
-- Indentation Settings
-- ========================================
local function setup_indentation()
	vim.opt.expandtab = true
	vim.opt.shiftwidth = 4
	vim.opt.tabstop = 4
	vim.opt.smartindent = true
	vim.opt.breakindent = true
end

-- ========================================
-- Search Settings
-- ========================================
local function setup_search()
	vim.opt.ignorecase = true
	vim.opt.smartcase = true
	vim.opt.hlsearch = true

	-- Clear search highlight with double Escape
	vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>", {
		silent = true,
		desc = "Clear search highlight",
	})
end

-- ========================================
-- File Encoding & Format
-- ========================================
local function setup_encoding()
	vim.opt.encoding = "utf-8"
	vim.opt.fileencoding = "utf-8"
	vim.opt.fileformats = "unix,dos"
end

-- ========================================
-- Editor Behavior
-- ========================================
local function setup_editor()
	vim.opt.mouse = "a"
	vim.opt.undofile = true
	vim.opt.updatetime = 250
	vim.opt.swapfile = false
	vim.opt.hidden = true
	vim.opt.clipboard = "unnamedplus"
end

-- ========================================
-- Diagnostic Configuration
-- ========================================
local function setup_diagnostics()
	vim.diagnostic.config({
		-- エラーのみサインカラムに表示（警告・情報・ヒントは非表示）
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "E",
				[vim.diagnostic.severity.WARN] = "W", -- 警告は非表示
				[vim.diagnostic.severity.INFO] = "I", -- 情報は非表示
				[vim.diagnostic.severity.HINT] = "H", -- ヒントは非表示
			},
		},
		-- 仮想テキストで警告を表示（サインカラムではなく行末に表示）
		virtual_text = {
			severity = {
				min = vim.diagnostic.severity.WARN, -- 警告以上を表示
			},
			prefix = "●",
		},
		-- フロートウィンドウですべて表示
		float = {
			source = "always",
			border = "rounded",
		},
		-- 更新頻度
		update_in_insert = false,
	})
end

-- ========================================
-- Main Setup
-- ========================================
local function setup()
	setup_platform()
	setup_display()
	setup_indentation()
	setup_search()
	setup_encoding()
	setup_editor()
	setup_diagnostics()
end

setup()
