local function setup_folding()
	vim.o.foldmethod = "expr"
	vim.o.foldexpr = "nvim_treesitter#foldexpr()"
	vim.o.foldnestmax = 3
	vim.o.foldenable = false -- Disable folding at startup
end

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"c",
		"cpp",
		"lua",
		"markdown",
		"markdown_inline",
		"python",
		"rust",
		"vimdoc",
	},
	indent = { enable = true },
	matchup = { enable = true },
	highlight = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "vv",
			node_incremental = "v",
			scope_incremental = false,
			node_decremental = "u",
		},
	},
})

-- Fix: cursor line getting cut off by treesitter @operator highlight
local val = vim.api.nvim_get_hl(0, { name = "Normal" })
val.bg = nil
---@diagnostic disable-next-line: inject-field
val.ctermbg = nil
---@diagnostic disable-next-line: param-type-mismatch
vim.api.nvim_set_hl(0, "@operator", val)

setup_folding()

require("treesitter-context").setup({
	mode = "cursor",
	max_lines = 5,
})
