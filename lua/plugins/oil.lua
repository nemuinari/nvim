-- ========================================
-- Oil Configuration
-- ========================================

return {
	"stevearc/oil.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope.nvim",
	},
	cmd = "Oil",
	keys = {
		{ "<leader>e", "<CMD>Oil --float<CR>", desc = "Open file explorer" },
	},
	config = function()
		local oil = require("oil")

		oil.setup({
			default_file_explorer = true,
			watch_for_changes = true,
			skip_confirm_for_simple_edits = true,

			columns = {
				"icon",
			},

			float = {
				padding = 4,
				max_width = 80,
				max_height = 0.7,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
			},

			view_options = {
				show_hidden = true,
				is_hidden_file = function(name, bufnr)
					return vim.startswith(name, ".")
				end,
				highlight_filenames = true,
			},

			-- Custom Keymaps
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",

				-- ========================================
				-- Custom Grep Integration
				-- ========================================
				["<leader>g"] = {
					callback = function()
						local current_dir = require("oil").get_current_dir()
						if not current_dir then
							return
						end

						require("telescope.builtin").live_grep({
							cwd = current_dir,
							prompt_title = "Grep in: " .. current_dir,
						})
					end,
					desc = "Grep in this directory",
				},
			},

			cleanup_delay_ms = 2000,
		})

		-- Auto-close dashboard when entering oil buffer
		local group = vim.api.nvim_create_augroup("oil_custom", { clear = true })
		vim.api.nvim_create_autocmd("BufEnter", {
			group = group,
			pattern = "oil://*",
			callback = function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.bo[buf].filetype == "dashboard" then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end
			end,
		})
	end,
}
