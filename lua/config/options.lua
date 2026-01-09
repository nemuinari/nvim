-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Display
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.laststatus = 3
vim.opt.signcolumn = "yes"

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.breakindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>', { silent = true })

-- Encoding & file format
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileformats = "unix,dos"

-- Editing
vim.opt.mouse = "a"
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.swapfile = false
vim.opt.hidden = true  -- 未保存バッファを隠すことを許可

local platform = require("config.platform")

local clip = platform.clipboard()
if clip then
	vim.g.clipboard = clip
end
vim.opt.clipboard = "unnamedplus"

local shell = platform.shell()
if shell then
	vim.opt.shell = shell.shell
	vim.opt.shellcmdflag = shell.shellcmdflag
	vim.opt.shellredir = shell.shellredir
	vim.opt.shellpipe = shell.shellpipe
end
