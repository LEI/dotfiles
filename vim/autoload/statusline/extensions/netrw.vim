" Netrw

" github.com/vim-airline/vim-airline/blob/master/autoload/airline/extensions/netrw.vim

function statusline#extensions#netrw#sortBy()
  return g:netrw_sort_by
endfunction

function statusline#extensions#netrw#order()
  let l:order = (g:netrw_sort_direction =~ 'n') ? '+' : '-'
  return l:order
endfunction
