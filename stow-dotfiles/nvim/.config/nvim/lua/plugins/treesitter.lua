-- Use nvim's built-in treesitter only.
-- nvim 0.12 bundles parsers for: c, lua, markdown, markdown_inline,
-- query, vim, vimdoc.  We turn highlighting on for those filetypes via
-- a FileType autocmd; everything else falls back to vim's regex syntax
-- highlighting.
local ft_to_lang = {
	c = "c",
	lua = "lua",
	markdown = "markdown",
	help = "vimdoc",
	vim = "vim",
	query = "query",
}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TreesitterEnable", { clear = true }),
	pattern = vim.tbl_keys(ft_to_lang),
	callback = function(ev)
		local lang = ft_to_lang[vim.bo[ev.buf].filetype]
		pcall(vim.treesitter.start, ev.buf, lang)
	end,
})

-- Folding: built-in treesitter foldexpr.
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldnestmax = 3
vim.o.foldenable = false -- Disable folding at startup

-- Fix: cursor line getting cut off by the @operator highlight.
local val = vim.api.nvim_get_hl(0, { name = "Normal" })
val.bg = nil
---@diagnostic disable-next-line: inject-field
val.ctermbg = nil
---@diagnostic disable-next-line: param-type-mismatch
vim.api.nvim_set_hl(0, "@operator", val)

require("treesitter-context").setup({
	mode = "cursor",
	max_lines = 5,
})
