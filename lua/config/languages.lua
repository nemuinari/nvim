local M = {}

local ok, platform = pcall(require, "config.platform")
local INDENTS = { rust = 4, python = 4, lua = 2, javascript = 2, typescript = 2, json = 2 }
local CLANG_PATTERNS = { "*.c", "*.cc", "*.cpp", "*.cxx", "*.h", "*.hh", "*.hpp", "*.hxx" }
local RUST_PATTERNS = { "*.rs" }
local FALLBACK = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "plugins", ".clang-format"))

function M.setup()
  local g1 = vim.api.nvim_create_augroup("LanguageConfig", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = g1,
    pattern = vim.tbl_keys(INDENTS),
    callback = function(ev)
      local indent = INDENTS[ev.match]
      if not indent then return end
      vim.opt_local.shiftwidth = indent
      vim.opt_local.tabstop = indent
    end,
  })

  -- LSP対応バッファで保存時に自動フォーマット
  local g_lsp = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = g_lsp,
    callback = function()
      if vim.lsp.buf.server_ready and vim.lsp.buf.server_ready() then
        pcall(function()
          vim.lsp.buf.format({ async = false })
        end)
      end
    end,
  })

  local g2 = vim.api.nvim_create_augroup("ClangFormatOnSave", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = g2,
    pattern = CLANG_PATTERNS,
    callback = function(ev)
      local bin = vim.g.clang_format_cmd or "clang-format"
      if vim.fn.executable(bin) ~= 1 then return end
      local name = vim.api.nvim_buf_get_name(ev.buf)
      if name == "" then return end
      local style = "file"
      local assume_filename = FALLBACK
      if ok and platform and type(platform.clang_style) == "function" then
        style = platform.clang_style("file")
      end
      local out = vim.fn.systemlist({ bin, "--style=" .. style, "--assume-filename=" .. assume_filename }, vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
      if vim.v.shell_error ~= 0 then return end
      local view = vim.fn.winsaveview()
      vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, out)
      vim.fn.winrestview(view)
    end,
  })

  local g3 = vim.api.nvim_create_augroup("RustFormatOnSave", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = g3,
    pattern = RUST_PATTERNS,
    callback = function(ev)
      local bin = vim.g.rustfmt_cmd or "rustfmt"
      if vim.fn.executable(bin) ~= 1 then return end
      local name = vim.api.nvim_buf_get_name(ev.buf)
      if name == "" then return end
      local out = vim.fn.systemlist({ bin, "--emit=stdout", "--quiet" }, vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
      if vim.v.shell_error ~= 0 then return end
      local view = vim.fn.winsaveview()
      vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, out)
      vim.fn.winrestview(view)
    end,
  })
end

return M