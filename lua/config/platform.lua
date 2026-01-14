-- C++/C用clang-formatスタイル判定
function M.clang_style(fallback)
	local platform = M.get_platform()
	if platform.is_windows or platform.is_wsl then
		return fallback
	end
	return "file"
end
-- platform.lua: Windows/WSL判定とクリップボード最適化
local M = {}
local cache = {}

function M.has(cmd)
	return vim.fn.executable(cmd) == 1
end

function M.get_platform()
	if cache.platform then return cache.platform end
	local platform = {
		is_windows = vim.fn.has("win32") == 1,
		is_wsl = vim.fn.has("wsl") == 1,
	}
	cache.platform = platform
	return platform
end

function M.clipboard()
	if cache.clipboard ~= nil then return cache.clipboard end
	local platform = M.get_platform()
	if platform.is_wsl and M.has("win32yank.exe") then
		cache.clipboard = {
			name = "win32yank-wsl",
			copy = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
			paste = { ["+"] = "win32yank.exe -o --lf", ["*"] = "win32yank.exe -o --lf" },
			cache_enabled = 1,
		}
		return cache.clipboard
	end
	if M.has("wl-copy") and M.has("wl-paste") then
		cache.clipboard = {
			name = "wl-clipboard",
			copy = { ["+"] = "wl-copy --foreground --type text/plain", ["*"] = "" },
			paste = { ["+"] = "wl-paste --no-newline", ["*"] = "" },
			cache_enabled = 0,
		}
		return cache.clipboard
	end
	if M.has("xclip") then
		cache.clipboard = {
			name = "xclip",
			copy = { ["+"] = "xclip -selection clipboard", ["*"] = "xclip -selection primary" },
			paste = { ["+"] = "xclip -selection clipboard -o", ["*"] = "xclip -selection primary -o" },
			cache_enabled = 0,
		}
		return cache.clipboard
	end
	if M.has("xsel") then
		cache.clipboard = {
			name = "xsel",
			copy = { ["+"] = "xsel --clipboard --input", ["*"] = "xsel --primary --input" },
			paste = { ["+"] = "xsel --clipboard --output", ["*"] = "xsel --primary --output" },
			cache_enabled = 0,
		}
		return cache.clipboard
	end
	return nil
end

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

return M
