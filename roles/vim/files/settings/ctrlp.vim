" CtrlP

"let g:ctrlp_map = '<leader>f'
"let g:ctrlp_max_height = 30
"let g:ctrlp_working_path_mode = 0
"let g:ctrlp_match_window_reversed = 0

"let g:ctrlp_buffer_func = { 'enter': 'BrightHighlightOn', 'exit':  'BrightHighlightOff', }
"function! BrightHighlightOn()
"  hi CursorLine ctermbg=3
"endfunction
"function! BrightHighlightOff()
"  hi CursorLine ctermbg=10
"endfunction

" https://github.com/thoughtbot/dotfiles/blob/master/vimrc
" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag -Q -l --nocolor --hidden -g "" %s'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
else
  " Exclude .gitignore paths
  let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
endif
