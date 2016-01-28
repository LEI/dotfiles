" ~/.vimrc

set nocompatible

" Autoload plugins
runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#infect()
Helptags

runtime! bundle/sensible/plugin/sensible.vim

" Theming
set background=dark
colorscheme base16-colors
" osx: https://github.com/chriskempson/base16-shell

filetype plugin indent on

set clipboard=unnamed

set esckeys

set ttyfast

set encoding=utf-8

set autoread

set binary
set noeol

set nobackup
set nowb
set noswapfile

set hidden

set modeline
set modelines=4

" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure

syntax on

set number

" Use relative line numbers
"if exists("&relativenumber")
"	set relativenumber
"	au BufReadPost * set relativenumber
"endif

if exists('+colorcolumn')
	set colorcolumn=80
endif

set cursorline
"set cursorcolumn
hi CursorColumn cterm=none ctermbg=darkgray ctermfg=white guibg=darkgray guifg=white

set gdefault
set ignorecase
set smartcase

set hlsearch
set incsearch

" Spacing

set synmaxcol=800

set autoindent
set backspace=indent,eol,start
"set complete-=i
"set smarttab

set tabstop=2

" Linebreak on 500 characters
set lbr
set tw=500

"set si "Smart indent
"set wrap "Wrap lines

" Show “invisible” characters
"tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
set list
set listchars=tab:▸\ ,trail:·,extends:❯,precedes:❮,nbsp:_,eol:¬

"set lazyredraw

"set magic

"set showmatch
"set mat=2

"set foldcolumn=1

if has("mouse")
	set mouse=a
endif

set visualbell
"set noerrorbells

set nostartofline

set wildmenu
set ruler

set shortmess=atI

set title

set showcmd

set laststatus=2

set noshowmode

" Start scrolling before the window border
set scrolloff=5
set sidescrolloff=5

if has("autocmd")
	" Auto reload .vimrc
	"autocmd BufWritePost .vimrc source $MYVIMRC
	" Enable file type detection
	filetype on
	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif

let mapleader=","

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Syntastic "

let g:syntastic_javascript_checkers = ['jshint']

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0

"let g:syntastic_error_symbol = "✗"
"let g:syntastic_warning_symbol = "⚠"
let g:syntastic_error_symbol = "☠"
let g:syntastic_warning_symbol = "⚠"
let g:syntastic_style_error_symbol = "☢"
let g:syntastic_style_warning_error = "⚠"

" The NERD Tree "

let NERDTreeMinimalUI=1
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1

" Open with <Ctrl+n>
map <C-n> :NERDTreeToggle<CR>

" Open if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Close if the last buffer is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" CtrlP "

" Exclude .gitignore paths
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" Airline "

let g:airline#extensions#syntastic#enabled=1
let g:airline#extensions#whitespace#enabled=1
" Enable the list of buffers
let g:airline#extensions#tabline#enabled=1
" Show just the filename
let g:airline#extensions#tabline#fnamemod=':t'
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'

if !exists('g:airline_symbols')
	let g:airline_symbols={}
endif

" unicode symbols
let g:airline_left_sep='»'
let g:airline_left_sep='▶'
let g:airline_right_sep='«'
let g:airline_right_sep='◀'
let g:airline_symbols.crypt='🔒'
let g:airline_symbols.linenr='␊'
let g:airline_symbols.linenr='␤'
let g:airline_symbols.linenr='¶'
"let g:airline_symbols.branch='⎇'
let g:airline_symbols.paste='ρ'
let g:airline_symbols.paste='Þ'
let g:airline_symbols.paste='∥'
let g:airline_symbols.whitespace='Ξ'

" old symbols
let g:airline_left_sep='⮀'
let g:airline_left_alt_sep='⮁'
let g:airline_right_sep='⮂'
let g:airline_right_alt_sep='⮃'
let g:airline_symbols.branch='⭠'
let g:airline_symbols.readonly='⭤'
"let g:airline_symbols.linenr='⭡'
