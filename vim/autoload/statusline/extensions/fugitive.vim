" Git integration
" vim: et sts=2 st=2 sw=2

if !exists("*fugitive#head")
  finish
endif

function statusline#extensions#fugitive#branch()
  let l:branch = fugitive#head()

  if strlen(l:branch) > 0
    return g:statusline_symbols.branch.' '.l:branch
  endif

  return ''
endfunction
