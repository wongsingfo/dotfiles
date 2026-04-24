require("aerial").setup({
	-- Set to false to display all symbols.
	filter_kind = {
		"Class",
		"Constructor",
		"Enum",
		"Function",
		"Interface",
		"Module",
		"Method",
		"Struct",
	},
})
vim.keymap.set("n", "<leader>gs", "<cmd>AerialToggle!<CR>")
