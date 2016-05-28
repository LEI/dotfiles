" Whitespaces

" TODO count & warn?

" Remove trailing whitespaces and preserve cursor position
" exe "normal mz"
" exe "normal `z"
function! <SID>StripTrailingWhitespaces()
  let line = line('.')
  let col = col('.')

  %s/\s\+$//e

  call cursor(line, col)
endfunction

augroup RemoveWitespace
  autocmd!
  autocmd BufWritePre * call <SID>StripTrailingWhitespaces()
augroup END

" Highlight trailing witespaces in red
" highlight ExtraWhitespace ctermbg=red guibg=red
" match ExtraWhitespace /\s\+$/
" autocmd BufWritePre * :%s/\s\+$//e
" autocmd BufWritePre * :call TrimWhitespace()
" autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
" autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
" autocmd InsertLeave * match ExtraWhitespace /\s\+$/
" autocmd BufWinLeave * call clearmatches()
