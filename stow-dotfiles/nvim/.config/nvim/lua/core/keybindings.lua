local vim = vim
local wk = require('which-key')

-- How Leader key works
-- https://learnvimscriptthehardway.stevelosh.com/chapters/06.html
vim.g.mapleader = " "
vim.g.maplocalleader = ","

local keymap = vim.keymap.set

local opt = {
	noremap = true,
	silent = true,
}
local function keymapOptions(desc, opt)
	local default = {
		noremap = true,
		silent = true,
		nowait = true,
		desc = desc,
	}
	if opt then
		for k, v in pairs(opt) do
			default[k] = v
		end
	end
	return default
end

-- wk.register({
-- 	["<c-n>"] = "NvimTreeToggle",
-- 	["<c-p>"] = "Telescope find_files",
-- 	["<c-space>"] = "Coc refresh",
-- 	["<c-num>"] = "Switch BufferLine",
-- 	["<c-s>"] = "Exit insert mode in neomux",
-- 	["<c-v>"] = "Paste reg in terminal mode",
-- }, { prefix = '?' })

wk.register({
	p = {
		name = 'Telescope Diffview PasteCode',
		d = ':DiffviewOpen',
		D = ':DiffviewFileHistory paths',
		c = ':DiffviewClose',
	},
	n = {
		name = 'NvimTree BufferLine',
	},
	w = {
		name = 'WindowResizer',
	},
	t = {
		name = 'Textmode',
	},
	-- l = {
	-- 	name = 'Lazygit',
	-- },
	c = {
		name = "Copy to clipboard",
	},
}, { prefix = '<leader>' })

-- LSP Saga
-- https://github.com/nvimdev/lspsaga.nvim/blob/main/lua/lspsaga/command.lua
-- LSP finder - Find the symbol's definition
-- If there is no definition, it will instead be hidden
-- When you use an action in finder like "open vsplit",
-- you can use <C-t> to jump back
keymap("n", "gr", "<cmd>Lspsaga finder<CR>")
keymap({"n", "v"}, "<leader>gx", "<cmd>Lspsaga code_action<CR>")
-- keymap("n", "gr", "<cmd>Lspsaga rename<CR>")
keymap("n", "<leader>gr", "<cmd>Lspsaga rename ++project<CR>")
keymap("n", "gp", "<cmd>Lspsaga peek_definition<CR>")
keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>")
keymap("n", "<leader>gt", "<cmd>Lspsaga goto_type_definition<CR>")
-- keymap("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>")
-- keymap("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>")
-- keymap("n", "<leader>gl", "<cmd>Lspsaga show_line_diagnostics<CR>")
keymap("n", "<leader>ge", "<cmd>Lspsaga show_buf_diagnostics<CR>")
keymap("n", "<leader>gE", "<cmd>Lspsaga show_workspace_diagnostics<CR>")
-- keymap("n", "<leader>gc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")
keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>")
keymap("n", "[E", function()
  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, keymapOptions("Prev Error"))
keymap("n", "]E", function()
  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end, keymapOptions("Next Error"))
