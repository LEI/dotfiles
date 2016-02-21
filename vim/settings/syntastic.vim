" Syntastic

" Syntax checkers
let g:syntastic_javascript_checkers = ['jshint']

"let g:syntastic_aggregate_errors=1
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0
let g:syntastic_loc_list_height = 5

" Symbols
"let g:syntastic_error_symbol = "✗" " ☠
"let g:syntastic_warning_symbol = "!" " ⚠
let g:syntastic_style_error_symbol = "☢"
let g:syntastic_style_warning_error = "⚠"

" Status line format
let g:syntastic_stl_format='%E{Err %fe #%e}%B{ | }%W{Warn %fw #%w}'

"hi warningmsg ctermfg=0 ctermbg=1
