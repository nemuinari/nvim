local M = {}

-- ========================================
-- Platform Detection
-- ========================================

local is_windows = jit.os == "Windows"
local is_wsl = not is_windows and vim.env.WSL_DISTRO_NAME ~= nil

M.info = {
	is_windows = is_windows,
	is_wsl = is_wsl,
	is_linux = jit.os == "Linux",
}

-- ========================================
-- Utility Functions
-- ========================================

local exe_cache = {}
function M.has(cmd)
	if exe_cache[cmd] == nil then
		exe_cache[cmd] = vim.fn.executable(cmd) == 1
	end
	return exe_cache[cmd]
end

-- ========================================
-- Clipboard Configuration
-- ========================================

local function detect_clipboard()
	-- WSL + win32yank
	if M.info.is_wsl and M.has("win32yank.exe") then
		return {
			name = "win32yank-wsl",
			copy = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
			paste = { ["+"] = "win32yank.exe -o --lf", ["*"] = "win32yank.exe -o --lf" },
			cache_enabled = 1,
		}
	end

	-- Wayland (wl-clipboard)
	if vim.env.WAYLAND_DISPLAY and M.has("wl-copy") then
		return {
			name = "wl-clipboard",
			copy = { ["+"] = "wl-copy --foreground --type text/plain" },
			paste = { ["+"] = "wl-paste --no-newline" },
		}
	end

	-- X11 (xclip / xsel)
	if vim.env.DISPLAY then
		if M.has("xclip") then
			return {
				name = "xclip",
				copy = { ["+"] = "xclip -selection clipboard", ["*"] = "xclip -selection primary" },
				paste = { ["+"] = "xclip -selection clipboard -o", ["*"] = "xclip -selection primary -o" },
			}
		elseif M.has("xsel") then
			return {
				name = "xsel",
				copy = { ["+"] = "xsel --clipboard --input", ["*"] = "xsel --primary --input" },
				paste = { ["+"] = "xsel --clipboard --output", ["*"] = "xsel --primary --output" },
			}
		end
	end
	return nil
end

local clipboard_cfg = detect_clipboard()
function M.clipboard()
	return clipboard_cfg
end

-- ========================================
-- Shell & External Tools
-- ========================================

function M.shell()
	if not M.info.is_windows then
		return nil
	end
	return {
		shell = "powershell",
		shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command",
		shellredir = ">",
		shellpipe = "| Out-File -Encoding UTF8",
	}
end

function M.clang_style(fallback)
	return (M.info.is_windows or M.info.is_wsl) and fallback or "file"
end

return M
