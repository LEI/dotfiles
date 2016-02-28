" Load theme
" vim: et st=2 sts=2 sw=2

" github.com/vim-airline/vim-airline/blob/master/autoload/airline/themes.vim

function statusline#themes#load(theme)
  let g:statusline_colors = g:statusline#themes#{a:theme}#colors
endfunction
