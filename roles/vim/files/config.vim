"
" ~/.vim/vimrc
"
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

if has('autocmd')
  " Enable filetype detection
  filetype plugin indent on
endif

if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8
endif

if &history < 1000
  set history=1000
endif

" Reload unmodified files when changes are detected outside
set autoread

" Automatically :write before running commands
" set autowrite

"if has('path_extra')
""  setglobal tags-=./tags tags-=./tags; tags^=./tags;
"endif

"if &shell =~# 'fish$'
"  set shell=/bin/bash
"endif

if &tabpagemax < 50
  set tabpagemax=50
endif

" Use Unix as the standard file type
set fileformats=unix,dos,mac

" Use system clipboard
set clipboard=unnamed

" Delete comment character when joining commented lines
if v:version > 703 || v:version == 703 && has('patch541')
  set formatoptions+=j
endif
" TODO fo+=t when wrap is on (after ft)

" Do not scan included files (ctags?)
set complete-=i

" Autocompete with dictionnary words when spell check is on
set complete+=kspell

" Disable octal format for number processing using CTRL-A
set nrformats-=octal

" Keep the cursor on the same column if possible
set nostartofline

" Modified buffers can persist in the background
set hidden

" Don't redraw while executing macros
set lazyredraw

" Allow setting some options at the beginning and end of the file
set modeline
" Number of lines checked for set commands
set modelines=2

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

" Backups {{{1

" Do not capture all global options
set sessionoptions-=options

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
"set viminfo='10,\"100,:20,%,n~/.viminfo
if !empty(&viminfo)
  set viminfo^=!
endif

" Disable swapfiles and backups
set noswapfile
set nobackup
set nowritebackup

" Keep undo history across sessions, by storing in file.
if has('persistent_undo')
  let g:vim_backups = expand('~/.vim/backups')
  if !isdirectory(g:vim_backups)
    execute 'silent !mkdir ' . g:vim_backups . ' > /dev/null 2>&1'
  endif
  let &undodir = g:vim_backups
  set undofile
endif

" Diff {{{1

" Always use vertical diffs
set diffopt+=vertical

" Interface {{{1

" Normal backspace in insert mode
set backspace=indent,eol,start

" Recognize escape immediately
set esckeys

" Set the window title
set title

" Highlight current line
set cursorline

" set showtabline=2

" set guioptions-=e

" Always show current position
set ruler

" set rulerformat=%-14(%l,%c%V%)\ %P

" Always show the status line
set laststatus=2

" if strlen(&stl) == 0
set statusline=%!statusline#build()

set display+=lastline

" Invoke completion on <Tab> in commande line mode
set wildmenu

" Complete longest common string, then each full match
set wildmode=longest,full

" Use <Left> and <Right> keys to move the cursor
" instead of selecting a different match:
cnoremap <Left> <Space><BS><Left>
cnoremap <Right> <Space><BS><Right>

" Height of the command bar
set cmdheight=2

" Display current mode
set noshowmode

" Display incomplete commands
set showcmd

" Line numbers
set number

" Use relative line numbers
if exists('&relativenumber')
  set relativenumber
endif

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

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Shorter messages
set shortmess=atI

set noerrorbells
set visualbell
set t_vb=

" Indentation {{{1

" shiftround?

" set sw=4 sts=4 ts=4 et
function! SetTabSize(...)
  let l:tabsize = a:0 ? a:1 : 4
  " Indent commands
 let &shiftwidth = l:tabsize
  " Set the number of columns for a tab
  let &softtabstop = l:tabsize
  " Visual width of a tabulation
  let &tabstop = l:tabsize
endfunction

if !exists('g:loaded_sleuth')
  " Use spaces instead of tabs
  set expandtab
  call SetTabSize()
endif

" Copy ident from curreent line when starting a new line
set autoindent

" Smart autoindenting when starting a new line
set smartindent

" Make <Tab> insert indents instead of tabs at the beginning of a line
set smarttab

" Don't wrap lines by default (changed in ftplugin)
set nowrap
" set textwidth=79

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

" Search {{{1

set gdefault

" Highlight previous search matches
set hlsearch

" Show matches while typing
set incsearch

" Ignore case in search patterns
set ignorecase

" Do not ignore case when the pattern contains upper case characters
set smartcase

" Changes the special characters that can be used in search patterns
set magic

" Terminal {{{1

if has('mouse')
  set mouse+=a
endif

if !has('nvim')
  " Fix mouse inside screen and tmux (e.g. drag splits)
  if &term =~# '^screen' || strlen($TMUX) > 0
      set ttymouse=xterm2
  endif
