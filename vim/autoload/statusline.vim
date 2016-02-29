" Statusline
" vim: et sts=2 sw=2 ts=2

" github.com/vim-airline/vim-airline

" Cheat sheet {{{1

" base16 colors (?)
" 0: black
" 1: red
" 2: green
" 3: yellow
" 4: blue
" 5: magenta
" 6: bright green (cyan)
" 7: white
" 8: bright black
" 9: bright red
" 10: deep gray (bright green)
" 11: gray (bright yellow)
" 12: light gray (bright blue)
" 13: white (bright magenta)
" 14: beige (bright cyan)
" 15: bright white

" Default statusline: %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
" Format markers:
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
"set statusline=%<\ %n:%f\ %m%r%y%=%-35.(line:\ %l\ of\ %L,\ col:\ %c%V\ (%P)%)

" Declarations {{{1

call statusline#utils#define('g:statusline', {})
call statusline#utils#define('g:statusline_theme', 'dark')
call statusline#utils#define('g:statusline_template', 'base')

" Mode map {{{2
" n      : Normal
" no     : Operator-pending
" v      : Visual by character
" V      : Visual by line
" CTRL-V : Visual blockwise
" s      : Select by character
" S      : Select by line
" CTRL-S : Select blockwise
" i      : Insert
" R      : Replace |R|
" Rv     : Virtual Replace |gR|
" c      : Command-line
" cv     : Vim Ex mode |gQ|
" ce     : Normal Ex mode |Q|
" r      : Hit-enter prompt
" rm     : The -- more -- prompt
" r?     : A confirm query of some sort
" !      : Shell or external command is executing

