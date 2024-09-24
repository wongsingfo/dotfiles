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

		-- https://www.reddit.com/r/neovim/comments/18c9ycw/fixing_neovimtree_float_background_color/
		-- vim.api.nvim_set_hl(0, 'NormalFloat', { fg = 'none', bg = 'none' })
		-- https://github.com/nshern/neovim-default-colorscheme-extras
		vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NvimDarkGrey3'  })
		vim.api.nvim_set_hl(0, 'FloatTitle', { link = 'NormalFloat' })
	end
}
