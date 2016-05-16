" Whitespaces

" Remove trailing whitespaces and preserve cursor position
function! <SID>TrimWhitespace()
  let l:line = line('.')
  let l:col = col('.')
  " exe "normal mz"
  %s/\s\+$//e
  " exe "normal `z"
  call cursor(l:line, l:col)
endfunction

augroup MatchWitespace
  autocmd!
  " Remove trailing whitespaces on save
  autocmd BufWritePre * call <SID>TrimWhitespace()
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
