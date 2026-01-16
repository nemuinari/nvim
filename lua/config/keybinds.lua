-- ========================================
-- Terminal Mode Keybinds
-- ========================================
local function setup_terminal_keymaps()
	local term_maps = {
		{ key = "<Esc>", cmd = [[<C-\><C-n>]], desc = "Escape to normal mode" },
		{ key = "<C-h>", cmd = [[<C-\><C-n><C-w>h]], desc = "Move to left window" },
		{ key = "<C-j>", cmd = [[<C-\><C-n><C-w>j]], desc = "Move to bottom window" },
		{ key = "<C-k>", cmd = [[<C-\><C-n><C-w>k]], desc = "Move to top window" },
		{ key = "<C-l>", cmd = [[<C-\><C-n><C-w>l]], desc = "Move to right window" },
	}

	for _, map in ipairs(term_maps) do
		vim.keymap.set("t", map.key, map.cmd, { desc = map.desc })
	end
end

-- ========================================
-- File Path Copy Utilities
-- ========================================
local PATH_FORMATS = {
	rel = function(abs)
		return vim.fn.fnamemodify(abs, ":.")
	end,
	abs = function(abs)
		return abs
	end,
	win = function(abs)
		return abs:gsub("/", "\\")
	end,
}

local function copy_path(format)
	local abs_path = vim.fn.expand("%:p")

	if abs_path == "" then
		vim.notify("No file path to copy", vim.log.levels.WARN)
		return
	end

	local formatter = PATH_FORMATS[format]
	if not formatter then
		vim.notify("Unknown path format: " .. format, vim.log.levels.ERROR)
		return
	end

	local path = formatter(abs_path)
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end

local function setup_path_copy_keymaps()
	local copy_maps = {
		{ key = "<leader>cr", format = "rel", desc = "Copy relative path" },
		{ key = "<leader>ca", format = "abs", desc = "Copy absolute path" },
		{ key = "<leader>cw", format = "win", desc = "Copy Windows path" },
	}

	for _, map in ipairs(copy_maps) do
		vim.keymap.set("n", map.key, function()
			copy_path(map.format)
		end, { desc = map.desc })
	end
end

-- ========================================
-- Graceful Quit Command
-- ========================================
local function delete_unnamed_buffers()
	local deleted_count = 0

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == "" then
			local ok = pcall(vim.api.nvim_buf_delete, buf, { force = true })
			if ok then
				deleted_count = deleted_count + 1
			end
		end
	end

	return deleted_count
end

local function graceful_quit()
	delete_unnamed_buffers()

	local ok = pcall(vim.cmd, "quit")
	if not ok then
		pcall(vim.cmd, "quit!")
	end
end

local function setup_quit_command()
	vim.api.nvim_create_user_command("Q", graceful_quit, {
		desc = "Graceful quit (deletes unnamed buffers, force quit if needed)",
	})
end

-- ========================================
-- Main Setup
-- ========================================
local M = {}
function M.setup()
  setup_terminal_keymaps()
  setup_path_copy_keymaps()
  setup_quit_command()
end
return M
