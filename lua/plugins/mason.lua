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
					granularity = {
						group = "module",
					},
					prefix = "self",
				},
				cargo = {
					buildScripts = {
						enable = true,
					},
				},
				procMacro = {
					enable = true,
				},
				inlayHints = {
					typeHints = { enable = true },
				},
			},
		},
	},
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = {},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
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
	--	"ripgrep", -- for windows users, install manually due to antivirus false positive
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
	-- use new API if available
	if vim.lsp.inlay_hint and type(vim.lsp.inlay_hint.enable) == "function" then
		pcall(vim.lsp.inlay_hint.enable, enabled, { bufnr = bufnr })
		return
	end

	-- fallback to buffer method
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

	-- Avoid duplicate entries
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

			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(LSP_SERVERS),
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local lsp_configs = require("lspconfig.configs")
			local util = require("lspconfig.util")

			for server_name, server_opts in pairs(LSP_SERVERS) do
				server_opts.capabilities = capabilities

				if not server_opts.root_dir then
					server_opts.root_dir = function(fname)
						return util.root_pattern("Cargo.toml", ".git", "package.json", "init.lua")(fname)
							or vim.fn.getcwd()
					end
				end

				if lsp_configs[server_name] then
					lsp_configs[server_name].setup(server_opts)
				end
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = on_lsp_attach,
			})
		end,
	},
}
