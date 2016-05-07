" Restore cursor position

function! RestoreCursor()
  if line("'\"") > 0 && line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup RestoreCursor
  autocmd!
  autocmd BufReadPost * call RestoreCursor()
augroup END
