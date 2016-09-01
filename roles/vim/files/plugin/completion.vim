" Completion
" http://vim.wikia.com/wiki/Make_Vim_completion_popup_menu_work_just_like_in_an_IDE

" autocmd CompleteDone * pclose

" Breaking q: (&& bufname('%') != [Command Line])
" autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
" autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" SuperTab
" let g:SuperTabClosePreviewOnPopupClose = 1

" YouCompleteMe
let g:ycm_autoclose_preview_window_after_insertion = 1