keymap("n","<leader>go", "<cmd>Lspsaga outline<CR>")
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>")
keymap("n", "<leader>gK", "<cmd>Lspsaga hover_doc ++keep<CR>")
-- keymap("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
-- keymap("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")
keymap({"n", "t"}, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")

-- Format
keymap({"n", "v"}, "<leader>gf", "<cmd>GuardFmt<CR>")
keymap("n", "<leader>gs", "<cmd>ClangdSwitchSourceHeader<CR>")

-- Telescope
keymap('n', '<c-p>', '<cmd>Telescope buffers<CR>', opt)
-- keymap('n', '<leader>pb', '<cmd>Telescope buffers<CR>', opt)
keymap('n', '<leader>pf', '<cmd>Telescope find_files<CR>', opt)
keymap('n', '<leader>pg', '<cmd>Telescope live_grep<CR>', opt)
keymap('n', '<leader>pw', '<cmd>Telescope grep_string<CR>', opt)
keymap('n', '<leader>ps', '<cmd>Telescope lsp_document_symbols<CR>', opt)
keymap('n', '<leader>pt', '<cmd>Telescope help_tags<CR>', opt)
-- Diffview
-- map('n', '<leader>pd', '<cmd>DiffviewOpen<CR>', opt)
-- map('n', '<leader>pD', '<cmd>DiffviewFileHistory<cr>', opt)
-- map('n', '<leader>pr', '<cmd>DiffviewRefresh<cr>', opt)
-- map('n', '<leader>pc', '<cmd>DiffviewClose<cr>', opt)
-- NvimTree
-- map('n', '<c-n>', '<cmd>NvimTreeToggle<CR>', opt)
-- map('n', '<leader>nr', '<cmd>NvimTreeRefresh<CR>', opt)
-- map('n', '<leader>nf', '<cmd>NvimTreeFindFile<CR>', opt)
-- Vista
-- map('n', '<leader>vi', '<cmd>Vista!!<CR>', opt)
-- BufferLine
-- map('n', '<leader>nn', '<cmd>BufferLineCycleNext<cr>', opt)
-- map('n', '<leader>np', '<cmd>BufferLineCyclePrev<cr>', opt)
-- map('n', '<leader>nl', '<cmd>BufferLineMoveNext<cr>', opt)
-- map('n', '<leader>nh', '<cmd>BufferLineMovePrev<cr>', opt)
-- map('n', '<leader>nb', '<cmd>BufferLinePick<cr>', opt)
-- map('n', '<leader>nc', '<cmd>BufferLinePickClose<cr>', opt)
-- for i = 1, 9 do
-- 	map('n', '<leader>n'..i, '<cmd>BufferLineGoToBuffer '..i..'<cr>', opt)
-- end
-- Tab naviagtion
-- use gt and gT to navigate tabs
-- use <n>gt to go to the n-th tab
keymap('n', '<leader>tn', '<cmd>tabnew<cr>', opt)
keymap('n', '<leader>tc', '<cmd>tabclose<cr>', opt)
-- Window resizer
-- vim.g.winresizer_start_key = '<leader>ww'
-- Neomux
-- vim.cmd[[
-- :tnoremap <expr> <C-V> '<C-\><C-N>"'.nr2char(getchar()).'pi'
-- ]]
-- Hop
-- map('', 'f', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>", {})
-- map('', 'F', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>", {})
-- map('', 't', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<cr>", {})
-- map('', 'T', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<cr>", {})
-- map('', 's', "<cmd>HopChar1MW<cr>", opt)
-- map('o', 'Z', "<cmd>HopChar1MW<cr>", opt)
-- paste code
-- Lazygit
-- https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md
-- map('n', '<leader>lg', '<cmd>LazyGit<cr>', opt)

-- Rnvimr (ranger)
keymap('n', '<leader>ra', '<cmd>RnvimrToggle<cr>', keymapOptions("Run Ranger"))

-- GitBlame
-- keymap('n', '<leader>gb', '<cmd>GitBlameToggle<cr>', keymapOptions("Toggle GitBlame"))

-- Copy to clipboard
local osc52 = require('osc52')
keymap('n', '<leader>c', osc52.copy_operator, {expr = true})
keymap('n', '<leader>cc', '<leader>c_', {remap = true})
keymap('v', '<leader>c', osc52.copy_visual)
keymap('n', '<leader>pp', '<cmd>set paste<cr>"*p<cmd>set nopaste<cr>', keymapOptions("Paste"))

-- TextMode
keymap('n', '<leader>tm', function()
	local enabled = not vim.wo.spell
	vim.wo.wrap = enabled
	vim.wo.spell = enabled
	vim.wo.linebreak = enabled
end, keymapOptions("Toggle TextMode"))

-- ChatGPT
keymap({"n", "i"}, "<C-g>c", "<cmd>GpChatNew<cr>", keymapOptions("New Chat"))
keymap({"n", "i"}, "<C-g>f", "<cmd>GpChatFinder<cr>", keymapOptions("Chat Finder"))
keymap({"n", "i"}, "<C-g>t", "<cmd>GpChatToggle<cr>", keymapOptions("Toggle Chat"))
keymap({"n", "i"}, "<C-g>r", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
keymap({"n", "i"}, "<C-g>a", "<cmd>GpAppend<cr>", keymapOptions("Append (after)"))
keymap({"n", "i"}, "<C-g>b", "<cmd>GpPrepend<cr>", keymapOptions("Prepend (before)"))
keymap("v", "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", keymapOptions("Visual Rewrite"))
keymap("v", "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", keymapOptions("Visual Append (after)"))
keymap("v", "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", keymapOptions("Visual Prepend (before)"))
keymap("v", "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", keymapOptions("Implement selection"))

-- Git
local gs=require('gitsigns')
keymap('n', ']c', function()
	if vim.wo.diff then return ']c' end
	vim.schedule(function() gs.next_hunk() end)
	return '<Ignore>'
end, keymapOptions("Next Hunk", {expr=true}))
keymap('n', '[c', function()
	if vim.wo.diff then return '[c' end
	vim.schedule(function() gs.prev_hunk() end)
	return '<Ignore>'
end, keymapOptions("Prev Hunk", {expr=true}))
keymap('n', '<leader>hs', gs.stage_hunk, keymapOptions("Stage Hunk"))
keymap('n', '<leader>hr', gs.reset_hunk, keymapOptions("Reset Hunk"))
keymap('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, keymapOptions("Stage Hunk"))
keymap('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, keymapOptions("Reset Hunk"))
keymap('n', '<leader>hS', gs.stage_buffer, keymapOptions("Stage Buffer"))
keymap('n', '<leader>hu', gs.undo_stage_hunk, keymapOptions("Undo Stage Hunk"))
keymap('n', '<leader>hR', gs.reset_buffer, keymapOptions("Reset Buffer"))
keymap('n', '<leader>hp', gs.preview_hunk, keymapOptions("Preview Hunk"))
keymap('n', '<leader>hb', function() gs.blame_line{full=true} end, keymapOptions("Blame Line"))
keymap('n', '<leader>hB', gs.toggle_current_line_blame, keymapOptions("Toggle Blame"))
keymap('n', '<leader>hd', gs.diffthis, keymapOptions("Diff This"))
keymap('n', '<leader>hD', function() gs.diffthis('HEAD') end, keymapOptions("Diff HEAD~"))
keymap('n', '<leader>hP', gs.toggle_deleted, keymapOptions("Toggle Deleted"))
keymap({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
