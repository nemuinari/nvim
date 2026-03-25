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
    init = function()
        -- Register early (before lazy load) so filetype detection and treesitter both work
        vim.filetype.add({ extension = { ron = "ron" } })
        pcall(vim.treesitter.language.register, "rust", "ron")
        -- BufWinEnter fires after BufReadPost (after nvim-treesitter processes the buffer)
        vim.api.nvim_create_autocmd("BufWinEnter", {
            pattern = "*.ron",
            callback = function(args)
                if not vim.treesitter.highlighter.active[args.buf] then
                    pcall(vim.treesitter.start, args.buf, "rust")
                end
            end,
        })
    end,
    config = function()
        local ok, configs = pcall(require, "nvim-treesitter.configs")
        if not ok then
            return
        end
        configs.setup(get_treesitter_config())
    end,
}
