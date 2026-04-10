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
            rust = { "rustfmt", "leptosfmt", "dx_fmt" },
            ron = {},
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
        -- formatter specific options
        -- ----------------------------------------
        formatters = {
            leptosfmt = {
                condition = function(self, ctx)
                    return vim.fn.executable("leptosfmt") == 1
                end,
            },
            dx_fmt = {
                command = "dx",
                args = { "fmt", "-f", "$FILENAME" },
                stdin = false,
            },
            shfmt = {
                prepend_args = { "-i", "2" },
            },
        },
    },

    -- opts のみだと lazy.nvim が自動で setup() を呼ぶが、
    -- config を明示することで setup() 後に追加処理を挟める
    config = function(_, opts)
        require("conform").setup(opts)

        -- ----------------------------------------
        -- RON: ron-lsp のコメント末尾カンマ挿入バグの修正
        --
        -- ron-lsp (lsp_fallback) はフォーマット時に
        -- コメント行 (// ...) の末尾に , を挿入するバグがある。
        -- conform の BufWritePre ハンドラが setup() 内で登録されるため、
        -- ここで登録する autocmd は必ず conform の LSP フォーマット完了後に実行される。
        -- ----------------------------------------
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.ron",
            desc = "Remove trailing commas inserted by ron-lsp into comment lines",
            callback = function(args)
                local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
                local changed = false
                for i, line in ipairs(lines) do
                    -- コメント行 (先頭が空白 + //) の末尾にある , を除去
                    -- 例: "    // foo,"  →  "    // foo"
                    --     "// bar,,"    →  "// bar,"  (二重カンマも一段階ずつ修正される)
                    local fixed = line:gsub("^(%s*//.-),%s*$", "%1")
                    if fixed ~= line then
                        lines[i] = fixed
                        changed = true
                    end
                end
                if changed then
                    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
                end
            end,
        })
    end,
}
