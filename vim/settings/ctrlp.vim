" CtrlP

"let g:ctrlp_map = '<leader>f'
"let g:ctrlp_max_height = 30
"let g:ctrlp_working_path_mode = 0
"let g:ctrlp_match_window_reversed = 0

" Exclude .gitignore paths
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

"let g:ctrlp_buffer_func = { 'enter': 'BrightHighlightOn', 'exit':  'BrightHighlightOff', }
"function! BrightHighlightOn()
"  hi CursorLine ctermbg=3
"endfunction
"function! BrightHighlightOff()
"  hi CursorLine ctermbg=10
"endfunction
