local function setup_keymaps(buf)
	local opts = { buffer = buf }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<space>f", function() vim.lsp.buf.format({ async = true }) end, opts)
	vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
end

local function enable_inlay_hints(bufnr)
	if vim.lsp.buf and type(vim.lsp.buf.inlay_hint) == "function" then
		pcall(vim.lsp.buf.inlay_hint, bufnr, true)
		return
	end
	if vim.lsp.inlay_hint and type(vim.lsp.inlay_hint.enable) == "function" then
		pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
	end
end

local servers = {
	clangd = {},
	pyright = {},
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				checkOnSave = true,
				check = { command = "clippy" },
				inlayHints = {
					bindingModeHints = { enable = true },
					parameterHints = { enable = true },
					typeHints = { enable = true },
				},
			},
		},
	},
	lua_ls = {
		settings = {
			Lua = { diagnostics = { globals = { "vim" } } },
		},
	},
}

return {
	{ "williamboman/mason.nvim", opts = {} },
	{ "williamboman/mason-lspconfig.nvim" },
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		config = function()
			local capabilities = {}

			local ok_masonlsp, mason_lspconfig = pcall(require, "mason-lspconfig")
			if ok_masonlsp then
				mason_lspconfig.setup({ ensure_installed = vim.tbl_keys(servers) })
			end

			for name, opts in pairs(servers) do
				opts.capabilities = capabilities
				vim.lsp.config(name, opts)
			end
			vim.lsp.enable(vim.tbl_keys(servers))

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(ev)
					setup_keymaps(ev.buf)
					enable_inlay_hints(ev.buf)
				end,
			})

			local ok_langs, langs = pcall(require, "config.languages")
			if ok_langs and langs.setup then langs.setup() end
		end,
	},
}
