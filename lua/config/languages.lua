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
	javascript = 4,
	typescript = 4,
	json = 4,
}

function M.setup()
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
