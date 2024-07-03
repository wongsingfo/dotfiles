local keymap = vim.keymap.set
return {
	"ojroques/nvim-osc52",
	config = function()
		local osc52 = require('osc52')
		keymap('n', '<leader>c', osc52.copy_operator, { expr = true })
		keymap('n', '<leader>cc', '<leader>c_', { remap = true })
		keymap('v', '<leader>c', osc52.copy_visual)
	end
}
