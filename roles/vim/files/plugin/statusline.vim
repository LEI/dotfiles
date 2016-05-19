" Vim statusline

" https://github.com/itchyny/lightline.vim
" https://github.com/tpope/vim-flagship
" https://github.com/vim-airline/vim-airline

if get(g:, 'loaded_statusline', 0)
  finish
endif
let g:loaded_statusline = 1

" Default Statusline:
" %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

" Variables {{{

if !exists('g:statusline')
  let g:statusline = {}
endif

call extend(g:statusline, { 'modes': {}, 'symbols': {}, 'parts': {} }, 'keep')

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
      \ }, 'keep')

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
      \ }, 'keep')

" Format Markers:
"   %< truncation point
"   %n buffer number
"   %f relative path to file (%t -> tail?)
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
call extend(g:statusline.parts, {
      \ 'mode': {'minwidth': 20},
      \ 'branch': {'minwidth': 60},
      \ 'buffer': '%f',
      \ 'flags': 1,
      \ 'errors': 1,
      \ 'filetype': {'minwidth': 80},
      \ 'fileinfo': {'minwidth': 80},
      \ 'ruler': {'minwidth': 40},
      \ }, 'keep')

let s:ep = get(g:statusline.symbols, 'separator')

let g:statusline.quickfix = {'mode': 0, 'buffer': '%t%{exists("w:quickfix_title") ? " " . w:quickfix_title : ""}', 'flags': 0, 'filetype': 0, 'fileinfo': 0}
let g:statusline.commandline = {'branch': 0, 'filetype': 0, 'fileinfo': 0}

" }}}

" Normal Buffer: WinEnter,BufEnter,BufAdd
" autocmd BufWinEnter * if &filetype!~'qf' | setlocal statusline=%!Statusline() | endif
" Quickfix Location List: QuickFixCmdPre,QuickFixCmdPost / BufWinEnter quickfix
" %t%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''} %=%-15(%l,%c%V%) %P
" autocmd FileType qf let &l:statusline = '%!Statusline({"mode": 0, "branch": 0, "flags": 0, "title": " %f %{w:quickfix_title}"})'
" autocmd BufWinEnter quickfix let b:statusline = {'mode': 0,'title': '%t%f%{exists("w:quickfix_title") ? " ".w:quickfix_title : ""}'}
" Command Line Mode: CmdWinEnter,CmdWinLeave
" autocmd CmdWinEnter * let &l:statusline='%!Statusline({"branch": 0})'
augroup Statusline
  autocmd!
  " Create the highlight groups on startup and when the colorscheme changes
  autocmd VimEnter,ColorScheme * call StatuslineInit() | redrawstatus
  " Adjust statusline according to the context
  autocmd FileType qf setlocal statusline=%!Statusline(g:statusline.quickfix)
  autocmd CmdWinEnter * let b:statusline = g:statusline.commandline
  " Change the statusline color and redraw faster
  autocmd InsertEnter * call StatuslineHighlight(v:insertmode)
  autocmd InsertChange * call StatuslineHighlight(v:insertmode)
  autocmd InsertLeave * call StatuslineHighlight() | redrawstatus
  " autocmd BufWritePost * redrawstatus
augroup END

function! StatuslineInit() abort
  if &background == 'dark'
    highlight StatusLineInsert ctermfg=0 ctermbg=2
    highlight StatusLineReplace ctermfg=0 ctermbg=9
  else
    highlight StatusLineInsert ctermfg=7 ctermbg=2
    highlight StatusLineReplace ctermfg=7 ctermbg=9
  endif
  if &laststatus == 1
    set laststatus=2
  endif
  setglobal statusline=%!Statusline()
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
  let o = a:0 ? a:1 : get(b:, 'statusline', {}) " get(w:, 'statusline', {}))
  call extend(o, g:statusline.parts, 'keep')

  " LEFT
  let l = ''

  if s:show(o.mode)
    let l.= s:wrap('%{winnr() == ' . winnr() . ' ? get(g:statusline.modes, mode(), mode()) . (&paste ? " PASTE" : "") : "------"}', s:ep)
  endif

  if s:show(o.branch)
    let l.= s:wrap('%{exists("*fugitive#head") ? fugitive#head(7) : ""}', s:ep)
  endif

  let l.= '%< '

  if s:show(o.buffer)
    let l.= o.buffer
  endif

  if s:show(o.flags)
    let l.= s:wrap('[%H%R%M]')
  endif
  " let l.= s:wrap('%h%r%m')
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

  " let l.= '%='

  " RIGHT
  let r = ''

  " Syntax checker
  if s:show(o.errors)
    let r.= '%#ErrorMsg#'
    let r.= '%( %{exists("g:loaded_syntastic_plugin") ? SyntasticStatuslineFlag() : ""} %)'
    let r.= '%*'
  endif

  " File type (%y)
  if s:show(o.filetype)
    let r.= s:wrap('%{&filetype!="" ? &filetype : "no ft"}', s:ep)
  endif

  " File format and encoding
  if s:show(o.fileinfo)
    let enc = '%{&fenc!="" ? &fenc : &enc}'
    let enc.= '%{exists("+bomb") && &bomb ? ",B" : ""}'
    let r.= s:wrap('%{&fileformat} [' . enc . ']', s:ep)
  endif

  if &ruler && s:show(o.ruler)
    if empty(&rulerformat)
      let &rulerformat = ' %-14.(%l,%c%V/%L%) %P'
    endif
    let r.= ' ' . &rulerformat
  endif

  if strlen(r) > 0
    let l.= '%=' . r . ' '
  endif

  return l
endfunction

function! s:show(o)
  let valid = 0

  if type(a:o) == type(0)
    let valid = a:o
  elseif type(a:o) == type('')
    let valid = strlen(a:o) > 0
  elseif type(a:o) == type({})
    if exists('a:o.minwidth') && winwidth(0) < a:o.minwidth
      let valid = 0
    else
      let valid = 1
    endif
  endif

  return valid
endfunction

function! s:wrap(string, ...)
  let l:separator = a:0 ? a:1 : ''
  if strlen(l:separator) > 0
    let l:separator = ' ' . l:separator
  endif
  return '%( ' . a:string . l:separator . '%)'
endfunction
