-- ========================================
-- Performance Optimization
-- ========================================

-- Enable the built-in module loader if available (Neovim 0.9+)
if vim.loader then
	vim.loader.enable()
end

-- Disable unused built-in plugins to improve startup time
local disabled_built_ins = {
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwLib",
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	"logipat",
	"rrhelper",
	"spellfile_plugin",
}
for _, plugin in ipairs(disabled_built_ins) do
	vim.g["loaded_" .. plugin] = 1
end

-- ========================================
-- Early UI Setup (Anti-Flash)
-- ========================================

-- Enable true color support
vim.opt.termguicolors = true
vim.opt.background = "dark"
-- Set a simple colorscheme to avoid flash of unstyled content
vim.api.nvim_set_hl(0, "Normal", { bg = "#2e3440", fg = "#d8dee9" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#2e3440", fg = "#d8dee9" })

-- ========================================
-- Lazy.nvim Bootstrap
-- ========================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ========================================
-- Module Loading Logic
-- ========================================

local function load_config()
	-- Load leader key configuration first
	pcall(require, "config.leader")

	-- Check if lazy.nvim is available
	local ok_lazy, _ = pcall(require, "config.lazy")
	if not ok_lazy then
		return
	end

	-- List of configuration modules to load
	local modules = {
		"config.options",
		"config.keybinds",
		"config.languages",
	}

	-- Load each module and call its setup function if available
	for _, mod in ipairs(modules) do
		local ok, m = pcall(require, mod)
		if ok and type(m) == "table" and type(m.setup) == "function" then
			local success, err = pcall(m.setup)
			if not success then
				vim.notify(string.format("Error in %s.setup(): %s", mod, err), vim.log.levels.WARN)
			end
		end
	end
end

-- execute
load_config()
