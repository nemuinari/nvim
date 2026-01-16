-- ========================================
-- LSP Server Configurations
-- ========================================
local LSP_SERVERS = {
	clangd = {},
	pyright = {},
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				checkOnSave = true,
				check = { command = "clippy" },
				inlayHints = {
					typeHints = { enable = true },
				},
			},
		},
	},
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = { vim.env.VIMRUNTIME },
					checkThirdParty = false,
				},
				telemetry = {
					enable = false,
				},
			},
		},
	},
}

-- ========================================
-- Mason Tools Configuration
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
}

-- ========================================
-- Keymaps Setup
-- ========================================
local function setup_lsp_keymaps(bufnr)
	local opts = { buffer = bufnr, silent = true }
	local keymap_configs = {
		{ "n", "gd", vim.lsp.buf.definition, "Go to definition" },
		{ "n", "K", vim.lsp.buf.hover, "Show hover documentation" },
		{
			"n",
			"<space>f",
			function()
				vim.lsp.buf.format({ async = true })
			end,
			"Format buffer",
		},
		{ "n", "<space>rn", vim.lsp.buf.rename, "Rename symbol" },
	}

	for _, config in ipairs(keymap_configs) do
		local mode, key, action, desc = config[1], config[2], config[3], config[4]
		vim.keymap.set(mode, key, action, vim.tbl_extend("force", opts, { desc = desc }))
	end
end

-- ========================================
-- Inlay Hints Setup
-- ========================================
local function set_inlay_hint(bufnr, enabled)
	-- Neovim 0.10+ の新しい API
	if vim.lsp.inlay_hint and type(vim.lsp.inlay_hint.enable) == "function" then
		pcall(vim.lsp.inlay_hint.enable, enabled, { bufnr = bufnr })
		return
	end

	-- 古い API のフォールバック
	if vim.lsp.buf and type(vim.lsp.buf.inlay_hint) == "function" then
		local ok = pcall(vim.lsp.buf.inlay_hint, bufnr, enabled)
		if not ok then
			pcall(vim.lsp.buf.inlay_hint, enabled)
		end
	end
end

local function create_inlay_hint_autocmds(bufnr)
	local group = vim.api.nvim_create_augroup("InlayHints" .. bufnr, { clear = true })

	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		buffer = bufnr,
		callback = function()
			set_inlay_hint(bufnr, false)
		end,
		desc = "Disable inlay hints in insert mode",
	})

	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		buffer = bufnr,
		callback = function()
			set_inlay_hint(bufnr, true)
		end,
		desc = "Enable inlay hints in normal mode",
	})

	vim.b[bufnr].inlay_hints_group = group
end

local function enable_inlay_hints(bufnr)
	vim.b[bufnr].inlay_hints_auto = true
	set_inlay_hint(bufnr, true)
	create_inlay_hint_autocmds(bufnr)
end

-- ========================================
-- Windows PATH Setup
-- ========================================
local function setup_windows_path()
	local is_windows = vim.fn.has("win32") == 1
	if not is_windows then
		return
	end

	local mason_bin = vim.fn.stdpath("data") .. "\\mason\\bin"
	local current_path = vim.env.PATH or ""

	-- 重複チェック
	if current_path:find(mason_bin, 1, true) then
		return
	end

	vim.env.PATH = mason_bin .. ";" .. current_path
end

-- ========================================
-- LSP Attach Handler
-- ========================================
local function on_lsp_attach(event)
	local bufnr = event.buf

	-- Setup keymaps
	setup_lsp_keymaps(bufnr)

	-- Enable inlay hints
	enable_inlay_hints(bufnr)

	-- Format options adjustment
	pcall(function()
		vim.opt_local.formatoptions:remove("o")
		vim.opt_local.formatoptions:remove("r")
	end)
end

-- ========================================
-- Plugin Configurations
-- ========================================
return {
	-- Mason core
	{
		"williamboman/mason.nvim",
		opts = {},
		config = function()
			local ok, mason = pcall(require, "mason")
			if not ok then
				return
			end

			mason.setup({
				ui = {
					border = "rounded",
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
				PATH = "append",
			})

			setup_windows_path()
		end,
	},

	-- Mason tool installer
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			local ok, installer = pcall(require, "mason-tool-installer")
			if not ok then
				return
			end

			installer.setup({
				ensure_installed = MASON_TOOLS,
				run_on_start = true,
				auto_update = false,
				start_delay = 3000,
				debounce_hours = 24,
			})
		end,
	},

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"williamboman/mason.nvim",
		},
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- Setup mason-lspconfig
			local ok_mason, mason_lspconfig = pcall(require, "mason-lspconfig")
			if ok_mason then
				mason_lspconfig.setup({
					ensure_installed = vim.tbl_keys(LSP_SERVERS),
				})
			end

			-- Setup LSP servers
			local ok_lsp, lspconfig = pcall(require, "lspconfig")
			if not ok_lsp then
				return
			end

			for server_name, server_opts in pairs(LSP_SERVERS) do
				server_opts.capabilities = capabilities
				lspconfig[server_name].setup(server_opts)
			end

			-- LSP attach autocmd
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = on_lsp_attach,
				desc = "Configure LSP keymaps and features on attach",
			})

			-- Load language-specific configurations
			local ok_langs, langs = pcall(require, "config.languages")
			if ok_langs and langs.setup then
				langs.setup()
			end
		end,
	},
}
