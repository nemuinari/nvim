-- Terminal mode: Escape & window navigation
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = "Escape to normal mode" })
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], { desc = "Move to left window" })
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], { desc = "Move to bottom window" })
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], { desc = "Move to top window" })
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], { desc = "Move to right window" })

-- File path copying
local function copy_path(fmt)
	local abs = vim.fn.expand("%:p")
	if abs == "" then return end
	local path = fmt == "rel" and vim.fn.fnamemodify(abs, ":.") or fmt == "win" and abs:gsub("/", "\\") or abs
	vim.fn.setreg('+', path)
	vim.notify("Copied: " .. path)
end

vim.keymap.set('n', '<leader>cr', function() copy_path("rel") end, { desc = "Copy relative path" })
vim.keymap.set('n', '<leader>ca', function() copy_path("abs") end, { desc = "Copy absolute path" })
vim.keymap.set('n', '<leader>cw', function() copy_path("win") end, { desc = "Copy Windows path" })

-- Graceful :q wrapper (force-delete unnamed buffers, fallback to quit!)
vim.api.nvim_create_user_command('Q', function()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == "" then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
	local ok = pcall(vim.cmd, 'quit')
	if not ok then
		pcall(vim.cmd, 'quit!')
	end
end, {})
