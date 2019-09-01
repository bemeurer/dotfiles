" Plugins
call plug#begin('~/.local/share/nvim/plugged')
if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'Shougo/neosnippet.vim'
else
    Plug 'Shougo/deoplete.nvim'
    Plug 'Shougo/neosnippet.vim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'dag/vim-fish'
Plug 'Shougo/neco-syntax'
Plug 'Shougo/neosnippet-snippets'
Plug 'ayu-theme/ayu-vim'
Plug 'bronson/vim-trailing-whitespace'
Plug 'cespare/vim-toml'
Plug 'dcharbon/vim-flatbuffers'
Plug 'dense-analysis/ale'
Plug 'deoplete-plugins/deoplete-clang'
Plug 'fszymanski/deoplete-emoji'
Plug 'gentoo/gentoo-syntax'
Plug 'igankevich/mesonic'
Plug 'junegunn/goyo.vim'
Plug 'lervag/vimtex'
Plug 'liuchengxu/graphviz.vim'
Plug 'lnl7/vim-nix'
Plug 'lotabout/skim', {'do':'./install'}
Plug 'lotabout/skim.vim'
Plug 'luochen1990/rainbow'
Plug 'majutsushi/tagbar'
Plug 'mattn/gist-vim'
Plug 'mattn/webapi-vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'nfnty/vim-nftables'
Plug 'potatoesmaster/i3-vim-syntax'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'qnighy/lalrpop.vim'
Plug 'rust-lang/rust.vim'
Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'
Plug 'uarun/vim-protobuf'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'wellle/tmux-complete.vim'
call plug#end()

" Settings
" ---- Line numbers
set number
set cursorline
" ---- Hide files in the background instad of closing them
set hidden
" ---- Undo limit
set history=1000
" ---- Automatically re-read files if unmodified inside vim
set autoread
" ---- Leader
let mapleader = ","
let g:mapleader = ","
nmap <leader>w :w!<cr>
" ---- :W sudo-save file
command W w !sudo tee % > /dev/null
" ---- Filetype specific plugins and indentation rules
filetype plugin on
filetype indent on
" ---- Cursor lines
set so=10
" ---- Show cursor position
set ruler
" ---- Allow backspacing over indentation, line breaks, and insertion start
set backspace=eol,start,indent
" ---- Automatically wrap left and right
set whichwrap+=<,>,h,l,[,]
" ---- Ignore case when searching
set ignorecase
" ---- Make search case-sensitive when using uppercase letters
set smartcase
" ---- Search highlighting
set hlsearch
" ---- Incremental searches: show partial results
set incsearch
" ---- Turn off search highlighting
nnoremap <leader><space> :nohlsearch<CR>
" ---- Don't update screen during macro/script execution
set lazyredraw
" ---- Enable magic macros
set magic
" ---- Show matching brackets
set showmatch
" ---- No bells on errors
set noerrorbells
set novisualbell
" ---- Syntax highlighting
syntax enable
" ---- True colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
" ---- UTF-8
set encoding=utf8
" ---- Unix filetypes
set ffs=unix,dos,mac
" ---- Spaces, never tabs
set expandtab
set smarttab
set shiftwidth=4
" ---- Linebreak at 80 chars
set lbr
set tw=80
" ---- Automatic indentation
set ai " Auto indent
set si " Smart indent
set wrap " Wrap lines
" ---- When in visual mode, * or # searches
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
" ---- Moving between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
" ---- Close the current buffer
map <leader>bd :bd<cr>:tabclose<cr>gT
" ---- Close all buffers
map <leader>ba :bufdo bd<cr>
" ---- Next/Previous buffer
map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>
" ---- Managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>t<leader> :tabnext<cr>
" ---- tl toggles tabs alt-tab style
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()
" ---- Opens a new tab with the current buffer's path
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
" ---- Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>
" ---- Specify the behavior when switching between buffers
try
    set switchbuf=useopen,usetab,newtab
    set stal=2
