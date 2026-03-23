-- ========================================
-- Editing Utilities: Comment + Auto-pairs
-- ========================================

return {
    -- Comment toggle: gcc (line), gc + motion (range)
    {
        "echasnovski/mini.comment",
        event = "VeryLazy",
        config = function()
            require("mini.comment").setup()
        end,
    },

    -- Auto-close brackets and quotes
    {
        "echasnovski/mini.pairs",
        event = "InsertEnter",
        config = function()
            require("mini.pairs").setup()
        end,
    },
}
