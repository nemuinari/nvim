-- ========================================
-- LSP Configuration
-- ========================================

local LSP_SERVERS = {
    clangd = {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    },
    pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
    },
    html = {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html", "javascriptreact", "typescriptreact" },
    },
    cssls = {
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = { "css", "scss", "less" },
    },
    emmet_ls = {
        cmd = { "emmet-ls", "--stdio" },
        filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "rust" },
    },
    rust_analyzer = {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = true,
                check = { command = "clippy" },
                procMacro = {
                    enable = true,
                    ignored = {
                        ["async-trait"] = { "async_trait" },
                        ["napi-derive"] = { "napi" },
                        ["async-recursion"] = { "async_recursion" },
                    },
                },
                cargo = {
                    buildScripts = { enable = true },
                },
                diagnostics = {
                    enable = true,
                },
            },
        },
    },
    lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                telemetry = { enable = false },
                hint = { enable = true },
            },
        },
    },
}

-- ========================================
-- Helpers
-- ========================================

local function build_lsp_filetypes()
    local filetypes = {}
    local seen = {}
    for _, server in pairs(LSP_SERVERS) do
        if type(server.filetypes) == "table" then
            for _, ft in ipairs(server.filetypes) do
                if not seen[ft] then
                    seen[ft] = true
                    table.insert(filetypes, ft)
                end
            end
        end
    end
    return filetypes
end

local function setup_lsp_keymaps(bufnr)
    local opts = { buffer = bufnr, silent = true }
    local map = vim.keymap.set

    map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Show hover documentation" }))
    map("n", "<space>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
    map("n", "<space>f", function()
        vim.lsp.buf.format({ async = true })
    end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
end

local function setup_inlay_hints(bufnr)
    if not vim.lsp.inlay_hint then
        return
    end
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
end

local function on_lsp_attach(event)
    local bufnr = event.buf
    setup_lsp_keymaps(bufnr)
    setup_inlay_hints(bufnr)
    -- Disable auto comment continuation on new line
    vim.bo[bufnr].formatoptions = vim.bo[bufnr].formatoptions:gsub("[or]", "")
end

-- ========================================
-- Plugin Specification
-- ========================================

return {
    "neovim/nvim-lspconfig",
    ft = build_lsp_filetypes(),
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        vim.g.lspconfig_silent_deprecation = true

        local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        local capabilities = has_cmp and cmp_nvim_lsp.default_capabilities()
            or vim.lsp.protocol.make_client_capabilities()

        require("mason-lspconfig").setup({
            ensure_installed = vim.tbl_keys(LSP_SERVERS),
            automatic_installation = true,
        })

        local util = require("lspconfig.util")
        local is_nvim_0_11 = vim.fn.has("nvim-0.11") == 1
        local autostart_group

        local function start_lsp_for_buf(server_name, server_opts, bufnr)
            if not vim.api.nvim_buf_is_loaded(bufnr) then
                return
            end

            local ft = vim.bo[bufnr].filetype
            if ft == "" then
                return
            end

            if server_opts.filetypes and not vim.tbl_contains(server_opts.filetypes, ft) then
                return
            end

            local existing = vim.lsp.get_clients({ bufnr = bufnr, name = server_name })
            if existing and #existing > 0 then
                return
            end

            local root_dir = server_opts.root_dir
            if type(root_dir) == "function" then
                root_dir = root_dir(vim.api.nvim_buf_get_name(bufnr))
            end
            if not root_dir then
                return
            end

            local config = vim.tbl_extend("force", server_opts, { name = server_name, root_dir = root_dir })
            vim.lsp.start(config, { bufnr = bufnr })
        end

        for server_name, server_opts in pairs(LSP_SERVERS) do
            server_opts.capabilities = capabilities
            server_opts.name = server_name

            if not server_opts.root_dir then
                if server_name == "rust_analyzer" then
                    server_opts.root_dir = util.root_pattern("Cargo.toml", "rust-project.json")
                else
                    server_opts.root_dir = function(fname)
                        return util.root_pattern("Cargo.toml", ".git", "package.json", "init.lua")(fname)
                            or vim.fn.getcwd()
                    end
                end
            end

            if is_nvim_0_11 then
                autostart_group = autostart_group
                    or vim.api.nvim_create_augroup("UserLspAutoStart", { clear = true })

                vim.lsp.config(server_name, server_opts)

                vim.api.nvim_create_autocmd("FileType", {
                    group = autostart_group,
                    pattern = server_opts.filetypes,
                    callback = function(args)
                        start_lsp_for_buf(server_name, server_opts, args.buf)
                    end,
                    desc = "Start LSP for " .. server_name,
                })

                for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                    start_lsp_for_buf(server_name, server_opts, bufnr)
                end
            else
                require("lspconfig")[server_name].setup(server_opts)
            end
        end

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
            callback = on_lsp_attach,
        })
    end,
}
