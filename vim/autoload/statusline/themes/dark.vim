" Base16 colors
" vim: et sts=2 sw=2 ts=2

call statusline#utils#define('g:statusline#themes#dark#palette', {})

"let s:palette = {
"  \ 'dark': 'ctermfg=8 ctermbg=0',
"  \ 'base': 'ctermfg=12 ctermbg=10',
"  \ 'bright': 'ctermfg=13 ctermbg=11',
"  \ 'white': 'ctermfg=13 ctermbg=10',
"  \ 'normal': 'ctermfg=10 ctermbg=4',
"  \ 'insert': 'ctermfg=10 ctermbg=2',
"  \ 'replace': 'ctermfg=13 ctermbg=1',
"  \ 'visual': 'ctermfg=10 ctermbg=3',
"  \ }
let s:palette = {
  \  'insert': 'StatusLineInsert',
  \  'normal': 'StatusLineNormal',
  \  'replace': 'StatusLineReplace',
  \  'visual': 'StatusLineVisual',
  \  'select': 'StatusLineVisual',
  \  'inactive': 'StatusLineNC',
  \ }

" call statusline#utils#define('g:statusline_mode_highlight', {})
" call extend(g:statusline_mode_highlight, {
"   \ 'insert': 'StatusLineInsert',
"   \ 'normal': 'StatusLineNormal',
"   \ 'replace': 'StatusLineReplace',
"   \ 'visual': 'StatusLineVisual',
"   \ 'inactive': 'StatusLineNC',
"   \ 'active': 'StatusLine',
"   \ }, 'keep')

hi StatusLine ctermfg=13 ctermbg=11
hi StatusLineNC ctermfg=8 ctermbg=10
hi StatusLineInsert ctermfg=10 ctermbg=2
hi StatusLineNormal ctermfg=10 ctermbg=4
hi StatusLineReplace ctermfg=13 ctermbg=1
hi StatusLineVisual ctermfg=10 ctermbg=3
hi StatusLineBG ctermfg=8 ctermbg=0
hi StatusLineBase ctermfg=12 ctermbg=10
hi StatusLineFile ctermfg=13 ctermbg=10

"set fillchars+=stl:\ ,stlnc:\
"set showmode
"hi ModeMsg ctermfg=11

call extend(g:statusline#themes#dark#palette, s:palette, 'force')

