return {
    -- バッファ内 Markdown レンダリング
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        keys = {
            {
                "<leader>mr",
                function()
                    local rm = require("render-markdown")
                    if require("render-markdown.state").enabled then
                        rm.disable()
                    else
                        rm.enable()
                    end
                end,
                desc = "Markdown Render Toggle",
            },
        },
        opts = {
            heading = { enabled = true },
            code = { enabled = true, style = "full" },
            bullet = { enabled = true },
            checkbox = { enabled = true },
            table = { enabled = true },
        },
    },

    -- ブラウザプレビュー
    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        build = "cd app && npm install",
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview (Browser)" },
        },
    },
}
