return {
	"akinsho/toggleterm.nvim",
	version = "*",
	lazy = false, -- Load immediately to ensure keymaps work
	config = function()
		local toggleterm = require("toggleterm")
		toggleterm.setup({
			shell = vim.o.shell,
			size = 6,
			open_mapping = "<C-t>",
			direction = "horizontal",
		})

		vim.keymap.set("t", "<C-j>", [[<C-\><C-n>:resize -1<CR>i]], {
			desc = "terminal: shrink height",
			silent = true,
		})

		vim.keymap.set("t", "<C-k>", [[<C-\><C-n>:resize +1<CR>i]], {
			desc = "terminal: grow height",
			silent = true,
		})

		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*#toggleterm#*",
			callback = function()
				vim.b.lualine_disable_statusline = true
				vim.b.lualine_disable_winbar = true
				vim.opt_local.statusline = ""
				vim.opt_local.winbar = ""
			end,
		})

		-- Copilot CLI terminal (tab) toggle with availability checks
		local Terminal = require("toggleterm.terminal").Terminal
		local copilot_cli_tab

		local function copilot_cli_available()
			-- Standalone `copilot` binary is preferred if present
			if vim.fn.executable("copilot") == 1 then
				return true
			end
			-- Fallback to gh extension
			if vim.fn.executable("gh") ~= 1 then
				return false, "gh が見つかりません"
			end
			local ok, out = pcall(vim.fn.systemlist, { "gh", "extension", "list" })
			if not ok then
				return false, "gh extension list 実行に失敗"
			end
			for _, line in ipairs(out) do
				if line:match("github/gh%-copilot") or line:match("githubnext/gh%-copilot") or line:match("copilot") then
					return true
				end
			end
			return false, "Copilot CLI 拡張が未インストール"
		end

		vim.keymap.set("n", "<leader>cc", function()
			local ok, msg = copilot_cli_available()
			if not ok then
				vim.notify(
					"Copilot CLI を起動できません: " .. msg .. "\nインストール: gh extension install github/gh-copilot",
					vim.log.levels.ERROR
				)
				return
			end
			if not copilot_cli_tab then
				local use_standalone = vim.fn.executable("copilot") == 1
				if use_standalone then
					-- 直接 Copilot CLI を起動（対話モード）
					copilot_cli_tab = Terminal:new({
						cmd = "copilot",
						direction = "tab",
						close_on_exit = false,
						hidden = true,
					})
				else
					-- 拡張のみの場合はシェルを開いて使い方を案内
					copilot_cli_tab = Terminal:new({
						cmd = vim.o.shell,
						direction = "tab",
						close_on_exit = false,
						hidden = true,
						on_open = function(term)
							term:send("echo 'Copilot CLI (gh extension) ready. Try: gh copilot suggest \"Install git\"'\n")
						end,
					})
				end
			end
			copilot_cli_tab:toggle()
		end, { desc = "Copilot CLI を開く", silent = true, noremap = true })

		vim.keymap.set("n", "<leader>cx", function()
			if copilot_cli_tab and copilot_cli_tab:is_open() then copilot_cli_tab:close() end
		end, { desc = "Copilot CLI を閉じる", silent = true, noremap = true })
	end,
}