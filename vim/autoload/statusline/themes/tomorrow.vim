" Base16 colors
" vim: et sts=2 sw=2 ts=2

" base16 ocean
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

" Called in the builder to map the template highlight groups
let s:palette = {
  \  'default': 'StatusLine',
  \  'inactive': 'StatusLineNC',
  \  'insert': 'StatusLineInsert',
  \  'normal': 'StatusLineNormal',
  \  'replace': 'StatusLineReplace',
  \  'visual': 'StatusLineVisual',
  \  'select': 'StatusLineVisual',
  \  'bg': 1,
  \  'base': 2,
  \  'file': 3,
  \  'sep': 9,
  \ }

"call statusline#utils#define('g:statusline#themes#tomorrow#palette', {})
"call extend(g:statusline#themes#tomorrow#palette, s:palette, 'force')

function statusline#themes#tomorrow#load()
  " Default groups
  hi StatusLine ctermfg=7 ctermbg=11
  hi StatusLineNC ctermfg=8 ctermbg=10

  " Custom groups
  hi StatusLineInsert ctermfg=10 ctermbg=2
  hi StatusLineNormal ctermfg=10 ctermbg=4
  hi StatusLineReplace ctermfg=13 ctermbg=1
  hi StatusLineVisual ctermfg=10 ctermbg=3

  " User groups
  hi User1 ctermfg=11 ctermbg=0
  hi User2 ctermfg=8 ctermbg=10
  hi User3 ctermfg=13 ctermbg=10
  hi User9 ctermfg=11

  "hi WarningMsg ctermfg=13 ctermbg=1

  "set fillchars+=stl:\ ,stlnc:\
  "set showmode
  "hi ModeMsg ctermfg=11

  return s:palette
endfunction
