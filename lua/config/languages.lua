-- ========================================
-- Languages Indent Configuration
-- ========================================
local M = {}

local INDENTS = {
    c = 4,
    cpp = 4,
    rust = 4,
    python = 4,
    lua = 4,
    ron = 4,
    javascript = 2,
    typescript = 2,
    json = 2,
    html = 2,
    css = 2,
}

function M.setup()
    -- filetype 検出
    vim.filetype.add({
        extension = { ron = "ron" },
    })

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "BufWinEnter" }, {
        pattern = "*.ron",
        callback = function(args)
            vim.schedule(function()
                vim.schedule(function()
                    if vim.treesitter.highlighter.active[args.buf] then
                        return
                    end
                    pcall(vim.treesitter.start, args.buf, "rust")
                end)
            end)
        end,
    })

    local group = vim.api.nvim_create_augroup("LangIndent", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = vim.tbl_keys(INDENTS),
        callback = function(ev)
            local sw = INDENTS[ev.match]
            vim.opt_local.shiftwidth = sw
            vim.opt_local.tabstop = sw
            vim.opt_local.expandtab = true
        end,
    })
end

return M
