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

-- Simple :q wrapper that force-quits all unnamed buffers first
vim.api.nvim_create_user_command('Q', function()
	-- 1) 無名バッファを強制削除
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local name = vim.api.nvim_buf_get_name(buf)
			if name == "" then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end
	end
	-- 2) 通常の quit を試み、失敗したら quit! にフォールバック
	local ok = pcall(vim.cmd, 'quit')
	if not ok then
		pcall(vim.cmd, 'quit!')
	end
end, {})

-- Map :q to :Q
vim.cmd('cnoreabbrev <expr> q getcmdtype() == ":" && getcmdline() == "q" ? "Q" : "q"')
vim.cmd('cnoreabbrev <expr> wq getcmdtype() == ":" && getcmdline() == "wq" ? "w<bar>Q" : "wq"')
