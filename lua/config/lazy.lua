require("lazy").setup({
    spec = { { import = "plugins" } },
    change_detection = { notify = false },
    performance = {
        cache = { enabled = true },
        reset_packpath = true,
        rtp = {
            disabled_plugins = {
                "gzip",
                "editorconfig",
                "matchit",
                "matchparen",
                "man",
                "netrwPlugin",
                "osc52",
                "rplugin",
                "shada",
                "spellfile",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
