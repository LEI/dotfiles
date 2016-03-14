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

let s:colors = {
\ 'gui': {
\   '00': '#1d1f21',
\   '01': '#282a2e',
\   '02': '#373b41',
\   '03': '#969896',
\   '04': '#b4b7b4',
\   '05': '#c5c8c6',
\   '06': '#e0e0e0',
\   '07': '#ffffff',
\   '08': '#cc6666',
\   '09': '#de935f',
\   '0A': '#f0c674',
\   '0B': '#b5bd68',
\   '0C': '#8abeb7',
\   '0D': '#81a2be',
\   '0E': '#b294bb',
\   '0F': '#a3685a',
\ },
\ 'cterm': {
\   '00': 0,
\   '01': 10,
\   '02': 11,
\   '03': 102,
\   '04': 145,
\   '05': 188,
\   '06': 253,
\   '07': 15,
\   '08': 1,
\   '09': 173,
\   '0A': 3,
\   '0B': 2,
\   '0C': 109,
\   '0D': 4,
\   '0E': 139,
\   '0F': 131,
\ }
\}

let s:scheme = [
\  {'mode': 'default', 'map': [[], [], [], ['02', '01']]},
\  {'mode': 'normal', 'map': [['01', '0D'], ['06', '02'], ['05', '01']]},
\  {'mode': 'insert', 'map': [['01', '0B'], ['06', '02'], ['06', '01']]},
\  {'mode': 'replace', 'map': [['07', '08'], ['06', '02'], ['05', '01']]},
\  {'mode': 'visual', 'map': [['01', '0A'], ['06', '02'], ['05', '01']]},
\  {'mode': 'select', 'map': [['01', '09'], ['06', '02'], ['05', '01']]},
\  {'mode': 'inactive', 'map': [['05', '01'], ['04', '01'], ['04', '01']]},
\]

" Tomorrow airline
" '00': 0,
" '01': 0,
" '02': 59,
" '03': 102,
" '04': 145,
" '05': 188,
" '06': 253,
" '07': 15,
" '08': 167,
" '09': 173,
" '0A': 222,
" '0B': 143,
" '0C': 109,
" '0D': 109,
" '0E': 139,
" '0F': 131,
" {'mode': 'normal', 'map': [['01', '0B'], ['06', '02'], ['09', '01']]},
" {'mode': 'insert', 'map': [['01', '0D'], ['06', '02'], ['09', '01']]},
" {'mode': 'replace', 'map': [['01', '08'], ['06', '02'], ['09', '01']]},
" {'mode': 'visual', 'map': [['01', '0E'], ['06', '02'], ['09', '01']]},
" {'mode': 'select', 'map': [['01', '0E'], ['06', '02'], ['09', '01']]},
" {'mode': 'inactive', 'map': [['05', '01'], ['05', '01'], ['05', '01']]},

"call statusline#utils#define('g:statusline#colorschemes#base16#palette', {})
"call extend(g:statusline#colorschemes#base16#palette, s:palette, 'force')

function statusline#colorschemes#base16#load()
  " Default groups
  hi StatusLine ctermfg=8 ctermbg=10
  hi StatusLineNC ctermfg=11 ctermbg=10

  " 'bg': 1,
  " 'base': 2,
  " 'file': 3,
  " 'sep': 9,

  " " Custom groups
  " hi StatusLineInsert ctermfg=10 ctermbg=2
  " hi StatusLineNormal ctermfg=10 ctermbg=4
  " hi StatusLineReplace ctermfg=13 ctermbg=1
  " hi StatusLineVisual ctermfg=10 ctermbg=3

  " " User groups
  " hi User1 ctermfg=11 ctermbg=0
  " hi User2 ctermfg=8 ctermbg=10
  " hi User3 ctermfg=13 ctermbg=10
  " hi User9 ctermfg=11

  "hi WarningMsg ctermfg=13 ctermbg=1

  "set fillchars+=stl:\ ,stlnc:\
  "set showmode
  "hi ModeMsg ctermfg=11

  return {'map': s:colors, 'scheme': s:scheme}
endfunction
