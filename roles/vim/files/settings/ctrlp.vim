" CtrlP
" https://github.com/skwp/dotfiles/blob/master/vim/settings/ctrlp.vim

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

" https://github.com/ggreer/the_silver_searcher
" https://github.com/thoughtbot/dotfiles/blob/master/vimrc
if executable('ag')
  " Use The Silver Searcher in CtrlP for listing files, fast and respects
  " .gitignore and .agignore, ignores hidden files by default
  let g:ctrlp_user_command = 'ag --nogroup --nocolor --files-with-matches --hidden --ignore .git -g "" --literal %s'
  " --ignore-case
  " Disable per-session caching
  let g:ctrlp_use_caching = 0
else
  " Exclude .gitignore paths
  let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
endif
