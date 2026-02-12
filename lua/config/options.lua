-- ========================================
-- Neovim Options Configuration
-- ========================================

local M = {}

-- ========================================
-- Platform & System Configuration
-- ========================================

local function setup_platform()
	-- Safely try to load platform specific config
	local ok, platform = pcall(require, "config.platform")
	if not ok then
		return
	end

	-- Clipboard configuration
	if platform.clipboard then
		local clip = platform.clipboard()
		if clip then
			vim.g.clipboard = clip
		end
	end

	-- Shell configuration
	if platform.shell then
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
-- Display & UI Settings
-- ========================================

local function setup_display()
	-- Window & Buffer UI
	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.cursorline = true
	vim.opt.signcolumn = "yes"
	vim.opt.laststatus = 3 -- Global statusline
	vim.opt.showmode = false -- Don't show mode in command line (lualine handles it)

	-- Window splitting behavior
	vim.opt.splitbelow = true
	vim.opt.splitright = true

	-- Mouse & Scrolling
	vim.opt.mouse = "a"
	-- vim.opt.scrolloff = 8 -- Keep 8 lines context when scrolling (optional but recommended)

	-- Visual Cursors
	vim.opt.guicursor = "n-v-c-i:block"

	-- Completion Menu
	vim.opt.completeopt = { "menu", "menuone", "noselect" }
end

-- ========================================
-- Indentation & Search
-- ========================================

local function setup_indentation()
	vim.opt.expandtab = true
	vim.opt.shiftwidth = 4
	vim.opt.tabstop = 4
	vim.opt.softtabstop = 4
	vim.opt.smartindent = true
	vim.opt.breakindent = true
end

local function setup_search()
	vim.opt.ignorecase = true -- Case insensitive searching
	vim.opt.smartcase = true -- Case sensitive if uppercase present
	vim.opt.hlsearch = true

	-- Clear search highlight with <Esc><Esc>
	vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
end

-- ========================================
-- Editor Behavior & File Handling
-- ========================================

local function setup_editor()
	-- ★ IMPORTANT FIX for E21 Error ★
	-- Use 'vim.opt_global' for buffer-local options.
	-- This sets the *default* for new buffers without trying to modify
	-- the current locked buffer (like Dashboard).

	vim.opt_global.fileencoding = "utf-8"
	vim.opt_global.fileformats = "unix,dos"
	vim.opt_global.swapfile = false
	vim.opt_global.undofile = true

	-- General Editor Settings
	vim.opt.updatetime = 250
	vim.opt.timeoutlen = 300
	vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
	vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in Visual Block mode
end

-- ========================================
-- Diagnostic Configuration
-- ========================================

local function setup_diagnostics()
	-- Define signs efficiently
	local signs = {
		{ name = "DiagnosticSignError", text = "󰅚 " },
		{ name = "DiagnosticSignWarn", text = "󰀪 " },
		{ name = "DiagnosticSignHint", text = "󰌶 " },
		{ name = "DiagnosticSignInfo", text = "󰋽 " },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	vim.diagnostic.config({
		-- Enable/Disable features
		virtual_text = {
			prefix = "●",
			spacing = 4,
			severity = { min = vim.diagnostic.severity.WARN }, -- Don't show virtual text for Info/Hint
		},
		signs = {
			active = signs, -- Use the signs defined above
		},
		float = {
			focused = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
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
	setup_platform()
	setup_display()
	setup_indentation()
	setup_search()
	setup_editor()
	setup_diagnostics()
end

return M
