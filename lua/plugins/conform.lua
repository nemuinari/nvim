-- ========================================
-- Conform.nvim: Universal Formatter
-- ========================================

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },

	opts = {
		-- ----------------------------------------
		-- formatter configuration per filetype
		-- ----------------------------------------
		formatters_by_ft = {
			-- Lua / Rust / Python
			lua = { "stylua" },
			rust = { "rustfmt" },
			python = { "isort", "black" },

			-- JavaScript / TypeScript
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },

			-- Web: Prettier
			html = { "prettier" },
			css = { "prettier" },
			json = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },

			-- C / C++: clang-format
			c = { "clang-format" },
			cpp = { "clang-format" },

			-- Shell Script: shfmt
			sh = { "shfmt" },

			-- TOML: taplo
			toml = { "taplo" },
		},

		-- ----------------------------------------
		-- options for formatting on save
		-- ----------------------------------------
		format_on_save = function(bufnr)
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname:match("/node_modules/") then
				return
			end

			return {
				timeout_ms = 2000,
				lsp_fallback = true,
			}
		end,

		-- ----------------------------------------
		-- formatter specific optionsk
		-- ----------------------------------------
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2" },
			},
			-- add more formatter specific options here
		},
	},
}
