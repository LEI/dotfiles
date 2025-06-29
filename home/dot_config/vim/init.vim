if v:version < 800
  echoerr 'vim-8.0 required'
endif

let g:mapleader=' '
let g:localmapleader=' '

set clipboard+=unamedplus
if has('syntax') && exists('+colorcolumn')
  set colorcolumn=+1 " Color column relative to textwidth
endif
set gdefault " Reverse global flag (always apply to all, except if /g)
set ignorecase " Ignore case in search patterns
" set magic " Changes the special characters that can be used in search patterns
if exists('+relativenumber')
  set relativenumber
endif
" set smartcase " Case sensitive when the search contains upper case characters
if has('termguicolors')
  set termguicolors
endif
" set wrapscan " Searches wrap around the end of the file

" Dark: catppuccin_mocha
" Light: catppuccin_latte
colorscheme catppuccin_macchiato

" filetype plugin indent on

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
