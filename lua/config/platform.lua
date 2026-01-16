local M = {}

-- キャッシュストレージ
local cache = {
  platform = nil,
  clipboard = nil,
}

-- プラットフォーム検出
function M.get_platform()
  if cache.platform then
    return cache.platform
  end

  cache.platform = {
    is_windows = vim.fn.has("win32") == 1,
    is_wsl = vim.fn.has("wsl") == 1,
  }

  return cache.platform
end

-- コマンド存在チェック
function M.has(cmd)
  return vim.fn.executable(cmd) == 1
end

-- clang-formatスタイル設定
function M.clang_style(fallback)
  local platform = M.get_platform()
  
  if platform.is_windows or platform.is_wsl then
    return fallback
  end
  
  return "file"
end

-- クリップボード設定のファクトリー関数
local function create_clipboard_config(name, copy_plus, copy_star, paste_plus, paste_star, cache_enabled)
  return {
    name = name,
    copy = {
      ["+"] = copy_plus,
      ["*"] = copy_star or "",
    },
    paste = {
      ["+"] = paste_plus,
      ["*"] = paste_star or "",
    },
    cache_enabled = cache_enabled or 0,
  }
end

-- クリップボード検出と設定
function M.clipboard()
  if cache.clipboard ~= nil then
    return cache.clipboard
  end

  local platform = M.get_platform()

  -- WSL + win32yank
  if platform.is_wsl and M.has("win32yank.exe") then
    cache.clipboard = create_clipboard_config(
      "win32yank-wsl",
      "win32yank.exe -i --crlf",
      "win32yank.exe -i --crlf",
      "win32yank.exe -o --lf",
      "win32yank.exe -o --lf",
      1
    )
    return cache.clipboard
  end

  -- Wayland clipboard (wl-clipboard)
  if M.has("wl-copy") and M.has("wl-paste") then
    cache.clipboard = create_clipboard_config(
      "wl-clipboard",
      "wl-copy --foreground --type text/plain",
      nil,
      "wl-paste --no-newline",
      nil,
      0
    )
    return cache.clipboard
  end

  -- X11 clipboard (xclip)
  if M.has("xclip") then
    cache.clipboard = create_clipboard_config(
      "xclip",
      "xclip -selection clipboard",
      "xclip -selection primary",
      "xclip -selection clipboard -o",
      "xclip -selection primary -o",
      0
    )
    return cache.clipboard
  end

  -- X11 clipboard (xsel)
  if M.has("xsel") then
    cache.clipboard = create_clipboard_config(
      "xsel",
      "xsel --clipboard --input",
      "xsel --primary --input",
      "xsel --clipboard --output",
      "xsel --primary --output",
      0
    )
    return cache.clipboard
  end

  -- フォールバック: クリップボード未検出
  cache.clipboard = false
  return nil
end

-- シェル設定
function M.shell()
  local platform = M.get_platform()

  if platform.is_windows then
    return {
      shell = "powershell",
      shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command",
      shellredir = ">",
      shellpipe = "| Out-File -Encoding UTF8",
    }
  end

  return nil
end

-- キャッシュクリア（デバッグ用）
function M.clear_cache()
  cache.platform = nil
  cache.clipboard = nil
end

return M
