" Statusline
" vim: foldenable foldmethod=marker et sts=2 sw=2 ts=2

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

" Init {{{1

call statusline#utils#define('g:statusline', {})

call statusline#utils#define('g:statusline_list', [])

" Mode map {{{1

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

" github.com/vim-scripts/genutils/blob/master/autoload/genutils.vim
" v:version >= 704
function s:invoke(funcList, ...)
  if len(a:funcList) != 0
    for funcName in keys(a:funcList)
      echom funcName

      "let result = call(funcName, [])
      "if result != -1
      "  echom result
      "endif
    endfor
  endif
endfunction

function statusline#init()
  call statusline#utils#define('g:statusline_parts', {})
  call statusline#utils#define('g:statusline_theme', 'base16_ocean')

  " Load theme (statusline#themes#{name}#colors -> g:statusline_color)
  call statusline#themes#load(g:statusline_theme)

  "call s:invoke(map(g:statusline_parts, 'v:val.function'))
endfunction

function statusline#set()
  " Register core section
  call statusline#core#load()
  " Add extensions
  call statusline#extensions#load()

  " Build parts
  return statusline#builder#render()
endfunction
