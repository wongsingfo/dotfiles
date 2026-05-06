-- Use nvim's built-in treesitter.  nvim 0.12 bundles parsers for: c, lua,
-- markdown, markdown_inline, query, vim, vimdoc.
-- Additional parsers listed in ts_ensure_installed are compiled from the
-- official tree-sitter grammar repos on startup (pre-generated C files; gcc
-- only, no tree-sitter CLI needed).  Or use :TSCompile {lang} at any time.
local ts_ensure_installed = {
	"python",
}

-- Single shared compile function used by both ensure_installed and :TSCompile.
local function ts_compile_one(lang)
	local repo = "https://github.com/tree-sitter/tree-sitter-" .. lang .. ".git"
	local tmp = vim.fn.tempname() .. "_ts_" .. lang
	local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
	local queries_dir = vim.fn.stdpath("data") .. "/site/queries/" .. lang
	local queries_url = "https://raw.githubusercontent.com/neovim-treesitter/nvim-treesitter/main/queries/" .. lang .. "/"

	---@diagnostic disable-next-line: undefined-field
	vim.system({
		"sh", "-c",
		"git clone -q --depth 1 " .. repo .. " " .. tmp
		.. " && cd " .. tmp .. "/src"
		.. " && mkdir -p " .. parser_dir .. " " .. queries_dir
		.. " && (gcc -shared -fPIC -o " .. parser_dir .. "/" .. lang .. ".so parser.c scanner.c -I. 2>/dev/null"
		.. "  || gcc -shared -fPIC -o " .. parser_dir .. "/" .. lang .. ".so parser.c -I. 2>/dev/null)"
		.. " && rm -rf " .. tmp,
	}, nil, function(res)
		vim.schedule(function()
			if res.code == 0 then
				-- Fetch query files from neovim-treesitter runtime.
				---@diagnostic disable-next-line: undefined-field
				vim.system({
					"sh", "-c",
					"for f in highlights folds injections; do"
					.. " curl -fsSL " .. queries_url .. "${f}.scm"
					.. " -o " .. queries_dir .. "/${f}.scm 2>/dev/null;"
					.. " done",
				}, nil, function(res2)
					vim.schedule(function()
						for _, buf in ipairs(vim.api.nvim_list_bufs()) do
							if vim.bo[buf].filetype == lang then
								pcall(vim.treesitter.start, buf, lang)
							end
						end
						vim.notify("Treesitter parser compiled: " .. lang, vim.log.levels.INFO)
					end)
				end)
			else
				vim.notify("TSCompile failed for " .. lang, vim.log.levels.ERROR)
			end
		end)
	end)
end

vim.api.nvim_create_user_command("TSCompile", function(opts)
	ts_compile_one(opts.args:lower())
end, { nargs = 1, desc = "Compile a treesitter parser from official grammar repo" })

-- On startup, compile any missing parsers from ts_ensure_installed.
for _, lang in ipairs(ts_ensure_installed) do
	local installed = pcall(vim.treesitter.language.inspect, lang)
	if not installed then
		ts_compile_one(lang)
	end
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TreesitterEnable", { clear = true }),
	pattern = "*",
	callback = function(ev)
		local ft = vim.bo[ev.buf].filetype
		if ft == "" then
			return
		end
		local lang = vim.treesitter.language.get_lang(ft)
		if not lang then
			return
		end
		-- Only start if highlight queries exist; without them treesitter
		-- highlighting produces nothing and the buffer goes dark.
		if #vim.api.nvim_get_runtime_file("queries/" .. lang .. "/highlights.scm", false) == 0 then
			return
		end
		pcall(vim.treesitter.start, ev.buf, lang)
	end,
})

-- Incremental selection: reimplements nvim-treesitter's incremental_selection
-- module using built-in vim.treesitter APIs.
--   vv  - init: select current AST node
--   v   - expand to parent node (in visual mode, when IS active)
--   u   - shrink to previous node (in visual mode, when IS active)
local is_state = {} -- { [bufnr] = { node = tsnode, stack = { tsnode, ... } } }

vim.api.nvim_create_autocmd("ModeChanged", {
	group = vim.api.nvim_create_augroup("ISClear", { clear = true }),
	pattern = "[vV\x16]*:*",
	callback = function()
		is_state[vim.api.nvim_get_current_buf()] = nil
	end,
})

-- Clamp row to valid buffer lines.
local function clamp_row(r0)
	return math.max(1, math.min(r0 + 1, vim.api.nvim_buf_line_count(0)))
end

-- Visually select the 0-indexed [sr,sc) -> [er,ec) range.
local function select_range(sr, sc, er, ec)
	local end_c = ec > 0 and (ec - 1) or ec
	local end_r = clamp_row(er)
	local start_r = clamp_row(sr)

	-- Already in visual mode (expand/shrink): swap anchor with o, then
	-- move cursor so the selection stays within the visual mode without
	-- leaving and re-entering (which would trigger ModeChanged).
	local m = vim.api.nvim_get_mode().mode
	local in_visual = m == "v" or m == "V" or m == "\22"

	if in_visual then
		-- Move to one end; o swaps cursor<->anchor; move to the other end.
		vim.api.nvim_win_set_cursor(0, { end_r, end_c })
		vim.cmd("normal! o")
		vim.api.nvim_win_set_cursor(0, { start_r, sc })
	else
		-- Normal mode (init): anchor at end, enter visual, move to start.
		vim.api.nvim_win_set_cursor(0, { end_r, end_c })
		vim.cmd("normal! v")
		vim.api.nvim_win_set_cursor(0, { start_r, sc })
	end
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