catch
endtry
" ---- Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
" ---- Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>
" ---- Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=
map <leader>y "+y
map <leader>p "+p
noremap <leader>f :ALEFix <CR>
" ---- Undo settings
try
    set undodir=~/.cache/nvim/undodir
    set undofile
catch
endtry
" ---- Set cursor to bar in tmux
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Plugin settings
" ---- Shougo/deoplete.nvim
let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#clang#libclang_path = "/usr/lib/llvm/8/lib64/libclang.so"
let g:deoplete#sources#clang#clang_header = "/usr/lib/llvm/8/include/clang"

call deoplete#custom#source('tabnine', 'rank', 100)
" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <expr><TAB>
            \ pumvisible() ? "\<C-n>" :
            \ neosnippet#expandable_or_jumpable() ?
            \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
    set conceallevel=2 concealcursor=niv
endif
" ---- luochen1990/rainbow
let g:rainbow_active = 1
" ---- lotabout/skim.vim
let g:fzf_layout = { 'window': '60split enew' }
let g:fzf_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit' }
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
            \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
nnoremap <C-b> :Buffers<CR>
nnoremap <C-p> :Files<CR>
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
command -nargs=+ -complete=file -bar Rg silent! grep! <args>|cwindow|redraw!
" ---- lervag/vimtex
call deoplete#custom#var('omni', 'input_patterns', {'tex': g:vimtex#re#deoplete})
let g:vimtex_compiler_latexmk = {
            \ 'options' : [
            \   '-pdf',
            \   '-shell-escape',
            \   '-verbose',
            \   '-file-line-error',
            \   '-synctex=1',
            \   '-interaction=nonstopmode',
            \ ],
            \}
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_view_general_viewer = 'evince'

" ---- vim-airline/vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_highlighting_cache = 1
let g:airline#extensions#ale#enabled = 1
let g:airline_theme='ayu_dark'
" ---- nathanaelkane/vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1
" ---- ayu-theme/ayu-vim
let g:ayucolor="dark"
colorscheme ayu
" ---- majutsushi/tagbar
noremap <leader>t :TagbarToggle<CR>
" ---- wellle/tmux-complete.vim
let g:tmuxcomplete#trigger = ''
" ---- dense-analysis/ale
let g:ale_fix_on_save = 1
nmap <silent> <C-j> <Plug>(ale_next_wrap)
let g:ale_linters = {
    \ 'c':['clangd', 'cppcheck', 'flawfinder'],
    \ 'cpp':['clangd', 'cppcheck', 'flawfinder'],
    \ 'ebuild':['shellcheck'],
    \ 'python': ['bandit', 'pylama', 'vulture'],
    \ 'rust': ['rls'],
    \ 'text':['proselint', 'languagetool'],
    \ }
let g:ale_fixers = {
    \ 'c':['remove_trailing_lines', 'trim_whitespace', 'clang-format'],
    \ 'cpp':['remove_trailing_lines', 'trim_whitespace', 'clang-format'],
    \ 'ebuild':['remove_trailing_lines', 'trim_whitespace'],
    \ 'fish':['remove_trailing_lines', 'trim_whitespace'],
    \ 'gentoo-metadata':['remove_trailing_lines', 'trim_whitespace', 'xmllint'],
    \ 'i3':['remove_trailing_lines', 'trim_whitespace'],
    \ 'json':['remove_trailing_lines', 'trim_whitespace', 'prettier', 'fixjson'],
    \ 'nix':['remove_trailing_lines', 'trim_whitespace'],
    \ 'python':['remove_trailing_lines', 'trim_whitespace', 'isort', 'autopep8'],
    \ 'rust':['remove_trailing_lines', 'trim_whitespace','rustfmt'],
    \ 'sh':['shfmt','remove_trailing_lines','trim_whitespace'],
    \ 'toml':['remove_trailing_lines', 'trim_whitespace'],
    \ 'xml':['remove_trailing_lines', 'trim_whitespace', 'xmllint'],
    \ }
