-- ========================================
-- LSP Server Configurations
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
	rust_analyzer = {
		cmd = { "rust-analyzer" },
		filetypes = { "rust" },
		settings = {
			["rust-analyzer"] = {
				checkOnSave = { command = "clippy" },
				imports = {
					granularity = { group = "module" },
					prefix = "self",
				},
				cargo = {
					buildScripts = { enable = true },
				},
				procMacro = { enable = true },
				-- Inlay hints are controlled client-side via vim.lsp.inlay_hint
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

-- Inlay Hints Setup (Neovim 0.10+)
local function setup_inlay_hints(bufnr)
	if not vim.lsp.inlay_hint then
		return
	end

	vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
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
	setup_inlay_hints(bufnr)

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
				automatic_installation = true,
			})

			local util = require("lspconfig.util")
			local is_nvim_0_11 = vim.fn.has("nvim-0.11") == 1
			local autostart_group

			-- Helper to start LSP for a specific buffer (Neovim 0.11+ only)
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

			-- Configure and Start Servers
			for server_name, server_opts in pairs(LSP_SERVERS) do
				-- Merge capabilities and name
				server_opts.capabilities = capabilities
				server_opts.name = server_name

				-- Configure root directory detection
				if not server_opts.root_dir then
					if server_name == "rust_analyzer" then
						-- Only start rust-analyzer in actual Rust projects
						server_opts.root_dir = util.root_pattern("Cargo.toml", "rust-project.json")
					else
						server_opts.root_dir = function(fname)
							return util.root_pattern("Cargo.toml", ".git", "package.json", "init.lua")(fname)
								or vim.fn.getcwd()
						end
					end
				end

				-- Setup Server
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

			-- Global LspAttach Event
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = on_lsp_attach,
			})
		end,
	},
}
