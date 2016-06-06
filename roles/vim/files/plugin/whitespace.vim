" Whitespaces
" http://vimcasts.org/episodes/tidying-whitespace/
" https://github.com/bronson/vim-trailing-whitespace

" Error detected while processing BufWritePre Auto commands for "*.js":
" E488: Trailing characters
function! Preserve(command)
  " Save last search and cursor position
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business
  execute a:command
  " Clean up: restore previous search history and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

nmap _$ :call Preserve("%s/\\s\\+$//e")<CR>
nmap _= :call Preserve("normal gg=G")<CR>

augroup Witespaces
  autocmd!
  autocmd BufWritePre *.js,*.php,*.py call Preserve("%s/\\s\\+$//e")
augroup END

" TODO count & Warn() trailing?
" exe "normal mz"
" exe "normal `z"
" function! <SID>StripTrailingWhitespaces()
"   let line = line('.')
"   let col = col('.')

"   %s/\s\+$//e

"   call cursor(line, col)
" endfunction

" Highlight trailing witespaces in red
" highlight ExtraWhitespace ctermbg=red guibg=red
" match ExtraWhitespace /\s\+$/
" autocmd BufWritePre * :%s/\s\+$//e
" autocmd BufWritePre * :call TrimWhitespace()
" autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
" autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
" autocmd InsertLeave * match ExtraWhitespace /\s\+$/
" autocmd BufWinLeave * call clearmatches()
