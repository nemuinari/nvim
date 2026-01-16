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


-- Enable Lua module loader cache
local function enable_loader_cache()
	if vim.loader and vim.loader.enable then
		vim.loader.enable()
	end
end

-- 設定モジュールをロード
local function load_config_modules()
	-- leader は即時実行型なので require のみ
	local ok, err = pcall(require, "config.leader")
	if not ok then
		vim.notify("Error loading config.leader: " .. tostring(err), vim.log.levels.WARN)
	end

	-- setup を export する config は setup() を呼ぶ
	for _, mod in ipairs({"config.options", "config.keybinds", "config.languages"}) do
		local ok, m = pcall(require, mod)
		if ok and m and type(m.setup) == "function" then
			local ok2, err2 = pcall(m.setup)
			if not ok2 then
				vim.notify("Error in " .. mod .. ".setup(): " .. tostring(err2), vim.log.levels.WARN)
			end
		elseif not ok then
			vim.notify("Error loading " .. mod .. ": " .. tostring(m), vim.log.levels.WARN)
		end
	end
end

local function init()
	-- 1. Bootstrap lazy.nvim
	if not bootstrap_lazy() then
		return
	end

	-- 2. Enable loader cache for faster startup
	pcall(enable_loader_cache)

	-- 3. Initialize lazy.nvim and load plugins
	require("config.lazy")

	-- 4. 設定モジュールをロード
	load_config_modules()
end

init()
