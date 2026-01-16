-- ========================================
-- Bootstrap lazy.nvim
-- ========================================
local function bootstrap_lazy()
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

	if (vim.uv or vim.loop).fs_stat(lazypath) then
		vim.opt.rtp:prepend(lazypath)
		return true
	end

	-- Clone lazy.nvim
	local repo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		repo,
		lazypath,
	})

	-- Check for errors
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end

	vim.opt.rtp:prepend(lazypath)
	return true
end

-- ========================================
-- Enable Lua module loader cache
-- ========================================
local function enable_loader_cache()
	if vim.loader and vim.loader.enable then
		vim.loader.enable()
	end
end

-- ========================================
-- Load deferred configurations
-- ========================================
local function load_deferred_config()
	local configs = { "config.options", "config.keybinds" }

	for _, config in ipairs(configs) do
		local ok, err = pcall(require, config)
		if not ok then
			vim.notify(string.format("Failed to load %s: %s", config, err), vim.log.levels.WARN)
		end
	end
end

-- ========================================
-- Main initialization
-- ========================================
local function init()
	-- 1. Bootstrap lazy.nvim
	if not bootstrap_lazy() then
		return
	end

	-- 2. Enable loader cache for faster startup
	pcall(enable_loader_cache)

	-- 3. Initialize lazy.nvim and load plugins
	require("config.lazy")

	-- 4. Defer heavy configurations to VimEnter
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = load_deferred_config,
	})
end

-- Run initialization
init()
