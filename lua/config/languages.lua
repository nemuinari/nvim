local M = {}

local platform = require("config.platform")
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

  local g2 = vim.api.nvim_create_augroup("ClangFormatOnSave", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = g2,
    pattern = CLANG_PATTERNS,
    callback = function(ev)
      local bin = vim.g.clang_format_cmd or "clang-format"
      if vim.fn.executable(bin) ~= 1 then return end
      local name = vim.api.nvim_buf_get_name(ev.buf)
      if name == "" then return end
      local style = platform.clang_style(FALLBACK)
      local out = vim.fn.systemlist({ bin, "--style=" .. style, "--assume-filename=" .. name }, vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
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