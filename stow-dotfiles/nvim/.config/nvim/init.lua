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
vim.o.splitright = true

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
       -- lead = '·',
       tab = '│ ',
       extends = '»',
       precedes = '«',
       nbsp = '␣',
}
vim.o.showbreak = "↪ "

vim.opt.mousescroll = "ver:3,hor:0"

vim.keymap.set('n', '<leader>tm', function()
       local enabled = not vim.wo.spell
       vim.wo.wrap = enabled
       vim.wo.spell = enabled
       vim.wo.linebreak = enabled
       vim.o.signcolumn = "yes"

       -- https://stackoverflow.com/questions/3033423/vim-command-to-restructure-force-text-to-80-columns
       -- vim.cmd('set columns=80')
end, {
       noremap = true,
       silent = true,
       nowait = true,
})

vim.keymap.set('n', '<leader>gg', '<cmd>LspStart<CR>')

-- For tex backward jump from SumatraPDF
if vim.fn.has('win32') == 1 then
    -- nvr -c "OpenFileWindows %f %l"
    function OpenFileWindows(filename, line)
        -- Convert Windows path to WSL path
        local wsl_path = filename:gsub("\\", "/"):gsub("^([A-Za-z]):", "/mnt/%1"):lower()
        -- Open the file using the WSL path
        vim.cmd('e ' .. vim.fn.fnameescape(wsl_path))
        -- Move to the specified line
        vim.api.nvim_win_set_cursor(0, { tonumber(line), 0 })
    end

    vim.cmd('command! -nargs=+ OpenFileWindows lua OpenFileWindows(<f-args>)')
end
