-- ========================================
-- Copilot.lua Configuration
-- ========================================
return {
	"zbirenbaum/copilot.lua",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 120,
				keymap = {
					accept = "<Tab>",
					accept_word = false,
					accept_line = false,
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			panel = {
				enabled = true,
				keymap = {
					open = "<M-/>",
					accept = "<CR>",
					refresh = "r",
					next = "j",
					prev = "k",
				},
			},
			filetypes = {
				markdown = false,
				help = false,
				gitcommit = false,
			},
		})
	end,
}
