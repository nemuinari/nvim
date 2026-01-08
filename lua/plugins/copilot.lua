-- Ensure Copilot CLI path is prioritized inside Neovim
if not (vim.env.PATH and vim.env.PATH:find("/home/yuki/.local/bin", 1, true)) then
  vim.env.PATH = "/home/yuki/.local/bin:" .. (vim.env.PATH or "")
end

local function _copilot_cmd()
  if vim.fn.executable("copilot") == 1 then return "copilot" end
  if vim.fn.filereadable("/home/yuki/.local/bin/copilot") == 1 then return "/home/yuki/.local/bin/copilot" end
  return "copilot"
end

-- Persistent Copilot CLI terminal buffer management
local copilot_cli = { bufnr = nil, job = nil }

local function _is_cli_visible()
  if not copilot_cli.bufnr or not vim.api.nvim_buf_is_valid(copilot_cli.bufnr) then return false end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == copilot_cli.bufnr then return true, win end
  end
  return false
end

local function _ensure_cli_buf()
  if copilot_cli.bufnr and vim.api.nvim_buf_is_valid(copilot_cli.bufnr) then return copilot_cli.bufnr end
  -- Create a terminal buffer attached to a temporary split, then close the view
  vim.cmd("botright split | enew")
  copilot_cli.bufnr = vim.api.nvim_get_current_buf()
  copilot_cli.job = vim.fn.termopen(_copilot_cmd(), { cwd = vim.fn.getcwd() })
  vim.cmd("quit")
  return copilot_cli.bufnr
end

-- Show in a new tab (reusing buffer if exists)
local function _show_cli_in_tab()
  _ensure_cli_buf()
  local visible = _is_cli_visible()
  if visible then return end
  vim.cmd("tabnew")
  vim.api.nvim_set_current_buf(copilot_cli.bufnr)
  vim.cmd("startinsert")
end

-- Show in horizontal split
local function _show_cli_in_hsplit()
  _ensure_cli_buf()
  local visible, _ = _is_cli_visible()
  if visible then
    return
  end
  vim.cmd("split")
  vim.api.nvim_set_current_buf(copilot_cli.bufnr)
  vim.cmd("startinsert")
end

-- Show in vertical split
local function _show_cli_in_vsplit()
  _ensure_cli_buf()
  local visible, _ = _is_cli_visible()
  if visible then
    return
  end
  vim.cmd("vsplit")
  vim.api.nvim_set_current_buf(copilot_cli.bufnr)
  vim.cmd("startinsert")
end

-- Close/hide all windows showing the CLI (buffer stays alive)
local function _close_cli()
  if not copilot_cli.bufnr or not vim.api.nvim_buf_is_valid(copilot_cli.bufnr) then return end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == copilot_cli.bufnr then pcall(vim.api.nvim_win_close, win, true) end
  end
end

-- Kill session: close windows, stop job, delete buffer
local function _kill_cli()
  _close_cli()
  if copilot_cli.job and copilot_cli.job > 0 then pcall(vim.fn.jobstop, copilot_cli.job) end
  if copilot_cli.bufnr and vim.api.nvim_buf_is_valid(copilot_cli.bufnr) then pcall(vim.api.nvim_buf_delete, copilot_cli.bufnr, { force = true }) end
  copilot_cli.bufnr = nil
  copilot_cli.job = nil
end

-- Toggle: show in tab if hidden, otherwise hide
local function _toggle_cli_tab()
  local visible = _is_cli_visible()
  if visible then _close_cli() else _show_cli_in_tab() end
end

return {
  {
    "github/copilot.vim",
    keys = {
      { "<leader>cc", _toggle_cli_tab, desc = "Copilot CLI (toggle tab)" },
      { "<leader>cx", _kill_cli,       desc = "Copilot CLI (close session)" },
    },
    config = function()
      vim.g.copilot_enabled = 1
    end,
  },
}
