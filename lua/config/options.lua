
local ok, platform = pcall(require, "config.platform")
if ok and platform then
	if type(platform.clipboard) == "function" then
		local clip = platform.clipboard()
		if clip then
			vim.g.clipboard = clip
		end
	end
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

-- 基本表示
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.laststatus = 3
vim.opt.signcolumn = "yes"

-- インデント
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.breakindent = true

-- 検索
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>', { silent = true })

-- 文字コード・ファイル形式
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileformats = "unix,dos"

-- 編集
vim.opt.mouse = "a"
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.swapfile = false
vim.opt.hidden = true

vim.opt.clipboard = "unnamedplus"