" Fast terminal connection
  set ttyfast
endif

" FIXME: Graphical issues if not xterm-256color (currently set by tmux)
" set term=$TERM screen-256color xterm-256color

if &term =~# '256color'
  " Disable Background Color Erase (BCE) so that color schemes
  " work properly when Vim is used inside tmux and GNU screen.
  " See also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif

" " Allow color schemes to do bright colors without forcing bold
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
  set t_Co=16
endif

" Colors {{{1

" Enable syntax highlighting
if has('syntax') && (&t_Co > 2 || has('gui_running')) && !exists('syntax_on')
  syntax enable
endif

set synmaxcol=500

if exists('+colorcolumn')
  " set colorcolumn=80
  " Relative to textwidth
  set colorcolumn=+1
  "let &colorcolumn=join(range(1,80),",")
endif

call background#set()
try
  " let g:solarized_termtrans = 1
  colorscheme solarized
  call togglebg#map('<F5>')
catch /E185:/
  " Default color scheme
  colorscheme desert
endtry

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

" Key mappings {{{1

" Change leader
let g:mapleader = "\<Space>"

" Move vertically on wrapped lines
nnoremap j gj
nnoremap k gk

" Quicker split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" if has('nvim')
"  nmap <BS> <C-w>h
" endif
" https://github.com/neovim/neovim/issues/2048#issuecomment-78045837
" Note: OSX terminfo maps <C-h> to backspace: kbs=^H -> kbs=\177(ascii del)
" infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > $TERM.ti
" tic $TERM.ti

" Repeat latest f, t, F or T [count] times
noremap <Tab> ;
" Repeat last command on next match
noremap ; :normal n.<CR>
" ; ? nnoremap Q :normal n.<CR>

" Yank from the cursor to the end of the line
map Y y$

" Visually select the whole buffer (use :% to operate on the entire file)
" noremap <Leader>a <Esc>ggVG
nmap gA ggVG

" Vimcast #26 Bubbling text
" Cf. settings/unimpaired.vim

" Visually select the text that was last edited/pasted
nmap gV `[v`]

" Bubble single lines
nmap <C-Up> ddkP
nmap <C-Down> ddp
" Bubble multiple lines
vmap <C-Up> xkP`[V`]
vmap <C-Down> xp`[V`]

" Remap C-Left and C-Right?
" noremap <Tab> v>
" noremap <S-Tab> v<
" vnoremap <Tab> >gv
" vnoremap <S-Tab> <gv

" Edit in the same directory as the current file
" cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<CR>

" Clear highlighted search results
nnoremap <Space> :nohlsearch<CR>
" noremap <Leader><Space> :nohlsearch<CR>

" Start new undoable edit in insert mode instead of deleting all entered
" characters in the current line
" inoremap <C-U> <C-G>u<C-U>

" Do not use arrows
" nnoremap <up> <nop>
" nnoremap <down> <nop>
" nnoremap <left> <nop>
" nnoremap <right> <nop>
" inoremap <up> <nop>
" inoremap <down> <nop>
" inoremap <left> <nop>
" inoremap <right> <nop>

" Switch between the last two files
nnoremap <Leader><Leader> <C-^>

" Edit in window
noremap <Leader>ew :e %%
" Edit in split
noremap <Leader>es :sp %%
" Edit in vertical split
noremap <Leader>ev :vsp %%
" Edit in tab
noremap <Leader>et :tabe %%

" Quicker quit
noremap <Leader>q :q<CR>
" Save a file
noremap <Leader>w :w<CR>
" Save as root (or use :SudoWrite)
noremap <Leader>W :w !sudo tee % > /dev/null<CR>

" Remove trailing whitespaces (see TrimWhitespace())
" noremap <Leader><BS> :%s/\s\+$//e<CR>

" Sort css properties
" nnoremap <Leader>S ?{<CR>jV/^\s*\}?$<CR>k:sort<CR>:noh<CR>

" Git shortcuts
" noremap <Leader>b :Gblame<cr>
" noremap <Leader>l :!clear && git log -p %<CR>
" noremap <Leader>d :!clear && git diff %<CR>

" Edit '.vimrc' in a new split
nnoremap <Leader>rc <C-w><C-v><C-l>:e $MYVIMRC<CR>

" Runtime {{{1

" if filereadable(expand('~/.vimrc.local'))
"   source ~/.vimrc.local
" endif

" if has('nvim')
"   runtime neo.vim
" endif

" 1}}}
" vim: foldenable foldmethod=marker et sts=2 sw=2 ts=2
