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
call statusline#utils#define('g:statusline_theme', 'base16_ocean')

" Parts {{{2

call statusline#utils#define('g:statusline_list', [])
call extend(g:statusline_list, [
\ 'mode', 'paste', 'fugitive', 'buffer',
  \ '%=',
  \ 'reg', 'info', 'percent', 'cursor',
  \ ], 'keep')

call statusline#utils#define('g:statusline_parts', {})
call extend(g:statusline_parts, {
  \   'mode': {
  \     'highlight': 'StatusLineModeBold',
  \     'core': 1,
  \     'truncate': 20,
  \   },
  \   'paste': {
  \     'core': 1,
  \   },
  \   'fugitive': {
  \     'highlight': 'StatusLineBright',
  \   },
  \   'buffer': {
  \     'highlight': 'StatusLineFile',
  \     'expr': '%< %n %f%( [%R%M]%)'
  \   },
  \   'reg': {
  \     'highlight': 'StatusLineBG',
  \     'expr': '%{v:register}',
  \   },
  \   'info': {
  \     'highlight': 'StatusLineBase',
  \     'truncate': 80,
  \     'item': { 'sep': ' | ' },
  \     'items': [
  \       { 'core': 'format' },
  \       { 'core': 'encoding' },
  \       { 'core': 'type' },
  \     ],
  \   },
  \   'percent': {
  \      'highlight': 'StatusLineBright',
  \      'expr': '%P',
  \      'width': '3',
  \      'truncate': 60,
  \   },
  \   'cursor': {
  \     'highlight': 'StatusLineMode',
  \     'truncate': 40,
  \     'items': [
  \       { 'expr': '%l:', 'width': '4' },
  \       { 'expr': '%c%V', 'width': '-3' },
  \     ],
  \   },
  \ }, 'keep')

" Mode map {{{2

call statusline#utils#define('g:statusline_modes', {})
call extend(g:statusline_modes, {
  \ '__' : '------',
  \ 'n'  : 'NORMAL',
  \ 'i'  : 'INSERT',
  \ 'R'  : 'REPLACE',
  \ 'v'  : 'VISUAL',
  \ 'V'  : 'V-LINE',
  \ 'c'  : 'COMMAND',
  \ '' : 'V-BLOCK',
  \ 's'  : 'SELECT',
  \ 'S'  : 'S-LINE',
  \ '' : 'S-BLOCK',
  \ 't'  : 'TERMINAL',
  \ }, 'keep')

" Symbols {{{2

" ⎇ /|•·
call statusline#utils#define('g:statusline_symbols', {})
call extend(g:statusline_symbols, {
  \ 'paste': 'PASTE',
  \ 'readonly': get(g:, 'powerline_fonts', 0) ? "\ue0a2" : 'RO',
  \ 'whitespace': get(g:, 'powerline_fonts', 0) ? "\u2739" : '!',
  \ 'linenr': get(g:, 'powerline_fonts', 0) ? "\ue0a1" : ':',
  \ 'branch': get(g:, 'powerline_fonts', 0) ? "\ue0a0" : '⎇ ',
  \ 'crypt': get(g:, 'crypt_symbol', nr2char(0x1F512)),
  \ 'modified': '+',
  \ 'close': '✕',
  \ 'sep': '|',
  \ }, 'keep')

" Functions {{{1

function statusline#init()
  " Register core functions
  call statusline#core#load()

  " Load theme (statusline#themes#{name}#colors -> g:statusline_color)
  call statusline#themes#load(g:statusline_theme)
endfunction

function statusline#set()
  " Add extensions
  call statusline#extensions#load()

  " Build parts
  return statusline#builder#render()
endfunction
