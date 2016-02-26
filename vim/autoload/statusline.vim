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

" Variables {{{1

call statusline#utils#define('g:statusline', {})
call statusline#utils#define('g:statusline#mode_map', {})
call extend(g:statusline#mode_map, {
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

" Colors {{{2

if !exists('g:statusline_colors')
  let g:statusline_colors={}
endif

call statusline#utils#define('g:statusline_colors', {})

" Palette
let g:statusline_colors.dark = 'ctermfg=11 ctermbg=0'
let g:statusline_colors.base = 'ctermfg=12 ctermbg=10'
let g:statusline_colors.white = 'ctermfg=13 ctermbg=10'
let g:statusline_colors.bright = 'ctermfg=13 ctermbg=11' " fg=12|13

" Mode colors
let g:statusline_colors.normal = 'ctermfg=10 ctermbg=4'
let g:statusline_colors.insert = 'ctermfg=10 ctermbg=2'
let g:statusline_colors.replace = 'ctermfg=13 ctermbg=1' " fg=10
let g:statusline_colors.visual = 'ctermfg=10 ctermbg=3'

" Functions {{{1

let s:items = {}

" github.com/vim-scripts/genutils/blob/master/autoload/genutils.vim
" v:version >= 704
function s:invoke(funcList, ...)
  if len(a:funcList) != 0
    for funcName in keys(a:funcList)
      "echo funcName

      "let result = call(funcName, [])
      "if result != -1
      "  echom result
      "endif
    endfor
  endif
endfunction

function statusline#extend(name, opts)
  let s:items[a:name] = get(s:items, a:name, {})
  call extend(s:items[a:name], a:opts, 'force')
endfunction

function statusline#init()
  "let args = get(a:options, 'arguments', [])

  " Build items
  call statusline#extend('mode', { 'function': 'statusline#build#mode' })

  call s:invoke(map(s:items, 'v:val.function'))

  " Add extensions
  call statusline#extend#load()
endfunction

function statusline#build()
  let l:l=''

  " Display colored mode
  let l:l.='%#StatusLineModeBold#'
  let l:l.='%( %{statusline#build#mode()} %)'

  let l:l.='%#StatusLineMode#'
  let l:l.='%(%{statusline#build#hasPaste()} %)'


  " Current branch
  "let l:l.='%#StatusLineBrightBold#'
  "let l:l.='%( %{statusline#extend#fugitive()} %)'


  " Reset color to default highlight groupe 'StatusLine'
  let l:l.='%*'

  " File segment
  let l:l.='%#StatusLineFile#'
  " Break point
  let l:l.=' %<'
  " %n Buffer index
  let l:l.='%n'
  " %f Relative path
  let l:l.=' %f '

  " File flags
  " %H Help buffer
  " %R Readonly
  " %M Modified or unmodifiable
  let l:l.='%([%R%M] %)'

  " No color section
  "let l:l.='%#StatusLineNC#'

  "let l:l.='%#StatusLineBG#'

  " Right align past this point
  let l:l.='%='


  " Syntastic "let l:l.='%#StatusLineWarning#'
  "let l:l.='%#warningmsg#'
  "let l:l.='%( %{statusline#extend#syntastic()} %)'
  ""let l:l.='%*'

  let l:l.='%#StatusLineBG#'

  " Register
  let l:l.='%( %{v:register} %)'

  " File details
  let l:l.='%#StatusLineBase#'
  let l:l.=statusline#build#fileInfo()

  let l:l.='%#StatusLineBright#'
  let l:l.=statusline#build#filePos()

  let l:l.='%#StatusLineMode#'
  let l:l.=statusline#build#cursorPos()

  return l:l
endfunction

function statusline#set()
  let l:ine = statusline#build()


  return l:ine
endfunction
