" Fugitive

" Open the parent in a tree buffer (go up one directory)
"autocmd User fugitive
"  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
"  \   nnoremap <buffer> .. :edit %:h<CR> |
"  \ endif

" Auto-clean git objects buffers
autocmd BufReadPost fugitive://* set bufhidden=delete
