" Load extensions
" vim: et st=2 sts=2 sw=2

" github.com/vim-airline/vim-airline/blob/master/autoload/airline/extensions.vim

"function statusline#extensions#register(name, function)
"  if filereadable('autoload/extensions/' . a:name . '.vim')
"    call statusline#builder#add(a:name, {
"      \   'function': 'statusline#extensions#' . a:name . '#' . a:function,
"      \ })
"    echom "add" . a:name . a:function
"  endif
"endfunction

" function statusline#extensions#load()
"   "if get(g:, 'loaded_ctrlp', 0)
"     "call statusline#extensions#ctrlp#load()
"   "endif
"
"   if exists('*fugitive#head')
"     call statusline#extensions#register('fugitive', 'branch')
"   endif
"
"   if get(g:, 'loaded_syntastic_plugin', 0)
"     call statusline#extensions#register('syntastic', 'flags')
"   endif
" endfunction
