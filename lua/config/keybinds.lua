local term_opts = { desc = "" }
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], term_opts)
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], term_opts)
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], term_opts)
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], term_opts)
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], term_opts)

-- Copy current file path helpers
local function copy_path(fmt)
	local abs = vim.fn.expand("%:p")
	if abs == "" then return end
	local path = abs
	if fmt == "rel" then
		path = vim.fn.fnamemodify(abs, ":.")
	end
	if fmt == "win" then
		path = abs:gsub("/", "\\")
	end
	vim.fn.setreg('+', path)
	vim.fn.setreg('*', path)
	vim.notify("Copied path: " .. path)
end

vim.keymap.set('n', '<leader>cr', function() copy_path("rel") end, { desc = 'Copy relative path' })
vim.keymap.set('n', '<leader>ca', function() copy_path("abs") end, { desc = 'Copy absolute path' })
vim.keymap.set('n', '<leader>cw', function() copy_path("win") end, { desc = 'Copy Windows path' })
