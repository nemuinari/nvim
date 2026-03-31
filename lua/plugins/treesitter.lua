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

        -- FileType で確実にハイライト＋インデントを有効化する
        -- (BufWinEnter より FileType の方がタイミングが安定している)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "ron",
            callback = function(args)
                local buf = args.buf

                -- Treesitter ハイライトを起動 (未起動の場合のみ)
                if not vim.treesitter.highlighter.active[buf] then
                    pcall(vim.treesitter.start, buf, "rust")
                end

                -- nvim-treesitter のインデント関数を明示的に設定
                -- これにより <CR> での改行インデントと = での整形が機能する
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.bo[buf].indentexpr = "nvim_treesitter#indent()"
                        -- smartindent は treesitter indent と競合するため無効化
                        vim.bo[buf].smartindent = false
                    end
                end)
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
