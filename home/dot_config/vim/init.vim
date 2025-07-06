if v:version < 800
  echoerr 'vim-8.0 required'
endif

let g:mapleader=' '
let g:localmapleader=' '

set clipboard+=unnamedplus
" set cmdheight=2
if has('syntax') && exists('+colorcolumn')
  set colorcolumn=+1 " Color column relative to textwidth
endif
set gdefault " Reverse global flag (always apply to all, except if /g)
set ignorecase " Ignore case in search patterns
" set magic " Changes the special characters that can be used in search patterns
if exists('+relativenumber')
  set relativenumber
endif
set smartcase " Case sensitive when the search contains upper case characters
if has('termguicolors')
  set termguicolors
endif

" Window
if has('windows')
  set splitbelow " Split windows below the current window
  set splitright " Split windows right of the current window
  set winminheight=0 " Minimal height of a window when it's not the current one
  " if &tabpagemax < 50
  "   set tabpagemax=50 " Maximum number of tab pages to be opened
  " endif
endif

set wrapscan " Searches wrap around the end of the file

" Cursor
if has('syntax')
  set cursorline " Highlight the screen line of the cursor
endif
set nostartofline " Keep the cursor on the same column when possible
set scrolloff=5 " Lines to keep above and below the cursor
set sidescroll=1 " Lines to scroll horizontally when 'wrap' is set
set sidescrolloff=5 " Lines to the left and right if 'nowrap' is set

" Indent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smartindent

" Make 'dot' work as expected in visual mode
" vnoremap . :normal .<cr>

" Repeat last command on next match
noremap ; :normal n.<cr>

" Split navigation shortcuts
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" Dark: catppuccin_mocha
" Light: catppuccin_latte
colorscheme catppuccin_macchiato

" filetype plugin indent on

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
