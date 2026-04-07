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
}
