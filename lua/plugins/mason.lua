local function setup_keymaps(buf)
	local opts = { buffer = buf }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<space>f", function() vim.lsp.buf.format({ async = true }) end, opts)
	vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
end

local function set_inlay(bufnr, enabled)
	if vim.lsp.buf and type(vim.lsp.buf.inlay_hint) == "function" then
		-- Neovim 0.10 signature: inlay_hint(bufnr, enabled)
		local ok = pcall(vim.lsp.buf.inlay_hint, bufnr, enabled)
		if not ok then pcall(vim.lsp.buf.inlay_hint, enabled) end
		return
	end
	if vim.lsp.inlay_hint and type(vim.lsp.inlay_hint.enable) == "function" then
		pcall(vim.lsp.inlay_hint.enable, enabled, { bufnr = bufnr })
	end
end

local function create_inlay_autocmds(bufnr)
	local gid = vim.api.nvim_create_augroup("InlayHints" .. bufnr, { clear = true })
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = gid,
		buffer = bufnr,
		callback = function() set_inlay(bufnr, false) end,
	})
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = gid,
		buffer = bufnr,
		callback = function() set_inlay(bufnr, true) end,
	})
	vim.b.inlay_hints_group = gid
end

local function enable_inlay_hints(bufnr)
	vim.b.inlay_hints_auto = true
	set_inlay(bufnr, true)
	create_inlay_autocmds(bufnr)
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
					-- Buffer-local toggle for auto inlay hints
					vim.keymap.set("n", "<leader>ih", function()
						if vim.b.inlay_hints_auto then
							vim.b.inlay_hints_auto = false
							local gid = vim.b.inlay_hints_group
							if gid then pcall(vim.api.nvim_del_augroup_by_id, gid) end
							set_inlay(ev.buf, false)
							vim.notify("Inlay hints: off")
						else
							enable_inlay_hints(ev.buf)
							vim.notify("Inlay hints: on (Normal=on, Insert=off)")
						end
					end, { buffer = ev.buf, desc = "Toggle inlay hints" })
				end,
			})

			local ok_langs, langs = pcall(require, "config.languages")
			if ok_langs and langs.setup then langs.setup() end
		end,
	},
}
