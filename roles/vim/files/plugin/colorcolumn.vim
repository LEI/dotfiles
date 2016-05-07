" github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc

set colorcolumn=

" ctermf=none
highlight ColorColumn ctermbg=red guibg=red

function! MarkMargin (on)
  if exists('b:MarkMargin')
    try
      call matchdelete(b:MarkMargin)
    catch /./
    endtry
    unlet b:MarkMargin
  endif
  if a:on
    let b:MarkMargin = matchadd('ColorColumn', '\%81v', 100)
    "let b:MarkMargin = matchadd('ColorColumn', '\%81v\s*\S', 100)
  endif
endfunction

augroup MarkMargin
  autocmd!
  autocmd BufEnter * :call MarkMargin(1)
augroup END
