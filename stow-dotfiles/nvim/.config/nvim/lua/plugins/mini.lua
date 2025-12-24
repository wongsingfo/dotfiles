return {
	'nvim-mini/mini.nvim',
	version = '*',
	config = function()
		-- https://nvim-mini.org/mini.nvim/
		require('mini.notify').setup()
		require('mini.pick').setup()
		require('mini.sessions').setup()
		require('mini.comment').setup()
		require('mini.surround').setup()
	end
}
