" Base16 colors
" vim: et sts=2 sw=2 ts=2

" github.com/vim-airline/vim-airline-themes/blob/master/autoload/airline/themes/base16_ocean.vim

let s:gui00 = "#2b303b"
let s:gui01 = "#343d46"
let s:gui02 = "#4f5b66"
let s:gui03 = "#65737e"
let s:gui04 = "#a7adba"
let s:gui05 = "#c0c5ce"
let s:gui06 = "#dfe1e8"
let s:gui07 = "#eff1f5"
let s:gui08 = "#bf616a"
let s:gui09 = "#d08770"
let s:gui0A = "#ebcb8b"
let s:gui0B = "#a3be8c"
let s:gui0C = "#96b5b4"
let s:gui0D = "#8fa1b3"
let s:gui0E = "#b48ead"
let s:gui0F = "#ab7967"

let s:cterm00 = 23
let s:cterm01 = 59
let s:cterm02 = 59
let s:cterm03 = 60
let s:cterm04 = 145
let s:cterm05 = 152
let s:cterm06 = 188
let s:cterm07 = 15
let s:cterm08 = 131
let s:cterm09 = 173
let s:cterm0A = 186
let s:cterm0B = 144
let s:cterm0C = 109
let s:cterm0D = 109
let s:cterm0E = 139
let s:cterm0F = 137

call statusline#utils#define('g:statusline#themes#base16_ocean#colors', {})

" Palette
"let g:statusline#themes#base16_ocean#colors.dark = 'ctermfg=11 ctermbg=0'
"let g:statusline#themes#base16_ocean#colors.base = 'ctermfg=12 ctermbg=10'
"let g:statusline#themes#base16_ocean#colors.white = 'ctermfg=13 ctermbg=10'
"let g:statusline#themes#base16_ocean#colors.bright = 'ctermfg=13 ctermbg=11' " fg=12|13

" Mode colors
"let g:statusline#themes#base16_ocean#colors.normal = 'ctermfg=10 ctermbg=4'
"let g:statusline#themes#base16_ocean#colors.insert = 'ctermfg=10 ctermbg=2'
"let g:statusline#themes#base16_ocean#colors.replace = 'ctermfg=13 ctermbg=1' " fg=10
"let g:statusline#themes#base16_ocean#colors.visual = 'ctermfg=10 ctermbg=3'

let s:map = {
  \ 'dark': 'ctermfg=8 ctermbg=0',
  \ 'base': 'ctermfg=12 ctermbg=10',
  \ 'bright': 'ctermfg=13 ctermbg=11',
  \ 'white': 'ctermfg=13 ctermbg=10',
  \ 'normal': 'ctermfg=10 ctermbg=4',
  \ 'insert': 'ctermfg=10 ctermbg=2',
  \ 'replace': 'ctermfg=13 ctermbg=1',
  \ 'visual': 'ctermfg=10 ctermbg=3',
  \ }

call extend(g:statusline#themes#base16_ocean#colors, s:map, 'force')
"call statusline#utils#highlight('', s:map.base)
"call statusline#utils#highlight('NC', s:map.dark)
hi StatusLine ctermfg=12 ctermbg=10
hi StatusLineNC ctermfg=8 ctermbg=0

