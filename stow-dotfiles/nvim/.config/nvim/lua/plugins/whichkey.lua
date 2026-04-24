require("which-key").setup({
	---@type wk.Win.opts
	win = {
		-- don't allow the popup to overlap with the cursor
		no_overlap = true,
		border = "rounded",
		padding = { 0, 1 },
		title = true,
		title_pos = "center",
		zindex = 1000,
		bo = {},
		wo = {},
	},
})
