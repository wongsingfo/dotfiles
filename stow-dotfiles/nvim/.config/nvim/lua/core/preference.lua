local vim = vim
-- Darwin / Linux / Windows
local os_name = vim.loop.os_uname().sysname

-- Download nerd font from
-- https://www.nerdfonts.com/font-downloads
vim.cmd([[
	set guifont=Cousine\ NF:h12:antialias
	set mouse=a
]])

vim.o.encoding = "UTF-8"
-- vim.o.fileencoding = 'utf-8'

vim.o.number = true
-- vim.o.relativenumber = true
-- vim.o.cursorcolumn = true
vim.o.cursorline = true
vim.o.wrap = false

-- vim.o.scrolloff = 4
-- vim.o.sidescrolloff = 4
vim.o.signcolumn = 'yes'

vim.o.splitbelow = true
vim.o.splitright = true
vim.o.ignorecase = true
vim.o.smartcase = true

vim.g.vista_default_executive = 'coc'

-- Bufferline needs this to work
vim.o.termguicolors = true

vim.g.neovide_cursor_vfx_mode = "railgun"

-- We prevent the color scheme from changing the background so that we can set
-- change the background opacity in Windows Terminal.
-- vim.cmd([[
-- 	autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
-- ]])
vim.cmd([[
	syntax enable
	" set colorcolumn=80
]])

vim.cmd([[
	set listchars=tab:»\ ,trail:•,nbsp:␣,extends:»,precedes:«
	set list
]])
