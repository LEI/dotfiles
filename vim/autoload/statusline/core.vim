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
  let l:modifier = ':p:~' " :.
  " :s?pat?sub?

  let l:str = expand('%') " :t?
  "'string': '%{expand("%")==""?"NO NAME":expand("%")=="[Command Line]"?"COMMAND LINE":expand("%:r")} ',

  if l:str =~ '\[[^\]]\+\]'
    " Remove surrounding brackets and uppercase matched string
    let l:str = substitute(l:str, '\[\([^\]]\+\)\]', '\U\1\E', 'g')
  elseif &filetype =~ 'help'
    let l:str = expand('%:t') . ' [HELP]'
  elseif strlen(l:str) == 0
    let l:str = strlen(&ft) > 0 ? toupper(&ft) : 'NO NAME'
  else
    let l:str = fnamemodify(l:str, l:modifier)
  endif

  "if strlen(l:str) == 0
  "  let l:str = './'
  "endif

  return l:str
endfunction

function statusline#core#netrw()
  let l:order = (g:netrw_sort_direction =~ 'n') ? '+' : '-'
  return g:netrw_sort_by . l:order
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
