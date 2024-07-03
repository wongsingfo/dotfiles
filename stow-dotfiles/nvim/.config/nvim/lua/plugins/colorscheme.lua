return {
	"morhetz/gruvbox",
	-- "jacoborus/tender.vim",
	-- "folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		-- https://github.com/morhetz/gruvbox/wiki/Configuration#ggruvbox_sign_column
		vim.g.gruvbox_sign_column = 'bg0'
		vim.cmd.colorscheme('gruvbox')
	end
}
