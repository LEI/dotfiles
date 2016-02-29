" Base16 colors
" vim: et sts=2 sw=2 ts=2

call statusline#utils#define('g:statusline#themes#dark#palette', {})

" Called in the builder to map the template highlight groups
let s:palette = {
  \  'default': 'StatusLine',
  \  'inactive': 'StatusLineNC',
  \  'insert': 'StatusLineInsert',
  \  'normal': 'StatusLineNormal',
  \  'replace': 'StatusLineReplace',
  \  'visual': 'StatusLineVisual',
  \  'select': 'StatusLineVisual',
  \  'command': 3,
  \  'warning': 9,
  \  'bg': 1,
  \  'base': 2,
  \  'file': 3,
  \ }

" Default groups
hi StatusLine ctermfg=13 ctermbg=11
hi StatusLineNC ctermfg=8 ctermbg=10

" Custom groups
hi StatusLineInsert ctermfg=10 ctermbg=2
hi StatusLineNormal ctermfg=10 ctermbg=4
hi StatusLineReplace ctermfg=13 ctermbg=1
hi StatusLineVisual ctermfg=10 ctermbg=3

" User groups
hi User1 ctermfg=8 ctermbg=0
hi User2 ctermfg=12 ctermbg=10
hi User3 ctermfg=13 ctermbg=10

" WarningMsg
hi User9 ctermfg=13 ctermbg=1

"set fillchars+=stl:\ ,stlnc:\
"set showmode
"hi ModeMsg ctermfg=11

call extend(g:statusline#themes#dark#palette, s:palette, 'force')
