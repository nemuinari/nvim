return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local ok, configs = pcall(require, "nvim-treesitter.configs")
		if ok then
			configs.setup({
				highlight = { enable = true },
				indent = { enable = true },
				ensure_installed = {
					"lua", "json", "markdown", "markdown_inline", "yaml", "bash", "html", "css",
					"c", "cpp", "python", "rust",
				},
				auto_install = false,
			})
		end
	end,
}

