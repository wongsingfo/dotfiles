return {
	'echasnovski/mini.nvim',
	version = '*',
	config = function()
		require('mini.notify').setup()
		require('mini.pick').setup()
		require('mini.sessions').setup()
	end
}
