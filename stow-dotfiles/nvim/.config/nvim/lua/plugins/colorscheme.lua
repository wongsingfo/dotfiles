local vim = vim

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

		-- https://github.com/nvim-treesitter/nvim-treesitter-context?tab=readme-ov-file#appearance
		local treecontext_bg = 'NvimDarkGrey1'
		vim.api.nvim_set_hl(0, 'TreesitterContext', { link = treecontext_bg })
		vim.api.nvim_set_hl(0, 'TreesitterContextSeparator', { link = treecontext_bg })

		-- Make the highlight compatible before the following commit
		-- Ref: https://github.com/neovim/neovim/pull/26658/commits
		vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Pmenu' })
	end
}
