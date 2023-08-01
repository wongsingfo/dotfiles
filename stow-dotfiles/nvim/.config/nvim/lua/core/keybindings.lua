local vim = vim
local wk = require('which-key')

-- How Leader key works
-- https://learnvimscriptthehardway.stevelosh.com/chapters/06.html
vim.g.mapleader = " "
vim.g.maplocalleader = ","

local map = vim.api.nvim_set_keymap
local keymap = vim.keymap.set

local opt = {
	noremap = true,
	silent = true,
}
local opt_expr = {
	noremap = true,
	silent = true,
	expr = true,
};

wk.register({
	p = {
		name = 'Telescope Diffview PasteCode',
		d = ':DiffviewOpen',
		D = ':DiffviewFileHistory paths',
		c = ':DiffviewClose',
		p = 'set paste',
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
	l = {
		name = 'Lazygit',
	},
}, { prefix = '<leader>' })

-- LSP Saga
-- LSP finder - Find the symbol's definition
-- If there is no definition, it will instead be hidden
-- When you use an action in finder like "open vsplit",
-- you can use <C-t> to jump back
keymap("n", "gr", "<cmd>Lspsaga lsp_finder<CR>")

-- Code action
keymap({"n", "v"}, "<leader>gx", "<cmd>Lspsaga code_action<CR>")

-- Rename all occurrences of the hovered word for the entire file
-- keymap("n", "gr", "<cmd>Lspsaga rename<CR>")

-- Rename all occurrences of the hovered word for the selected files
keymap("n", "<leader>gr", "<cmd>Lspsaga rename ++project<CR>")

-- Peek definition
-- You can edit the file containing the definition in the floating window
-- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
-- It also supports tagstack
-- Use <C-t> to jump back
keymap("n", "gp", "<cmd>Lspsaga peek_definition<CR>")

-- Go to definition
keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>")

-- Peek type definition
-- You can edit the file containing the type definition in the floating window
-- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
-- It also supports tagstack
-- Use <C-t> to jump back
-- keymap("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>")

-- Go to type definition
-- keymap("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>")

-- Show line diagnostics
-- You can pass argument ++unfocus to
-- unfocus the show_line_diagnostics floating window
-- keymap("n", "<leader>gl", "<cmd>Lspsaga show_line_diagnostics<CR>")

-- Show buffer diagnostics
keymap("n", "<leader>ge", "<cmd>Lspsaga show_buf_diagnostics<CR>")

-- Show workspace diagnostics
keymap("n", "<leader>gE", "<cmd>Lspsaga show_workspace_diagnostics<CR>")

-- Show cursor diagnostics
-- keymap("n", "<leader>gc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")

-- Diagnostic jump
-- You can use <C-o> to jump back to your previous location
keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>")

-- Diagnostic jump with filters such as only jumping to an error
keymap("n", "[E", function()
  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
keymap("n", "]E", function()
  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end)

-- Toggle outline
keymap("n","<leader>go", "<cmd>Lspsaga outline<CR>")

-- Hover Doc
-- If there is no hover doc,
-- there will be a notification stating that
-- there is no information available.
-- To disable it just use ":Lspsaga hover_doc ++quiet"
-- Pressing the key twice will enter the hover window
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>")

-- If you want to keep the hover window in the top right hand corner,
-- you can pass the ++keep argument
-- Note that if you use hover with ++keep, pressing this key again will
-- close the hover window. If you want to jump to the hover window
-- you should use the wincmd command "<C-w>w"
keymap("n", "<leader>gK", "<cmd>Lspsaga hover_doc ++keep<CR>")

-- Call hierarchy
-- keymap("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
-- keymap("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")

-- Floating terminal
keymap({"n", "t"}, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")

keymap("n", "<leader>gs", "<cmd>ClangdSwitchSourceHeader<CR>")

-- Telescope
map('n', '<c-p>', '<cmd>Telescope buffers<CR>', opt)
map('n', '<leader>pf', '<cmd>Telescope find_files<CR>', opt)
map('n', '<leader>pg', '<cmd>Telescope live_grep<CR>', opt)
map('n', '<leader>ps', '<cmd>Telescope grep_string<CR>', opt)
map('n', '<leader>pt', '<cmd>Telescope help_tags<CR>', opt)
-- Diffview
map('n', '<leader>pd', '<cmd>DiffviewOpen<CR>', opt)
map('n', '<leader>pD', '<cmd>DiffviewFileHistory<cr>', opt)
map('n', '<leader>pr', '<cmd>DiffviewRefresh<cr>', opt)
map('n', '<leader>pc', '<cmd>DiffviewClose<cr>', opt)
-- NvimTree
-- map('n', '<c-n>', '<cmd>NvimTreeToggle<CR>', opt)
-- map('n', '<leader>nr', '<cmd>NvimTreeRefresh<CR>', opt)
-- map('n', '<leader>nf', '<cmd>NvimTreeFindFile<CR>', opt)
-- Vista
-- map('n', '<leader>vi', '<cmd>Vista!!<CR>', opt)
-- BufferLine
map('n', '<leader>nn', '<cmd>BufferLineCycleNext<cr>', opt)
map('n', '<leader>np', '<cmd>BufferLineCyclePrev<cr>', opt)
map('n', '<leader>nl', '<cmd>BufferLineMoveNext<cr>', opt)
map('n', '<leader>nh', '<cmd>BufferLineMovePrev<cr>', opt)
map('n', '<leader>nb', '<cmd>BufferLinePick<cr>', opt)
map('n', '<leader>nc', '<cmd>BufferLinePickClose<cr>', opt)
for i = 1, 9 do
	map('n', '<leader>n'..i, '<cmd>BufferLineGoToBuffer '..i..'<cr>', opt)
end
-- Tab naviagtion
map('n', 'tj', '<cmd>tabnext<cr>', opt)
map('n', 'tk', '<cmd>tabprevious<cr>', opt)
map('n', 'tn', '<cmd>tabnew<cr>', opt)
map('n', 'tc', '<cmd>tabclose<cr>', opt)
-- Window resizer
vim.g.winresizer_start_key = '<leader>ww'
-- Neomux
vim.cmd[[
:tnoremap <expr> <C-V> '<C-\><C-N>"'.nr2char(getchar()).'pi'
]]
-- Hop
-- map('', 'f', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>", {})
-- map('', 'F', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>", {})
-- map('', 't', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<cr>", {})
-- map('', 'T', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<cr>", {})
-- map('', 's', "<cmd>HopChar1MW<cr>", opt)
-- map('o', 'Z', "<cmd>HopChar1MW<cr>", opt)
-- paste code
map('n', '<leader>pp', '<cmd>set paste<cr>"*p<cmd>set nopaste<cr>', opt)
-- Lazygit
-- https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md
map('n', '<leader>lg', '<cmd>LazyGit<cr>', opt)

wk.register({
	["<c-n>"] = "NvimTreeToggle",
	["<c-p>"] = "Telescope find_files",
	["<c-space>"] = "Coc refresh",
	["<c-num>"] = "Switch BufferLine",
	["<c-s>"] = "Exit insert mode in neomux",
	["<c-v>"] = "Paste reg in terminal mode",
}, { prefix = '?' })

-- Copy to clipboard
vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr = true})
vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
vim.keymap.set('v', '<leader>c', require('osc52').copy_visual)

map('n', '<leader>tm', '<cmd>lua toggle_textmode()<cr>', opt)
function toggle_textmode()
	local enabled = not vim.wo.spell
	vim.wo.wrap = enabled
	vim.wo.spell = enabled
	vim.wo.linebreak = enabled
end
