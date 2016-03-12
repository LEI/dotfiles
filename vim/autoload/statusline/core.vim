" Core sections
" vim: et sts=2 sw=2 ts=2

" Display mode name
function statusline#core#mode(...)
  let l:stl_mode = a:0 > 0 ? a:1 : get(w:, 'statusline_mode', '')

  if l:stl_mode =~ '^inactive'
    let l:mode = '__'
  else
    let l:mode = mode()
  endif

  return get(g:statusline.mode_map, l:mode, l:mode)
endfunction

" Returns true if paste mode is enabled
function statusline#core#paste()
  if &paste
    return g:statusline.symbols.paste
  endif

  return ''
endfunction

function statusline#core#file()
  let l:str = expand('%')
  "'string': '%{expand("%")==""?"NO NAME":expand("%")=="[Command Line]"?"COMMAND LINE":expand("%:r")} ',
  "let l:str = expand('%:t')
  if strlen(l:str) == 0
    let l:str = 'NO NAME'
  elseif l:str ==# '[Command Line]'
    let l:str = 'COMMAND LINE'
  "elseif l:str =~ '['
  "  let l:str = '[' . l:str . ']'
  elseif &filetype =~ 'help'
    let l:str = expand('%:t') . ' [?]'
  else
    let l:str = fnamemodify(l:str, ':p:~')
  endif

  return l:str
endfunction

" File type
function statusline#core#type()
  if &filetype != ''
    return &filetype
  endif

  return 'no ft'
endfunction

" File encoding
function statusline#core#encoding()
  if (&fenc!='')
    let l:encoding = &fenc
  else
    let l:encoding = &enc
  endif

  if exists("+bomb") && &bomb
    let l:encoding.= ",B"
  endif

  return l:encoding
endfunction

" Encrypted buffer
function statusline#core#crypt()
  if exists('+key') && !empty(&key)
    return g:statusline.symbols.key
  endif

  return ''
endfunction
