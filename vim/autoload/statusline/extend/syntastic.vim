" Errors and warnings
" vim: et sts=2 st=2 sw=2

if !exists(':SyntasticCheck')
  finish
endif

function statusline#extend#syntastic#flags()
  let l:warnings = SyntasticStatuslineFlag()

  if strlen(l:warnings) > 0
    return l:warnings
  endif

  return ''
endfunction

function statusline#extend#syntastic#load()
  call statusline#extend('syntastic', { 'function': 'statusline#extend#syntastic#flags' })
endfunction
