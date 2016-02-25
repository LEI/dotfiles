" Statusline
" vim: foldenable foldmethod=marker

" github.com/vim-airline/vim-airline

" Options {{{1

" Always show the status line
set laststatus=2

" Do not display current mode
set noshowmode

" Display incomplete commands
set showcmd

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
  \ })

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
  \ })

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

" Render status line {{{1

function statusline#render()
  let l:l=''

  " Display colored mode
  let l:l.='%#StatusLineModeBold#'
  let l:l.='%( %{statusline#build#mode()} %)'

  let l:l.='%#StatusLineMode#'
  let l:l.='%(%{statusline#build#hasPaste()} %)'

  " Current branch
  let l:l.='%#StatusLineBrightBold#'
  let l:l.='%( %{statusline#build#branch()} %)'
  "
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
  let l:l.='%#warningmsg#'
  let l:l.='%( %{statusline#build#syntastic()} %)'
  "let l:l.='%*'

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
