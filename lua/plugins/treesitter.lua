-- ========================================
-- Treesitter Configuration
-- ========================================

-- ========================================
-- Language List
-- ========================================

local ENSURE_INSTALLED_LANGUAGES = {
	"lua",
	"vim",
	"vimdoc",
}

-- ========================================
-- Treesitter Setup
-- ========================================

local function get_treesitter_config()
	return {
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
		ensure_installed = ENSURE_INSTALLED_LANGUAGES,
		auto_install = true,
	}
end

-- ========================================
-- Plugin Specification
-- ========================================

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = "BufReadPost",
	priority = 800,
	config = function()
		local ok, configs = pcall(require, "nvim-treesitter.configs")
		if not ok then
			return
		end
		configs.setup(get_treesitter_config())
	end,
}

