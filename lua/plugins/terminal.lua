-- Constants
local COPILOT_PATTERNS = { "github/gh%-copilot", "githubnext/gh%-copilot", "copilot" }
local COPILOT_WELCOME_MSG = "gh copilot --banner\n"
local TOGGLETERM_PATTERN = "term://*#toggleterm#*"

-- State
local copilot_cli_tab

-- Helper functions
local function setup_terminal_window()
	vim.opt_local.winbar = ""
	vim.opt_local.buflisted = false
end

local function check_copilot_cli_available()
	-- Check standalone copilot binary
	if vim.fn.executable("copilot") == 1 then
		return true
	end

	-- Check gh CLI
	if vim.fn.executable("gh") ~= 1 then
		return false, "gh が見つかりません"
	end

	-- Check gh copilot extension
	local ok, extensions = pcall(vim.fn.systemlist, { "gh", "extension", "list" })
	if not ok then
		return false, "gh extension list 実行に失敗"
	end

	for _, line in ipairs(extensions) do
		for _, pattern in ipairs(COPILOT_PATTERNS) do
			if line:match(pattern) then
				return true
			end
		end
	end

	return false, "Copilot CLI 拡張が未インストール"
end

local function create_copilot_terminal()
	local Terminal = require("toggleterm.terminal").Terminal
	local use_standalone = vim.fn.executable("copilot") == 1

	local config = {
		cmd = use_standalone and "copilot --banner" or "gh copilot --banner",
		direction = "float",
		close_on_exit = false,
		hidden = true,
		display_name = "Copilot CLI",
		float_opts = {
			border = "none",
			width = vim.o.columns,
			height = vim.o.lines,
			winblend = 0,
		},
		on_open = function(term)
			setup_terminal_window()
			-- フローティングウィンドウを最大化
			vim.cmd("startinsert!")
		end,
	}

	return Terminal:new(config)
end

-- Public functions
local function open_copilot()
	local ok, msg = check_copilot_cli_available()
	if not ok then
		vim.notify(
			"Copilot CLI を起動できません: " .. msg .. "\nインストール: gh extension install github/gh-copilot",
			vim.log.levels.ERROR
		)
		return
	end

	if not copilot_cli_tab then
		copilot_cli_tab = create_copilot_terminal()
	end

	copilot_cli_tab:toggle()
end

local function close_copilot()
	if copilot_cli_tab and copilot_cli_tab:is_open() then
		copilot_cli_tab:close()
	end
end

local function setup_terminal_autocmds()
	-- Clean up terminal appearance
	vim.api.nvim_create_autocmd("TermOpen", {
		pattern = TOGGLETERM_PATTERN,
		callback = function()
			-- Disable lualine components
			vim.b.lualine_disable_statusline = true
			vim.b.lualine_disable_winbar = true

			-- Hide UI elements
			vim.opt_local.statusline = ""
			vim.opt_local.winbar = ""
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
			vim.opt_local.signcolumn = "no"
			vim.opt_local.buflisted = false
		end,
	})

end

local function setup_terminal_keymaps()
	-- Terminal window resize keymaps
	vim.keymap.set("t", "<C-j>", [[<C-\><C-n>:resize -1<CR>i]], {
		desc = "Shrink terminal height",
		silent = true,
	})
	vim.keymap.set("t", "<C-k>", [[<C-\><C-n>:resize +1<CR>i]], {
		desc = "Grow terminal height",
		silent = true,
	})
end

-- Plugin configuration
return {
	"akinsho/toggleterm.nvim",
	version = "*",
	keys = {
		{ "<leader>cc", open_copilot, desc = "Copilot CLI を開く" },
		{ "<leader>cx", close_copilot, desc = "Copilot CLI を閉じる" },
		{
			"<C-t>",
			function()
				vim.cmd("ToggleTerm direction=horizontal")
			end,
			mode = { "n", "t" },
			desc = "Toggle terminal",
		},
	},
	config = function()
		require("toggleterm").setup({
			shell = vim.o.shell,
			size = 6,
			open_mapping = "<C-t>",
			direction = "horizontal",
		})

		setup_terminal_keymaps()
		setup_terminal_autocmds()
	end,
}