" Airline

" Does not work: not really global?
if !exists('g:loaded_airline')
  finish
endif

" Enable colorscheme
let g:airline_theme="solarized"

" Enable syntastic messages
let g:airline#extensions#syntastic#enabled=1

" Add indentation guides
let g:airline#extensions#whitespace#enabled=1

" Enable smarter list of buffers
let g:airline#extensions#tabline#enabled=1

" Show just the filename
let g:airline#extensions#tabline#fnamemod=':t'
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

if !exists('g:airline_symbols')
  let g:airline_symbols={}
endif

" Unicode symbols
let g:airline_left_sep='»'
"let g:airline_left_sep='▶'
let g:airline_left_sep=''
let g:airline_right_sep='«'
"let g:airline_right_sep='◀'
let g:airline_right_sep=''
let g:airline_symbols.crypt='🔒'
"let g:airline_symbols.linenr='␊'
let g:airline_symbols.linenr='␤'
"let g:airline_symbols.linenr='¶'
let g:airline_symbols.branch='⎇'
"let g:airline_symbols.paste='ρ'
let g:airline_symbols.paste='Þ'
"let g:airline_symbols.paste='∥'
let g:airline_symbols.whitespace='Ξ'

" Old symbols
"let g:airline_left_sep='⮀'
"let g:airline_left_alt_sep='⮁'
"let g:airline_right_sep='⮂'
"let g:airline_right_alt_sep='⮃'
"let g:airline_symbols.branch='⭠'
"let g:airline_symbols.readonly='⭤'
"let g:airline_symbols.linenr='⭡'
