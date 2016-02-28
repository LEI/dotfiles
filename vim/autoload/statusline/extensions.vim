" Load extensions
" vim: et st=2 sts=2 sw=2

" github.com/vim-airline/vim-airline/blob/master/autoload/airline/extensions.vim

function statusline#extensions#load()
  if get(g:, 'loaded_ctrlp', 0)
    "call statusline#extensions#ctrlp#load()
  endif

  if exists('*fugitive#head')
    call statusline#builder#add('fugitive', { 'function': 'statusline#extensions#fugitive#branch' })
  endif

  if get(g:, 'loaded_syntastic_plugin', 0)
    call statusline#builder#add('syntastic', { 'function': 'statusline#extensions#syntastic#flags' })
  endif
endfunction
