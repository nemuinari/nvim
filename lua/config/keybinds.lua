-- ========================================
-- Keybinds Configuration
-- ========================================

local M = {}

-- ========================================
-- Terminal Mode Keybinds
-- ========================================

local function setup_terminal_keymaps()
	local opts = { silent = true }
	local term_maps = {
		{ "t", "<Esc>", [[<C-\><C-n>]], "Escape to normal mode" },
		{ "t", "<C-h>", [[<C-\><C-n><C-w>h]], "Move to left window" },
		{ "t", "<C-j>", [[<C-\><C-n><C-w>j]], "Move to bottom window" },
		{ "t", "<C-k>", [[<C-\><C-n><C-w>k]], "Move to top window" },
		{ "t", "<C-l>", [[<C-\><C-n><C-w>l]], "Move to right window" },
	}

	for _, m in ipairs(term_maps) do
		vim.keymap.set(m[1], m[2], m[3], vim.tbl_extend("force", opts, { desc = m[4] }))
	end
end

-- ========================================
-- File Path Utilities
-- ========================================

-- Copy file path to clipboard
local function copy_path(mode)
	local path = vim.fn.expand("%:p")
	if path == "" then
		vim.notify("No file path to copy", vim.log.levels.WARN)
		return
	end

	if mode == "rel" then
		path = vim.fn.fnamemodify(path, ":.")
	elseif mode == "win" then
		path = path:gsub("/", "\\")
	end

	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path)
end

local function setup_path_copy_keymaps()
	local maps = {
		{ "<leader>cr", "rel", "Copy relative path" },
		{ "<leader>ca", "abs", "Copy absolute path" },
		{ "<leader>cw", "win", "Copy Windows path" },
	}

	for _, m in ipairs(maps) do
		vim.keymap.set("n", m[1], function()
			copy_path(m[2])
		end, { desc = m[3] })
	end
end

-- ========================================
-- Graceful Exit Command
-- ========================================

-- Gracefully quit Neovim, cleaning unnamed buffers
local function graceful_quit()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == "" then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
	-- Attempt to quit, notify if save is required
	local ok = pcall(vim.cmd, "quit")
	if not ok then
		vim.notify("Save required before quitting", vim.log.levels.WARN)
	end
end

local function setup_commands()
	vim.api.nvim_create_user_command("Q", graceful_quit, { desc = "Quit with cleaning unnamed buffers" })
end

-- ========================================
-- Main Setup
-- ========================================

function M.setup()
	setup_terminal_keymaps()
	setup_path_copy_keymaps()
	setup_commands()
end

return M
