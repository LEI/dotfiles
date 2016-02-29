" Core sections
" vim: et sts=2 sw=2 ts=2

" Display mode name
function statusline#core#mode()
  let l:m = mode()
  let l:mode = get(w:, 'statusline_mode', '')

  if l:mode =~ '^inactive'
    let l:m = l:mode
  endif

  let l:mode = get(g:statusline_mode_map, l:m, l:m)

  return l:mode
endfunction

" Returns true if paste mode is enabled
function statusline#core#paste()
  if &paste
    return g:statusline_symbols.paste
  endif
  return ''
endfunction

" File type
function statusline#core#type()
  if (&filetype!='')
    let l:type=&filetype
  else
    let l:type='no ft'
  endif

  return l:type
endfunction

" File encoding
function statusline#core#encoding()
  if (&fenc!='')
    let l:encoding=&fenc
  else
    let l:encoding=&enc
  endif

  if (exists("+bomb") && &bomb)
    let l:encoding.="[B]"
  endif

  return l:encoding
endfunction

" File format
function statusline#core#format()
  return &fileformat
endfunction
