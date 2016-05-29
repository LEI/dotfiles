" Auto reload vimrc

augroup VimReload
  autocmd!
  autocmd BufWritePost $MYVIMRC nested source %
augroup END
