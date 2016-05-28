" Reverse highlight of characters on the color column
" FIXME: EOL char

" https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc
" highlight ColorColumn ctermbg=red guibg=red
" function! MarkMargin (on)
"   if exists('b:MarkMargin')
"     try
"       call matchdelete(b:MarkMargin)
"     catch /./
"     endtry
"     unlet b:MarkMargin
"   endif
"   if a:on
"     let b:MarkMargin = matchadd('ColorMargin', '\%81v', 100)
"     "let b:MarkMargin = matchadd('ColorColumn', '\%81v\s*\S', 100)
"   endif
" endfunction

" highlight ColorMargin term=reverse cterm=reverse
" augroup MarkMargin
"   autocmd!
"   autocmd ColorScheme * highlight ColorMargin term=reverse cterm=reverse
"   autocmd BufEnter * set colorcolumn= | call MarkMargin(1)
" augroup END
