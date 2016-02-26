" extend
" vim: st=2 sts=2 sw=2

" github.com/vim-airline/vim-airline/blob/master/autoload/airline/extend.vim

function statusline#extend#load()

  if get(g:, 'loaded_ctrlp', 0)
    "call statusline#extend#ctrlp#load()
  endif

  if exists('*fugitive#head')
    call statusline#extend#fugitive#load()
  endif

  if get(g:, 'loaded_syntastic_plugin', 0)
    call statusline#extend#syntastic#load()
  endif

endfunction
