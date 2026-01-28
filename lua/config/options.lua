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

	-- clipboard configuration
	local clip = platform.clipboard()
	if clip then
		vim.g.clipboard = clip
	end

	-- shell configuration
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
	vim.opt.laststatus = 3
	vim.opt.scrolloff = 1
	vim.opt.signcolumn = "yes"
	vim.opt.mouse = "a"
	vim.opt.guicursor = "n-v-c-i:block"
	vim.opt.completeopt = "menu,menuone,noselect"
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
	vim.opt.undofile = true
	vim.opt.updatetime = 250
	vim.opt.swapfile = false
	vim.opt.clipboard = "unnamedplus"
	vim.opt.virtualedit = "block"
end

-- ========================================
-- Diagnostic Configuration
-- ========================================

local function setup_diagnostics()
	local signs = {
		[vim.diagnostic.severity.ERROR] = "󰅚 ",
		[vim.diagnostic.severity.WARN] = "󰀪 ",
		[vim.diagnostic.severity.HINT] = "󰌶 ",
		[vim.diagnostic.severity.INFO] = "󰋽 ",
	}

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
			source = true,
			header = "",
			prefix = "",
		},
		signs = {
			text = signs,
		},
		underline = true,
		update_in_insert = false,
		severity_sort = true,
	})
end

-- ========================================
-- Main Setup
-- ========================================

function M.setup()
	-- Call individual setup functions
	setup_platform()
	setup_display()
	setup_indentation()
	setup_search()
	setup_editor()
	setup_diagnostics()
end

return M
