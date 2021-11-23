syntax on " highlight syntax

" https://vim.fandom.com/wiki/Omni_completion
" Press <C-x><C-o>
filetype plugin on
set omnifunc=syntaxcomplete#Complete

set number " show line numbers
set relativenumber
set hlsearch " highlight all results
" highlight Search ctermbg=Yellow cterm=underline
" set showmatch
highlight MatchParen ctermbg=DarkYellow
set ignorecase " ignore case in search
set incsearch " show search results as you type
set showcmd
set nowrap
set smarttab

set cursorline

" set foldmethod=syntax
highlight Folded ctermbg=none

" change leader key
" let mapleader = ","
let mapleader = "\<Space>"

func MyTab4()
  " https:/jstackoverflow.com/questions/1878974/redefine-tab-as-4-spaces
  set tabstop=8 softtabstop=0 expandtab shiftwidth=4
endfunc

" vr: vim reload
nnoremap <Leader>vr :source $MYVIMRC<CR>
" pi: plug install
nnoremap <Leader>pi :PlugInstall<CR>

let g:my_project_root = ['.svn', '.git', '.root', '_darcs', 'build.xml']

call plug#begin('~/.vim/plugged')
" Emmet for vim
Plug 'mattn/emmet-vim'
" A tree explorer plugin for vim
Plug 'preservim/nerdtree'
" lean & mean status/tabline for vim that's light as air
Plug 'vim-airline/vim-airline'
" Vim motions on speed!
Plug 'easymotion/vim-easymotion'
" Vim motions (with key s)
Plug 'justinmk/vim-sneak'
" quoting/parenthesizing made simple ysaW{
Plug 'tpope/vim-surround'
" cscope
Plug 'dr-kino/cscope-maps'
" Toggle comment
Plug 'chrisbra/vim-commentary'
" Text object  di,
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter'
" Diff
if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif
" Linting
Plug 'dense-analysis/ale'
" <leader>b / <leader>f: search buffer / files
" Also install the C extension of the fuzzy matching algorithm
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
" Auto generate ctags files
" https://ctags.io/
Plug 'ludovicchabant/vim-gutentags'
" AsyncRun
Plug 'skywind3000/asyncrun.vim'
" C++ Syntax highlighting
Plug 'octol/vim-cpp-enhanced-highlight'
" YCM
Plug 'ycm-core/YouCompleteMe'
call plug#end()

" Emmet trigger key. Enter , after the leader key
let g:user_emmet_leader_key='<C-Y>'

" Shortcut for NERDTree
nnoremap <C-t> :NERDTreeToggle<CR>

" Automatically displays all buffers when there's only one tab open.
let g:airline#extensions#tabline#enabled = 1

" ale config
let g:airline#extensions#ale#enabled = 1
" let g:ale_set_highlights = 0
" highlight ALEError ctermbg=none cterm=underline
highlight ALEError ctermbg=DarkRed
highlight ALEWarning ctermbg=DarkMagenta
" highlight ALEErrorSign ctermbg=DarkRed
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_c_build_dir_names = ['build', 'bin', 'cmake-build-debug']

" No background color for sign column
highlight clear SignColumn
" Merge number column and sign column
" set signcolumn=number
highlight SignifySignAdd ctermfg=green
highlight SignifySignDelete ctermfg=red
highlight SignifySignChange ctermfg=yellow

highlight PMenu ctermfg=0 ctermbg=242 guifg=black guibg=darkgrey
highlight PMenuSel ctermfg=242 ctermbg=8 guifg=darkgrey guibg=black

" Leaderf
nnoremap <Leader>mru :LeaderfMru<CR>

" ctags
set tags=./.tags;,.tags

" gutentags
let g:gutentags_project_root = g:my_project_root
let g:gutentags_ctags_tagfile = '.tags'
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

" Signify diff
nnoremap <Leader>di :SignifyDiff<CR>

" Asynrun
let g:asyncrun_open = 10  " window height
" let g:asyncrun_bell = 1
" Compile single file
" nnoremap <F9> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
" Run
" nnoremap <F5> :AsyncRun -raw -cwd=$(VIM_FILEDIR) "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
let g:asyncrun_rootmarks = g:my_project_root
" Make
nnoremap <Leader>cm :AsyncRun -cwd=<root> cmake -S . -B build<CR>
nnoremap <Leader>mk :AsyncRun -cwd=<root> cmake --build build<CR>
nnoremap <Leader>te :AsyncRun -cwd=<root> cmake --build build --target test<CR>
nnoremap <Leader>py :!python3 %<CR>

" C++ hightlight
let g:cpp_member_variable_highlight = 1
let g:cpp_class_scope_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_class_decl_highlight = 1

" YCM
let g:ycm_filetype_whitelist = {
\ 'c': 1,
\ 'cc': 1,
\ 'cpp': 1,
\ 'h': 1,
\ 'rs': 1,
\ 'sh': 1,
\ 'go': 1,
\}
let g:ycm_show_diagnostics_ui = 0
let g:ycm_enable_diagnostic_signs = 1
let g:ycm_enable_diagnostic_highlighting = 0
set completeopt=menu,menuone
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_semantic_triggers =  {
			\ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
			\ 'cs,lua,javascript': ['re!\w{2}'],
			\ }

