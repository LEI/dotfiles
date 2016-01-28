" ~/.vimrc

" Make Vim more useful
set nocompatible

" Theming
set background=dark
try
    colorscheme torte
catch
endtry

" Autoload plugins
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
Helptags

filetype plugin indent on

set clipboard=unnamed

set wildmenu

set esckeys

set backspace=indent,eol,start

set ttyfast

set gdefault

set encoding=utf-8 nobomb

set binary
set noeol

set autoread

set nobackup
set nowb
set noswapfile
"set backupdir=~/.vim/backups
"set directory=~/.vim/swaps
"if exists("&undodir")
"	set undodir=~/.vim/undo
"endif
"set backupskip=/tmp/*,/private/tmp/*

set modeline
set modelines=4

" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure

set number

syntax on
set synmaxcol=800

if exists('+colorcolumn')
	set colorcolumn=80
endif

set cursorline
"set cursorcolumn
hi CursorLine cterm=none ctermbg=darkgray ctermfg=white guibg=darkgray guifg=white
hi ColorColumn ctermbg=black

set tabstop=2

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" Show “invisible” characters
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_,extends:❯,precedes:❮

set ignorecase

set smartcase

set hlsearch

set incsearch

"set lazyredraw

"set magic

"set showmatch
"set mat=2

"set foldcolumn=1

set laststatus=2
"set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l

if has("mouse")
	set mouse=a
endif

set visualbell
"set noerrorbells

set nostartofline

set ruler

set shortmess=atI

set showmode

set title

set showcmd

" Use relative line numbers
"if exists("&relativenumber")
"	set relativenumber
"	au BufReadPost * set relativenumber
"endif

" Start scrolling three lines before the horizontal window border
set scrolloff=3

"let $LANG='en'
"set langmenu=en
"source $VIMRUNTIME/delmenu.vim
"source $VIMRUNTIME/menu.vim

let mapleader=","

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Automatic commands
if has("autocmd")
	autocmd BufWritePost .vimrc source $MYVIMRC
	" Enable file type detection
	filetype on
	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif

" Returns true if paste mode is enabled
function! HasPaste()
	if &paste
		return 'PASTE MODE  '
	endif
	return ''
endfunction



" ...

function! DisplayColorSchemes()
   let currDir = getcwd()
   exec "cd $VIMRUNTIME/colors"
   for myCol in split(glob("*"), '\n')
      if myCol =~ '\.vim'
         let mycol = substitute(myCol, '\.vim', '', '')
         exec "colorscheme " . mycol
         exec "redraw!"
         echo "colorscheme = ". myCol
         sleep 2
      endif
   endfor
   exec "cd " . currDir
endfunction
