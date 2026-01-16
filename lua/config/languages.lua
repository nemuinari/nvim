local M = {}

-- 定数定義
local INDENTS = {
	-- c, cpp is clang-format setting 2 spaces
	rust = 4,
	python = 4,
	lua = 2,
	javascript = 2,
	typescript = 2,
	json = 2,
}

local FILE_PATTERNS = {
	clang = { "*.c", "*.cc", "*.cpp", "*.cxx", "*.h", "*.hh", "*.hpp", "*.hxx" },
	rust = { "*.rs" },
}

-- ヘルパー関数
local function setup_indent()
	local group = vim.api.nvim_create_augroup("LanguageConfig", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = vim.tbl_keys(INDENTS),
		callback = function(ev)
			local indent = INDENTS[ev.match]
			if not indent then
				return
			end

			vim.opt_local.shiftwidth = indent
			vim.opt_local.tabstop = indent
		end,
	})
end

local function format_with_external_tool(bin, args, lines)
	if vim.fn.executable(bin) ~= 1 then
		return nil
	end

	local out = vim.fn.systemlist(vim.list_extend({ bin }, args), lines)
	if vim.v.shell_error ~= 0 then
		return nil
	end

	return out
end

local function apply_formatting(bufnr, formatted_lines)
	if not formatted_lines then
		return
	end

	local view = vim.fn.winsaveview()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
	vim.fn.winrestview(view)
end

local function setup_clang_format()
	local ok, platform = pcall(require, "config.platform")
	local group = vim.api.nvim_create_augroup("ClangFormatOnSave", { clear = true })

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		pattern = FILE_PATTERNS.clang,
		callback = function(ev)
			local bin = vim.g.clang_format_cmd or "clang-format"
			local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)

			local style = "file"
			if ok and platform and type(platform.clang_style) == "function" then
				style = platform.clang_style("file")
			end

			local formatted = format_with_external_tool(bin, { "--style=" .. style }, lines)
			apply_formatting(ev.buf, formatted)
		end,
	})
end

local function setup_rust_format()
	local group = vim.api.nvim_create_augroup("RustFormatOnSave", { clear = true })

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		pattern = FILE_PATTERNS.rust,
		callback = function(ev)
			local bin = vim.g.rustfmt_cmd or "rustfmt"
			local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)

			local formatted = format_with_external_tool(bin, { "--emit=stdout", "--quiet" }, lines)
			apply_formatting(ev.buf, formatted)
		end,
	})
end

local function setup_lsp_format()
	local group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		callback = function()
			if vim.lsp and vim.lsp.buf then
				pcall(vim.lsp.buf.format, { async = false })
			end
		end,
	})
end

-- メイン関数
function M.setup()
	setup_indent()

	local use_conform = vim.g.use_conform
	if use_conform == nil then
		use_conform = true
	end

	if not use_conform then
		setup_lsp_format()
		setup_clang_format()
		setup_rust_format()
	end
end

return M

