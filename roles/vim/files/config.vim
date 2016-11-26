" ~/.vim/vimrc
" vim: foldenable foldmethod=marker et sts=2 sw=2 ts=2

" zi Folding on/off
" zR Open all
" zM Close all
" za Toggle current
" zj Down to the start of the next
" zk Up to the end of the previous

" https://github.com/mathiasbynens/dotfiles/blob/master/.vimrc
" https://github.com/tpope/vim-sensible/blob/master/plugin/sensible.vim"
" https://github.com/lukaszkorecki/DotVim/blob/master/vimrc
" https://github.com/wsdjeg/DotFiles/tree/master/config/nvim/config

" Arch
" set rtp^=/usr/share/vim/vimfiles

" General {{{1

if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8
endif

" Automatically :write before running commands
" set autowrite

"if has('path_extra')
""  setglobal tags-=./tags tags-=./tags; tags^=./tags;
"endif

"if &shell =~# 'fish$'
"  set shell=/bin/bash
"endif

" Do not scan included files (ctags?)
set complete-=i

" Autocompete with dictionnary words when spell check is on
set complete+=kspell

" Disable octal format for number processing using CTRL-A
set nrformats-=octal

" Escape fix?
set timeout
set timeoutlen=1000
" set ttimeout
set ttimeoutlen=10

" Use one space, not two, after punctuation
" set nojoinspaces

" set binary
" set noeol

" Enable per-directory '.vimrc' file
set exrc
" Disable autocmd, shell and write commands in the current directory '.vimrc'
set secure

" Diff {{{1

" Always use vertical diffs
set diffopt+=vertical

" Interface {{{1

" set showtabline=2

" set guioptions-=e

" Disable cursor blinking
"set guicursor=a:blinkon0

" Do not show matching brackets when text indicator is over them
set noshowmatch
" How many tenths of a second to blink when matching brackets
"set mat=2

" HTML brackets
set matchpairs+=<:>

" Treat <li> and <p> tags like the block tags they are
" let g:html_indent_tags = 'li\|p'

" Show line breaks (arrows: 0x21AA or 0x08627)
let &showbreak = nr2char(0x2026) " Ellipsis

" set fillchars+=stl:\ ,stlnc:\
" let &fillchars='vert:|,fold:-,stl:x,stlnc:y'

" Show invisible character (highlighted with NonText and SpecialKey)
" Vim: eol:$
" Nvim: tab:>\ ,trail:-,nbsp:+
" set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+

set list
let &listchars = 'tab:' . nr2char(0x25B8) . ' '
let &listchars.= ',trail:' . nr2char(0x00B7)
let &listchars.= ',extends:' . nr2char(0x276F)
let &listchars.= ',precedes:' . nr2char(0x276E)
let &listchars.= ',nbsp:' . nr2char(0x005F)
let &listchars.= ',eol:' . nr2char(0x00AC)

" Folding {{{1

" Add a bit extra margin to the left
"set foldcolumn=1

set foldmethod=indent
set foldnestmax=3
set nofoldenable

" Scrolling {{{1

" Start scrolling before the window border
if !&scrolloff
  set scrolloff=1
endif

if !&sidescrolloff
  set sidescrolloff=5
endif

if !&sidescroll
  set sidescroll=1
endif


" Colors {{{1

" Hide line number background
"highlight LineNr ctermbg=none guibg=none

" " Custom Base16 colors
" " "hi clear SignColumn
" hi VertSplit ctermfg=10 ctermbg=10
" " hi ColorColumn ctermbg=10
" hi ColorColumn ctermfg=10 ctermbg=1
" "
" " hi LineNr ctermbg=10
" hi CursorLineNr ctermfg=12
" " hi CursorLine ctermbg=10

" " Not supported by Terminal.app
" " See settings/terminal.vim
" " hi Cursor ctermfg=1 ctermbg=7

" hi MatchParen ctermfg=13 ctermbg=11

" hi IncSearch ctermfg=10 ctermbg=9
" hi Search ctermfg=10 ctermbg=3
" "hi Visual ctermfg=11 ctermbg=3

" "hi Pmenu        ctermbg=240 ctermfg=12
" "hi PmenuSel     ctermbg=3   ctermfg=1
" "hi SpellBad ctermfg=1 ctermbg=0 cterm=underline
"
" "hi SpellBad ctermfg=13 ctermbg=1
" "hi SpellCap ctermfg=13 ctermbg=9
"
" "hi CursorColumn cterm=none ctermbg=darkgray ctermfg=white guibg=darkgray guifg=white
" call matchadd('ColorColumn', '\%81v', 100) "set column nr
"
" " Hightlight text over 80 chars
" "highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" "match OverLength /\%>80v.\+/

" " Customize invisible characters color
" hi NonText ctermfg=11
" hi SpecialKey ctermfg=11

" Commands {{{1

" Enable soft wrap (break lines without breaking words)
command! -nargs=* Wrap setlocal wrap linebreak nolist

" Quick spell lang switch
command! En set spelllang=en
command! Fr set spelllang=fr


" Runtime {{{1

" if has('nvim')
"   runtime neo.vim
" endif

" 1}}}
