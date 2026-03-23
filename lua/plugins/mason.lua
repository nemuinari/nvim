-- ========================================
-- Mason: LSP / Tool Installer
-- ========================================

local MASON_TOOLS = {
    "stylua",
    "prettier",
    "black",
    "isort",
    "rustfmt",
    "clang-format",
    "shfmt",
    "taplo",
    "stylelint",
}

local function setup_windows_path()
    if vim.fn.has("win32") == 0 then
        return
    end

    local mason_bin = vim.fn.stdpath("data") .. "\\mason\\bin"
    local current_path = vim.env.PATH or ""

    if not current_path:find(mason_bin, 1, true) then
        vim.env.PATH = mason_bin .. ";" .. current_path
    end
end

return {
    -- Mason.nvim
    {
        "williamboman/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
        opts = {
            ui = { border = "rounded" },
            PATH = "append",
        },
        config = function(_, opts)
            require("mason").setup(opts)
            setup_windows_path()
        end,
    },

    -- Mason Tool Installer
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = MASON_TOOLS,
                run_on_start = false,
                start_delay = 3000,
            })
        end,
    },
}
