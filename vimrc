syntax on " highlight syntax

" https://vim.fandom.com/wiki/Omni_completion
" Press <C-x><C-o>
filetype plugin on
set omnifunc=syntaxcomplete#Complete

set number " show line numbers
set hlsearch " highlight all results
set ignorecase " ignore case in search
set incsearch " show search results as you type

" change leader key
let mapleader = "'"

" reload vimrc
nnoremap <Leader>vr :source $MYVIMRC<CR>

call plug#begin('~/.vim/plugged')
" Emmet for vim
Plug 'mattn/emmet-vim'
" A tree explorer plugin for vim
Plug 'preservim/nerdtree'
" lean & mean status/tabline for vim that's light as air
Plug 'vim-airline/vim-airline'
" Vim motions on speed!
Plug 'easymotion/vim-easymotion'
" quoting/parenthesizing made simple
Plug 'tpope/vim-surround'
call plug#end()

" Emmet trigger key. Enter , after the leader key
let g:user_emmet_leader_key='<C-Y>'

" Shortcut for NERDTree
nnoremap <C-t> :NERDTreeToggle<CR>

" Automatically displays all buffers when there's only one tab open.
let g:airline#extensions#tabline#enabled = 1

