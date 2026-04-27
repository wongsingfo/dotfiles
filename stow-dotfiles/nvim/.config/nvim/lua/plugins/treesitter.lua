-- Use nvim's built-in treesitter. nvim 0.12 bundles parsers for: c, lua,
-- markdown, markdown_inline, query, vim, vimdoc. For any other filetype,
-- vim.treesitter.language.get_lang() returns the canonical parser name and
-- vim.treesitter.start() activates it if the parser is installed; otherwise
-- pcall catches the error and the buffer falls back to regex highlighting.
-- Additional parsers can be installed with:
--   nvim --headless -c "lua vim.treesitter.language.add('python')" +q
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TreesitterEnable", { clear = true }),
	pattern = "*",
	callback = function(ev)
		local ft = vim.bo[ev.buf].filetype
		if ft == "" then
			return
		end
		local lang = vim.treesitter.language.get_lang(ft)
		if lang then
			pcall(vim.treesitter.start, ev.buf, lang)
		end
	end,
})

-- Incremental selection: reimplements nvim-treesitter's incremental_selection
-- module using built-in vim.treesitter APIs.
--   vv  - init: select current AST node
--   v   - expand to parent node (in visual mode, when IS active)
--   u   - shrink to previous node (in visual mode, when IS active)
local is_state = {} -- { [bufnr] = { node = tsnode, stack = { tsnode, ... } } }
local is_updating = false

vim.api.nvim_create_autocmd("ModeChanged", {
	group = vim.api.nvim_create_augroup("ISClear", { clear = true }),
	pattern = "[vV\x16]*:*",
	callback = function()
		if is_updating then
			return
		end
		is_state[vim.api.nvim_get_current_buf()] = nil
	end,
})

-- Select a node range by leaving any visual mode, moving to end,
-- entering visual, then moving to start.
local function select_range(sr, sc, er, ec)
	local ec_anchored = ec > 0 and (ec - 1) or ec
	local last_line = vim.api.nvim_buf_line_count(0)
	local end_row = math.min(er + 1, last_line)
	local start_row = math.min(sr + 1, last_line)
	is_updating = true
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
	vim.api.nvim_win_set_cursor(0, { end_row, ec_anchored })
	vim.cmd("normal! v")
	vim.api.nvim_win_set_cursor(0, { start_row, sc })
	is_updating = false
end

local function init_selection()
	local buf = vim.api.nvim_get_current_buf()
	local node = vim.treesitter.get_node({ bufnr = buf })
	if not node then
		return
	end
	local sr, sc, er, ec = node:range()
	select_range(sr, sc, er, ec)
	is_state[buf] = { node = node, stack = {} }
end

local function node_incremental()
	local buf = vim.api.nvim_get_current_buf()
	local state = is_state[buf]
	if not state then
		vim.cmd("normal! v")
		return
	end
	local parent = state.node:parent()
	if not parent then
		return
	end
	table.insert(state.stack, state.node)
	state.node = parent
	local sr, sc, er, ec = parent:range()
	select_range(sr, sc, er, ec)
end

local function node_decremental()
	local buf = vim.api.nvim_get_current_buf()
	local state = is_state[buf]
	if not state then
		vim.cmd("normal! u")
		return
	end
	local prev = table.remove(state.stack)
	if not prev then
		return
	end
	state.node = prev
	local sr, sc, er, ec = prev:range()
	select_range(sr, sc, er, ec)
end

vim.keymap.set("n", "vv", init_selection, { desc = "Init treesitter incremental selection" })
vim.keymap.set("v", "v", node_incremental, { desc = "Expand TS selection" })
vim.keymap.set("v", "u", node_decremental, { desc = "Shrink TS selection" })

-- Folding: built-in treesitter foldexpr.
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldnestmax = 3
vim.o.foldenable = false -- Disable folding at startup

-- -- Fix: cursor line getting cut off by the @operator highlight.
-- local val = vim.api.nvim_get_hl(0, { name = "Normal" })
-- val.bg = nil
-- ---@diagnostic disable-next-line: inject-field
-- val.ctermbg = nil
-- ---@diagnostic disable-next-line: param-type-mismatch
-- vim.api.nvim_set_hl(0, "@operator", val)

require("treesitter-context").setup({
	mode = "cursor",
	max_lines = 5,
})
