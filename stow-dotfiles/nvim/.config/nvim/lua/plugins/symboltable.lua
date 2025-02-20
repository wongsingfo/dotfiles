return {
	'stevearc/aerial.nvim',
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons"
	},
	config = function()
		require("aerial").setup {
			-- Set to false to display all symbols.
			filter_kind = false,
			filter_kind = {
				-- Default
				"Class",
				"Constructor",
				"Enum",
				"Function",
				"Interface",
				"Module",
				"Method",
				"Struct",

				-- Additional
				-- To see all available values, see :help SymbolKind	
				-- "Variable",
			},
		}
		vim.keymap.set("n", "<leader>gs", "<cmd>AerialToggle!<CR>")
	end
}
