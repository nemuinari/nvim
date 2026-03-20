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
    "rust",
    "css",
    "html",
    "markdown",
    "markdown_inline",
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

        pcall(vim.treesitter.language.register, "rust", "ron")

        vim.api.nvim_create_autocmd("BufReadPost", {
            pattern = "*.ron",
            callback = function(args)
                pcall(vim.treesitter.start, args.buf, "rust")
            end,
        })
    end,
}
