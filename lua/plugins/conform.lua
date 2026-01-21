-- ========================================
-- Conform.nvim: フォーマッター設定
-- ========================================

return {
	"stevearc/conform.nvim",
	-- ファイル保存直前に実行
	event = { "BufWritePre" },
	-- コマンドからも実行可能
	cmd = { "ConformInfo" },

	opts = {
		-- ----------------------------------------
		-- 言語別フォーマッターの定義
		-- ----------------------------------------
		formatters_by_ft = {
			-- Lua / Rust / Python
			lua = { "stylua" },
			rust = { "rustfmt" },
			python = { "isort", "black" },

			-- JavaScript / TypeScript
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },

			-- Web関連: Prettier
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
		-- 保存時の自動実行設定
		-- ----------------------------------------
		format_on_save = function(bufnr)
			-- node_modules 内のファイルは除外
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname:match("/node_modules/") then
				return
			end

			return {
				timeout_ms = 500, -- 500ms以内に完了しない場合は中止
				lsp_fallback = true, -- フォーマッターがない場合は LSP で整形
			}
		end,

		-- ----------------------------------------
		-- フォーマッターごとの詳細オプション
		-- ----------------------------------------
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2" },
			},
			-- Prettier の挙動
			-- prettier = {
			--     condition = function(self, ctx)
			--         return vim.fs.find({ ".prettierrc" }, { path = ctx.filename, upward = true })[1]
			--     end,
			-- },
		},
	},
}
