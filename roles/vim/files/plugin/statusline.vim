" Vim statusline

if get(g:, 'loaded_statusline', 0)
  finish
endif
let g:loaded_statusline = 1

let s:save_cpo = &cpo
set cpo&vim

" Default Status Line:
"   %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

" Format Markers:
"   %< truncation point
"   %n buffer number
"   %f relative path to file
"   %m modified flag [+] (modified), [-] (unmodifiable) or nothing
"   %r readonly flag [RO]
"   %y filetype [ruby]
"   %= split point for left and right justification
"   %-35. width specification
"   %l current line number
"   %L number of lines in buffer
"   %c current column number
"   %V current virtual column number (-n), if different from %c
"   %P percentage through buffer
"   %) end of width specification

" Mode Map:
"   n       Normal
"   no      Operator-pending
"   v       Visual by character
"   V       Visual by line
"   CTRL-V  Visual blockwise
"   s       Select by character
"   S       Select by line
"   CTRL-S  Select blockwise
"   i       Insert
"   R       Replace |R|
"   Rv      Virtual Replace |gR|
"   c       Command-line
"   cv      Vim Ex mode |gQ|
"   ce      Normal Ex mode |Q|
"   r       Hit-enter prompt
"   rm      The -- more -- prompt
"   r?      A confirm query of some sort
"   !       Shell or external command is executing

let g:statusline_mode_map = {
\  'n': 'NORMAL',
\  'i': 'INSERT',
\  'R': 'REPLACE',
\  'v': 'VISUAL',
\  'V': 'V-LINE',
\  'c': 'COMMAND',
\  '': 'V-BLOCK',
\  's': 'SELECT',
\  'S': 'S-LINE',
\  '': 'S-BLOCK',
\}

let g:statusline_symbols = {
\  'paste': 'PASTE',
\  'key': nr2char(0x1F511) . ' ',
\}
"  'whitespace': get(g:, 'powerline_fonts', 0) ? '\u2739' : '!',
"  'linenr': get(g:, 'powerline_fonts', 0) ? '\ue0a1' : ':',
"  'branch': get(g:, 'powerline_fonts', 0) ? '\ue0a0' : nr2char(0x2387). ' ',
"  'readonly': get(g:, 'powerline_fonts', 0) ? '\ue0a2' : nr2char(0x1F512) . ' ',
"  'close': nr2char(0x2715),
"  'separator': nr2char(0x2502),

function! Statusline(winnr)
  let l:active = a:winnr == winnr()
  let l:mode = l:active ? mode() : '------'
  call setwinvar(a:winnr, 'mode', l:mode)

  let l:s = ''

  " Mode
  let l:s.= ' %{get(g:statusline_mode_map, w:mode, w:mode)} '
  let l:s.= '%{&paste ? g:statusline_symbols.paste . " " : ""}'

  " Buffer index
  " let l:s.= '%n'

  " Truncate
  let l:s.= '%<'

  " File path
  let l:s.= '%f '

  " Flags '%h%m%r'
  " %H HLP (help buffer)
  " %R RO (readonly)
  " %M +,- (modifiable)
  let l:s.= '%([%{StatuslineFlags()}]%)'

  " Split
  let l:s.= '%='

  " Fugitive
  if exists('*fugitive#head') && strlen(fugitive#head(7)) > 0
    let l:s.= ' %{fugitive#head(7)}'
  endif

  " Syntastic
  " if get(g:, 'loaded_syntastic_plugin', 0)
  if exists('*SyntasticStatuslineFlag') && strlen(SyntasticStatuslineFlag()) > 0
    let l:s.= '%( %#WarningMsg# %{SyntasticStatuslineFlag()} %*%)'
  endif

  " File type
  " let l:s.= ' %{&ft != "" ? "[" . &ft . "]" : ""}'
  " let l:s.= '%([%{&filetype}]%)'
  let l:s.= ' %y'

  " " File format
  " let l:s.= ' %{&fileformat}'
  " " File encoding
  " let l:s.= ' [%{&fenc != "" ? &fenc : &enc}%{exists("+bomb") && &bomb ? ",B" : ""}]'

  " Encrypted buffer (TODO: symbol)
  " if exists('+key') && !empty(&key)
  "   let l:s.= get(g:statusline_symbols, 'key', '')
  " endif

  " Cursor position
  let l:s.= ' %-12.(%l,%c%V%)'

  " File position
  let l:s.= ' %P '

  return l:s
endfunction

function! StatuslineFlags()
  let l:flags = ''

  " expand('%') == 'gundo', &buftype == 'nofile'?
  if &filetype !~ 'help\|netrw\|vim-plug'
    " %R
    let l:flags = &modified ? '+' : &modifiable ? '' : '-'
    " %M
    let l:flags.= &readonly ? ',RO' : ''
  " elseif &filetype == 'help'
  "   let l:flags = 'H'
  endif

  return l:flags
endfunction

" Solarized Statusline Colors:
" Red: 1
" Green: 2
" Yellow: 3
" Blue: 4
" Magenta: 5
" Cyan: 6
" Brightred: 9
function! StatuslineColors()
  if &background == 'dark'
    highlight Statusline term=reverse cterm=reverse ctermfg=14 ctermbg=0 gui=bold,reverse
    highlight StatuslineNC term=reverse cterm=reverse ctermfg=11 ctermbg=0 gui=reverse

    " highlight Statusline term=none cterm=none ctermfg=14 ctermbg=0 gui=bold
    " highlight StatuslineNC term=none cterm=none ctermfg=11 ctermbg=0 gui=none

    highlight StatuslineInsert ctermfg=0 ctermbg=2
    highlight StatuslineReplace ctermfg=0 ctermbg=1
  else
    highlight Statusline term=reverse cterm=reverse ctermfg=10 ctermbg=7 gui=bold,reverse
    highlight StatuslineNC term=reverse cterm=reverse ctermfg=12 ctermbg=7 gui=reverse

    " highlight Statusline term=none cterm=none ctermfg=10 ctermbg=7 gui=bold
    " highlight StatuslineNC term=none cterm=none ctermfg=12 ctermbg=7 gui=none

    highlight StatuslineInsert ctermfg=7 ctermbg=2
    highlight StatuslineReplace ctermfg=7 ctermbg=1
  endif
endfunction

function! StatuslineMode(mode)
  if a:mode == 'i'
    highlight! link Statusline StatuslineInsert
  elseif a:mode == 'r'
    highlight! link Statusline StatuslineReplace
  else
    echom 'MODE: ' . a:mode
    " highlight link Statusline NONE
  endif
endfunction

function! StatuslineUpdate()
  for nr in range(1, winnr('$'))
    call setwinvar(nr, '&statusline', '%!Statusline(' . nr . ')')
  endfor
endfunction

" set statusline=%!Statusline(winnr())
" set noshowmode

augroup Statusline
  autocmd!
  " Create the highlight groups on startup and when the colorscheme changes
  autocmd VimEnter,ColorScheme * call StatuslineColors() | redrawstatus
  " Update the statusline function (setlocal statusline=%!)
  autocmd BufAdd,BufEnter,WinEnter * call StatuslineUpdate()
  " Update the statusline highlight group
  autocmd InsertEnter * call StatuslineMode(v:insertmode)
  autocmd InsertChange * call StatuslineMode(v:insertmode)
  " Clear highlight link
  autocmd InsertLeave * highlight link Statusline NONE
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
