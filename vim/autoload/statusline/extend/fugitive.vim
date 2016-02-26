" Git integration
" vim: et sts=2 st=2 sw=2

if !exists("*fugitive#head")
  finish
endif

function statusline#extend#fugitive#branch()
  let l:branch = fugitive#head()

  if strlen(l:branch) > 0
    statusline#utils#truncate(g:statusline_symbols.branch.' '.l:branch, 60)
  endif

  return ''
endfunction

function statusline#extend#fugitive#load()
  call statusline#extend('fugitive', { 'function': 'statusline#extend#fugitive#branch' })
endfunction
