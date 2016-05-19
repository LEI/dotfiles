" Vim statusline

" https://github.com/itchyny/lightline.vim
" https://github.com/tpope/vim-flagship
" https://github.com/vim-airline/vim-airline

if get(g:, 'loaded_statusline', 0)
  finish
endif
let g:loaded_statusline = 1

" %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

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

if !exists('g:statusline')
  let g:statusline = {}
endif

call extend(g:statusline, { 'modes': {}, 'symbols': {}, }, 'keep')

call extend(g:statusline.modes, {
      \ 'n': 'NORMAL',
      \ 'i': 'INSERT',
      \ 'R': 'REPLACE',
      \ 'v': 'VISUAL',
      \ 'V': 'V-LINE',
      \ 'c': 'COMMAND',
      \ '': 'V-BLOCK',
      \ 's': 'SELECT',
      \ 'S': 'S-LINE',
      \ '': 'S-BLOCK',
\}, 'keep')

" Branch: system('uname -s')[:5] ==? 'Darwin' ? nr2char(0x2387) . ' ' : ''
" Close: nr2char(0x2715)
" Lock: nr2char(0x1F512)
" |- nr2char(0x251C),
call extend(g:statusline.symbols, {
      \ 'branch': '',
      \ 'key': nr2char(0x1F511) . ' ',
      \ 'readonly': 'RO',
      \ 'paste': '(paste)',
      \ 'separator': nr2char(0x2502),
\}, 'keep')

unlet! s:did_setup
function StatuslineEnter() abort
  if !exists('s:did_setup')
    if empty(&g:statusline)
      setglobal statusline=%!Statusline()
    endif
    if &laststatus == 1
      set laststatus=2
    endif
    let s:did_setup = 1
  endif
endfunction

function! StatuslineColors() abort
  if &background == 'dark'
    highlight StatusLineInsert ctermfg=0 ctermbg=2
    highlight StatusLineReplace ctermfg=0 ctermbg=9
  else
    highlight StatusLineInsert ctermfg=7 ctermbg=2
    highlight StatusLineReplace ctermfg=7 ctermbg=9
  endif
endfunction

function! StatuslineHighlight(...) abort
  let l:mode = a:0 ? a:1 : ''
  if l:mode == 'i'
    " insert mode
    highlight! link StatusLine StatusLineInsert
  elseif l:mode == 'r'
    " replace mode
    highlight! link StatusLine StatusLineReplace
  elseif l:mode == 'v'
    " virtual replace mode
    highlight! link StatusLine StatusLineReplace
  " elseif strlen(l:mode) > 0
  "   echom 'unknown mode: ' . l:mode
  else
    highlight link StatusLine NONE
  endif
endfunction

function! Statusline(...) abort
  let o = a:0 ? a:1 : {}
  call extend(o, { 'mode': 1, 'branch': 1, 'flags': 1, 'title': '%< %f' }, 'keep')
  let sep = get(g:statusline.symbols, 'separator')

  let s = ''

  " Mode
  if o.mode
    let s.= s:wrap('%{winnr() == ' . winnr() . ' ? get(g:statusline.modes, mode(), mode()) . (&paste ? " PASTE" : "") : "------"}', sep)
  endif

  " Branch
  if o.branch
    let s.= s:wrap('%{exists("*fugitive#head") ? fugitive#head(7) : ""}', sep)
  endif

  if strlen(o.title) > 0
    let s.= o.title
  endif

  " Flags
  if o.flags
    let s.= s:wrap('[%H%R%M]')
  endif
  " let s.= s:wrap('%h%r%m')
  " let l:flags = []
  " if &buftype == 'help'
  "   call add(l:flags, 'H')
  " elseif &buftype != 'nofile' && &filetype !~ 'help\|netrw\|qf\|vim-plug'
  "   if &readonly
  "     call add(l:flags, g:statusline.symbols.readonly)
  "   endif
  "   if &modified
  "     call add(l:flags, '+')
  "   elseif !&modifiable
  "     call add(l:flags, '-')
  "   endif
  " endif

  " let s.= '%='

  let r = ''

  let r.= '%#ErrorMsg#'
  let r.= '%( %{exists("g:loaded_syntastic_plugin") ? SyntasticStatuslineFlag() : ""} %)'
  let r.= '%*'

  " File encoding
  " let enc = '%{&fenc!="" ? &fenc : &enc}'
  " let enc.= '%{exists("+bomb") && &bomb ? ",B" : ""}'
  " let r.= s:wrap('%{&fileformat} [' . enc . ']', sep)

  " File type (%y)
  let r.= s:wrap('%{&filetype!="" ? &filetype : "no ft"}', sep)

  " if &ruler
  if empty(&rulerformat)
    let r.= ' %-14.(%l,%c%V%) %P'
  else
    let r.= ' ' . &rulerformat
  endif

  if strlen(r) > 0
    let s.= '%=' . r . ' '
  endif

  return s
endfunction

function! s:wrap(string, ...)
  let l:separator = a:0 ? a:1 : ''
  if strlen(l:separator) > 0
    let l:separator = ' ' . l:separator
  endif
  return '%( ' . a:string . l:separator . '%)'
endfunction

augroup Statusline
  autocmd!

  " Create the highlight groups on startup and when the colorscheme changes
  autocmd VimEnter,ColorScheme * call StatuslineColors() | redrawstatus

  " Buffer: WinEnter,BufEnter,BufAdd
  autocmd BufWinEnter * if &ft!~'qf' | setlocal statusline=%!Statusline() | endif

  " Command Line Mode: CmdWinEnter,CmdWinLeave
  autocmd CmdWinEnter * let &l:statusline='%!Statusline({"branch": 0})'

  " Quickfix Location List: QuickFixCmdPre,QuickFixCmdPost
  autocmd FileType qf let &l:statusline = '%!Statusline({"mode": 0, "branch": 0, "flags": 0, "title": " %f%< %{w:quickfix_title}"})'

  " Update the statusline highlight group
  autocmd InsertEnter * call StatuslineHighlight(v:insertmode)
  autocmd InsertChange * call StatuslineHighlight(v:insertmode)
  autocmd InsertLeave * call StatuslineHighlight() | redrawstatus
  " autocmd BufWritePost * redrawstatus
augroup END
