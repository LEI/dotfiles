" Syntastic

" Specific syntax checkers
let g:syntastic_javascript_checkers = ['jshint']

" https://github.com/scrooloose/syntastic/wiki/VimL:---vimlint#checker-options
" Ignore undefined variable (unlet before continue in for E706)
" let g:syntastic_vimlint_options = { 'EVL101': 1 }

" Ignore specific levels
"let g:syntastic_quiet_messages = {'level': 'warnings'}

" Run each checker in turn and stop to display errors
let g:syntastic_aggregate_errors = 0

" Run syntax checks when buffers are first loaded or on saving
let g:syntastic_check_on_open = 1

" Skip checks when buffers are written
let g:syntastic_check_on_wq = 0

" Always stick detected errors into the location list
let g:syntastic_always_populate_loc_list = 1

" Automatically open when errors are detected, close when none
let g:syntastic_auto_loc_list = 1

" Location list height
let g:syntastic_loc_list_height = 5

" Status line message format
" Default: [Syntax: line:%F (%t)]
" %e  - number of errors
" %w  - number of warnings
" %t  - total number of warnings and errors
" %ne - filename of file containing first error
" %nw - filename of file containing first warning
" %N  - filename of file containing first warning or error
" %pe - filename with path of file containing first error
" %pw - filename with path of file containing first warning
" %P  - filename with path of file containing first warning or error
" %fe - line number of first error
" %fw - line number of first warning
" %F  - line number of first warning or error
" %E{...} - hide the text in the brackets unless there are errors
" %W{...} - hide the text in the brackets unless there are warnings
" %B{...} - hide unless there are both warnings AND errors
let g:syntastic_stl_format = '%E{Err %fe #%e}'
let g:syntastic_stl_format.= '%B{, }'
let g:syntastic_stl_format.= '%W{Warn %fw #%w}'

" Symbols
"let g:syntastic_error_symbol = "✗" " ☠
"let g:syntastic_warning_symbol = "!" " ⚠
"let g:syntastic_style_error_symbol = "☢"
"let g:syntastic_style_warning_error = "⚠"

" Statusline highlight: WarningMsg
" Custom one: StatusLineWarning

" Error highlighting, links to 'SpellBad' by default
"hi SyntasticError ctermfg=13 ctermbg=0
" Warning highlighting, links to 'SpellCap' by default
"hi SyntasticWarning ctermfg=12 ctermbg=9

" Highlight the line where a sign resides
"hi SyntasticErrorLine
"hi SyntasticWarningLine

" Syntax errors, links to 'error' by default
"hi SyntasticErrorSign
" Syntax warnings, links to 'todo' by default
"hi SyntasticWarningSign
