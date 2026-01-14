require('config.leader')
require('config.bootstrap')

vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		local modules = {
			'config.options',
			'config.keybinds',
			'config.leader',
			'config.languages',
		}
		for _, mod in ipairs(modules) do
			local ok, err = pcall(require, mod)
			if not ok then
				print('Error loading '..mod..': '..tostring(err))
			end
		end
	end
})
