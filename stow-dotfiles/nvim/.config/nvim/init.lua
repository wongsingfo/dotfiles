local vim = vim

-- We need to set the mapleader before plugin setup.
--
-- `<leader>` is used for general custom key combinations,
-- while `<localleader>` is used for more context-specific mappings.
vim.g.mapleader = " "
vim.g.maplocalleader = ","
require("plugins")

-- Darwin / Linux / Windows
-- local os_name = vim.loop.os_uname().sysname

-- Download nerd font from
-- https://www.nerdfonts.com/font-downloads
-- vim.o.guifont = "Cousine NF:h12:antialias"

vim.o.mouse = "a"
vim.o.encoding = "UTF-8"

-- vim.o.number = true
-- vim.o.relativenumber = true
-- vim.o.cursorcolumn = true
-- vim.o.cursorline = true
vim.o.wrap = false

-- vim.o.scrolloff = 4
-- vim.o.sidescrolloff = 4
-- vim.o.signcolumn = 'yes'
-- vim.o.colorcolumn = 80
vim.o.signcolumn = "number"

-- vim.o.splitbelow = true
-- vim.o.splitright = true

vim.o.ignorecase = true
vim.o.smartcase = true

-- Bufferline needs this to work
-- vim.o.termguicolors = true

-- vim.g.vista_default_executive = "coc"
-- vim.g.neovide_cursor_vfx_mode = "railgun"

-- We prevent the color scheme from changing the background so that we can set
-- change the background opacity in Windows Terminal.
-- vim.cmd([[
-- 	autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
-- ]])

vim.o.autowrite = true

vim.o.wildmode = "longest:full,full"
vim.o.wildmenu = true

vim.opt.list = true
vim.opt.listchars = {
	trail = '•',
	lead = '·',
	tab = '▸ ',
	extends = '»',
	precedes = '«',
	nbsp = '␣',
}