call statusline#utils#define('g:statusline_mode_map', {})
call extend(g:statusline_mode_map, {
  \ '__' : '------',
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
  " 't': 'TERMINAL',

" Symbols {{{2

" ⎇ /|•·
call statusline#utils#define('g:statusline_symbols', {})
call extend(g:statusline_symbols, {
  \ 'paste': 'PASTE',
  \ 'readonly': get(g:, 'powerline_fonts', 0) ? '\ue0a2' : 'RO',
  \ 'whitespace': get(g:, 'powerline_fonts', 0) ? '\u2739' : '!',
  \ 'linenr': get(g:, 'powerline_fonts', 0) ? '\ue0a1' : ':',
  \ 'branch': get(g:, 'powerline_fonts', 0) ? '\ue0a0' : '⎇ ',
  \ 'crypt': get(g:, 'crypt_symbol', nr2char(0x1F512) . ' '),
  \ 'modified': '+',
  \ 'close': '✕',
  \ 'sep': '│',
  \ }, 'keep')

" Templates {{{2
" Format: %-0{minwid}.{maxwid}{item}

call statusline#utils#define('g:statusline_tpl_minimal', [])
call extend(g:statusline_tpl_minimal, [
  \   {
  \     'highlight': 'mode',
  \     'format': ' %{statusline#core#mode()} ',
  \     'width': '-9',
  \     'truncate': 33,
  \   },
  \   '%<%f%( [%M%R]%)',
  \   '%=',
  \   '%( [%{&filetype}]%) ',
  \   '%-8.(%l,%c%V%) %p%% ',
  \ ], 'keep')

call statusline#utils#define('g:statusline_tpl_base', [])
call extend(g:statusline_tpl_base, [
  \   {
  \     'highlight': 'mode',
  \     'format': ' %{statusline#core#mode()} ',
  \     'width': '-8',
  \     'truncate': 20,
  \   },
  \   {
  \     'format': '%{statusline#core#paste()} ',
  \   },
  \   {
  \     'highlight': 'default',
  \     'format': ' %{statusline#extensions#fugitive#branch()} ',
  \     'truncate': 60,
  \   },
  \   {
  \     'highlight': 'file',
  \     'format': ' %<%n %f %([%M%R] %)'
  \   },
  \   {
  \     'format': '%{statusline#core#crypt()} ',
  \   },
  \   '%=',
  \   {
  \     'highlight': 'bg',
  \     'format': ' %{v:register} ',
  \   },
  \   {
  \     'highlight': 'base',
  \     'truncate': 80,
  \     'sep': g:statusline_symbols.sep,
  \     'items': [
  \       { 'format': ' %{&fileformat} ' },
  \       { 'format': ' %{statusline#core#encoding()} ' },
  \       { 'format': ' %{statusline#core#type()} ' },
  \     ],
  \   },
  \   {
  \     'highlight': 'default',
  \     'format': ' %P ',
  \     'width': '5',
  \     'truncate': 60,
  \   },
  \   {
  \     'highlight': 'mode',
  \     'truncate': 40,
  \     'sep': ':',
  \     'items': [
  \       { 'format': ' %l', 'width': '4' },
  \       { 'format': '%c%V ', 'width': '-4' },
  \     ],
  \   },
  \   {
  \     'highlight': 'warning',
  \     'format': ' %{statusline#extensions#syntastic#flags()} ',
  \     'truncate': 60,
  \   },
  \ ], 'keep')

" Main {{{1

let s:wins = {}

" Updates the status line in the current window
function statusline#set()
  for nr in filter(range(1, winnr('$')), 'v:val != winnr()')
  "for nr in range(1, winnr('$'))
    call s:update(nr, 0)
  endfor

  call s:update(winnr(), 1)
  "statusline#utils#getwinvar(l:winnr, 'statusline_active', 0)
endfunction

" Build status string
function statusline#build(winnr)
  let l:win = s:wins[a:winnr]
  let l:mode = s:mode(l:win.active)

  " Refresh the status line string
  " Only if the mode changed, the window was resized or the string is undefined
  if get(w:, 'statusline_mode', '') != l:mode
      \ || (exists('l:win.columns') && l:win.columns != &columns)
      \ || !exists('l:win.line')

    " Update last window mode (used in autoload/builder s:highlight)
    let w:statusline_mode = l:mode

    " Build line
    let l:line = ''
    let l:items = g:statusline_tpl_{g:statusline_template}
    for item in l:items
      let l:line.= statusline#builder#add(item, l:win)
      unlet item
    endfor

    " Update window object
    let l:win.line = l:line
    let l:win.columns = &columns
    "let s:wins[a:winnr] = l:win
  "else
    "let l:line = l:win.line
  endif

  " Send final string
  return l:win.line
endfunction

" Update local status line
function s:update(nr, active)
  let l:win = { 'nr': a:nr, 'active': a:active, 'bufnr': winbufnr(a:nr) }
  let s:wins[a:nr] = l:win

  "setlocal statusline=%!statusline#set(winnr())
  let &l:statusline = '%!statusline#build(' . l:win.nr . ')'
  "call setwinvar(l:win.nr, '&statusline', '%!statusline#set(' . l:win.nr . ')')
endfunction

" Output mode string
function s:mode(active)
  let l:m = mode()

  if a:active
    if l:m ==# 'n'
      let l:mode = ['normal']
    elseif l:m ==# 'i'
      let l:mode = ['insert']
    elseif l:m ==# 'R'
      let l:mode = ['replace']
    elseif l:m =~# '\v(v|V||s|S|)'
      let l:mode = ['visual']
    elseif l:m ==# 'c'
      let l:mode = ['command']
    elseif l:m ==# 't'
      let l:mode = ['terminal']
    else
      let l:mode = [l:m]
    endif
  else
    let l:mode = ['inactive']
  endif

  return join(l:mode)
endfunction

" github.com/vim-airline/vim-airline/blob/master/autoload/airline/themes.vim
function s:theme()
  " User defined theme
  if exists('g:statusline_theme')
    try
      let g:statusline_palette = g:statusline#themes#{g:statusline_theme}#palette
    catch
      echom 'Could not find theme "' . g:statusline_theme . '"'
    endtry
  endif

  " Default theme
  if !exists('g:statusline_palette')
    let l:theme = 'dark'
    let g:statusline_palette = g:statusline#themes#{l:theme}#palette
  endif
endfunction

function s:init()
  " Load theme at startup
  call s:theme()
endfunction

" Initialization
call s:init()

" function statusline#active(...)
"   "let l:a = get(w:, 'statusline_active', 0)
"   let l:active = a:0 > 0 ? a:1 : 'nope'
"   return l:active
" endfunction
