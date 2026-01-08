local M = {}
local _cache = {}

M.is_win = vim.loop.os_uname().sysname == "Windows_NT"
M.is_wsl = vim.fn.has("wsl") == 1

function M.has(cmd)
	return vim.fn.executable(cmd) == 1
end

function M.clipboard()
	if _cache.clipboard ~= nil then return _cache.clipboard end
	if M.is_wsl and M.has("win32yank.exe") then
		return {
			name = "win32yank",
			copy = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
			paste = { ["+"] = "win32yank.exe -o --lf", ["*"] = "win32yank.exe -o --lf" },
			cache_enabled = 0,
		}
	end
	if M.has("wl-copy") and M.has("wl-paste") then
		_cache.clipboard = {
			name = "wl-clipboard",
			copy = { ["+"] = "wl-copy --foreground --type text/plain", ["*"] = "wl-copy --foreground --type text/plain" },
			paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --no-newline" },
			cache_enabled = 0,
		}
		return _cache.clipboard
	end
	if M.has("xclip") then
		_cache.clipboard = {
			name = "xclip",
			copy = { ["+"] = "xclip -selection clipboard", ["*"] = "xclip -selection primary" },
			paste = { ["+"] = "xclip -selection clipboard -o", ["*"] = "xclip -selection primary -o" },
			cache_enabled = 0,
		}
		return _cache.clipboard
	end
	if M.has("xsel") then
		_cache.clipboard = {
			name = "xsel",
			copy = { ["+"] = "xsel --clipboard --input", ["*"] = "xsel --primary --input" },
			paste = { ["+"] = "xsel --clipboard --output", ["*"] = "xsel --primary --output" },
			cache_enabled = 0,
		}
		return _cache.clipboard
	end
end

function M.shell()
	if _cache.shell ~= nil then return _cache.shell end
	if not M.is_win then return nil end
	local ps = M.has("pwsh") and "pwsh" or "powershell"
	_cache.shell = {
		shell = ps,
		shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
		shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
		shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; if($?) { cat %s } : { cat %s; exit 1 }",
	}
	return _cache.shell
end

function M.clang_style(fallback_path)
	if not fallback_path or fallback_path == "" then
		return "file"
	end
	if not vim.loop.fs_stat(fallback_path) then
		return "file"
	end
	return "file:" .. fallback_path:gsub("\\", "/")
end

return M
