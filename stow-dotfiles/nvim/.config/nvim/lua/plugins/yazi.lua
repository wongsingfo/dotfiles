require("yazi").setup({
	-- if you want to open yazi instead of netrw, see below for more info
	open_for_directories = false,
})

vim.keymap.set("n", "-", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })
