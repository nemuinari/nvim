-- ========================================
-- Neovim Bootstrap Configuration
-- ========================================

-- ========================================
-- Lazy.nvim Bootstrap
-- ========================================

--- Lazy.nvim をインストールまたは読み込む
---@return boolean success
local function bootstrap_lazy()
	local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
	
	if (vim.uv or vim.loop).fs_stat(lazypath) then
		vim.opt.rtp:prepend(lazypath)
		return true
	end
	
	local repo = 'https://github.com/folke/lazy.nvim.git'
	local out = vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'--branch=stable',
		repo,
		lazypath,
	})
	
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
			{ out, 'WarningMsg' },
			{ '\nPress any key to exit...' },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
	
	vim.opt.rtp:prepend(lazypath)
	return true
end

-- ========================================
-- Loader Cache
-- ========================================

--- Lua モジュールローダーのキャッシュを有効化
local function enable_loader_cache()
	if vim.loader and vim.loader.enable then
		vim.loader.enable()
	end
end

-- ========================================
-- Early Colorscheme Setup
-- ========================================

--- 早期カラースキーム設定（フラッシュ防止）
local function set_early_colorscheme()
	vim.opt.termguicolors = true
	vim.opt.background = 'dark'
	vim.api.nvim_set_hl(0, 'Normal', { bg = '#2e3440', fg = '#d8dee9' })
	vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#2e3440', fg = '#d8dee9' })
end

-- ========================================
-- Config Modules
-- ========================================

--- 設定モジュールをロード
local function load_config_modules()
	-- Leader キー設定を即時実行
	local ok, err = pcall(require, 'config.leader')
	if not ok then
		vim.notify('Error loading config.leader: ' .. tostring(err), vim.log.levels.WARN)
	end
	
	-- setup() を持つ設定モジュールを実行
	local config_modules = {
		'config.options',
		'config.keybinds',
		'config.languages',
	}
	
	for _, mod in ipairs(config_modules) do
		local ok, module = pcall(require, mod)
		if ok and module and type(module.setup) == 'function' then
			local ok2, err2 = pcall(module.setup)
			if not ok2 then
				vim.notify(
					'Error in ' .. mod .. '.setup(): ' .. tostring(err2),
					vim.log.levels.WARN
				)
			end
		elseif not ok then
			vim.notify('Error loading ' .. mod .. ': ' .. tostring(module), vim.log.levels.WARN)
		end
	end
end

-- ========================================
-- Initialization
-- ========================================

--- Neovim を初期化
local function init()
	-- 1. ローダーキャッシュを有効化（高速化）
	pcall(enable_loader_cache)
	
	-- 2. 早期カラースキーム設定（フラッシュ防止）
	pcall(set_early_colorscheme)
	
	-- 3. Lazy.nvim をブートストラップ
	if not bootstrap_lazy() then
		return
	end
	
	-- 4. Lazy.nvim を初期化してプラグインをロード
	require('config.lazy')
	
	-- 5. 設定モジュールをロード
	load_config_modules()
end

-- ========================================
-- Execute
-- ========================================

init()
