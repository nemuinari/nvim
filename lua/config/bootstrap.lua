-- ========================================
-- Performance Optimization
-- ========================================

-- Lua モジュールローダーのキャッシュを有効化
if vim.loader then
	vim.loader.enable()
end

-- ========================================
-- Early UI Setup (Anti-Flash)
-- ========================================

vim.opt.termguicolors = true
vim.opt.background = "dark"
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
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ========================================
-- Module Loading Logic
-- ========================================

local function load_config()
	pcall(require, "config.leader")

	local ok_lazy, _ = pcall(require, "config.lazy")
	if not ok_lazy then
		return
	end

	local modules = {
		"config.options",
		"config.keybinds",
		"config.languages",
	}

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

-- 実行
load_config()
