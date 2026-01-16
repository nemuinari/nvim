-- Description: Neovim configuration for conform.nvim to format
return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("conform").setup({
            formatters = {
                clang_format = { exe = "clang-format" },
                rustfmt = { exe = "rustfmt" },
                prettier = { exe = "prettier" },
            },

            formatters_by_ft = {
                -- Lua
                lua = { "stylua" },

                -- Rust
                rust = { "rustfmt" },

                -- Python
                python = { "black", "isort" },

                -- JavaScript / TypeScript
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },

                -- Web / markup
                html = { "prettier" },
                css = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },

                -- C / C++
                c = { "clang_format" },
                cpp = { "clang_format" },

                -- Shell
                sh = { "shfmt" },
                bash = { "shfmt" },

                -- その他
                toml = { "taplo" },
            },

            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        })
    end,
}
