" Whitespaces
" FIXME: restrict filetype (e.g. not .py)

" Highlight trailing witespaces in red
" highlight ExtraWhitespace ctermbg=red guibg=red
" match ExtraWhitespace /\s\+$/

" Remove trailing whitespaces and preserve cursor position
function! TrimWhitespace()
  exe "normal mz"
  %s/\s\+$//e
  exe "normal `z"
endfunction

augroup MatchWitespace
  autocmd!
  " Remove trailing whitespaces on save
  " autocmd BufWritePre * :%s/\s\+$//e
  autocmd BufWritePre * :call TrimWhitespace()
  " autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
  " autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
  " autocmd InsertLeave * match ExtraWhitespace /\s\+$/
  " autocmd BufWinLeave * call clearmatches()
augroup END
