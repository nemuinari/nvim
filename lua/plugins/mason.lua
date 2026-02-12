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
				imports = {
					granularity = { group = "module" },
					prefix = "self",
				},
				cargo = {
					buildScripts = { enable = true },
				},
				procMacro = { enable = true },
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
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = { enable = false },
				hint = { enable = true }, -- lua inlay hints
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
-- Helper Functions
-- ========================================

-- Keymaps Setup
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

-- Inlay Hints Setup (Modern v0.10+ logic)
local function setup_inlay_hints(bufnr)
	-- Neovim 0.10+ is required for native inlay hints
	if not vim.lsp.inlay_hint then
		return
	end

	-- Helper to toggle hints
	local function set_hint(state)
		vim.lsp.inlay_hint.enable(state, { bufnr = bufnr })
	end

	-- Initial state: enable
	set_hint(true)

	-- Auto-toggle group: Disable in Insert mode, Enable in Normal mode
	local group = vim.api.nvim_create_augroup("LspInlayHints_" .. bufnr, { clear = true })

	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		buffer = bufnr,
		callback = function()
			set_hint(false)
		end,
		desc = "Disable inlay hints in insert mode",
	})

	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		buffer = bufnr,
		callback = function()
			set_hint(true)
		end,
		desc = "Enable inlay hints in normal mode",
	})
end

-- Windows PATH Setup
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

-- LSP Attach Handler
local function on_lsp_attach(event)
	local bufnr = event.buf

	-- Setup Keymaps
	setup_lsp_keymaps(bufnr)

	-- Setup Inlay Hints
	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if client and client.server_capabilities.inlayHintProvider then
		setup_inlay_hints(bufnr)
	end

	-- Format Options (Disable auto comment on new line)
	vim.bo[bufnr].formatoptions = vim.bo[bufnr].formatoptions:gsub("[or]", "")
end

-- ========================================
-- Plugin Configurations
-- ========================================
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

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			vim.g.lspconfig_silent_deprecation = true

			-- Capabilities Setup
			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			local capabilities = has_cmp and cmp_nvim_lsp.default_capabilities()
				or vim.lsp.protocol.make_client_capabilities()

			-- Mason LSP Config Setup
			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(LSP_SERVERS),
			})

			local util = require("lspconfig.util")
			local is_nvim_0_11 = vim.fn.has("nvim-0.11") == 1

			-- Iterate and Setup Servers
			for server_name, server_opts in pairs(LSP_SERVERS) do
				-- Merge Capabilities
				server_opts.capabilities = capabilities

				-- Root Directory Setup
				if not server_opts.root_dir then
					server_opts.root_dir = function(fname)
						return util.root_pattern("Cargo.toml", ".git", "package.json", "init.lua")(fname)
							or vim.fn.getcwd()
					end
				end

				-- Setup Server
				if is_nvim_0_11 then
					-- new API
					vim.lsp.config(server_name, server_opts)
					vim.lsp.enable(server_name)
				else
					-- old API
					require("lspconfig")[server_name].setup(server_opts)
				end
			end

			-- Global LspAttach Event
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = on_lsp_attach,
			})
		end,
	},
}
