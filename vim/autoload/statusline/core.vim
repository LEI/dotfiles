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
  " File name modifiers:
  "   % Replaced by the current file name
  "   :p Expand to the full path of the file
  "   :~ Reduce file name to be relative to the home directory
  "   :. Reduce file name to be relative to current directory
  "   :s(|gs)?pat?sub? Substitute first(|all) occurence(s) of pat with sub
  let l:cwd = ':s?' . getcwd() . '?.?'
  let l:dir = ':s?/$??'
  let l:name = ':t:r'

  let l:brackets_pattern = '\[\([^\]]\+\)\]'
  let l:modifier = ':p' . l:cwd . l:dir . ':~'

  let l:str = expand('%') " :t?
  "'string': '%{expand("%")==""?"NO NAME":expand("%")=="[Command Line]"?"COMMAND LINE":expand("%:r")} ',

  if l:str =~ l:brackets_pattern
    " Remove surrounding brackets and uppercase matched string
    let l:str = substitute(l:str, l:brackets_pattern, '\U\1\E', 'g')
  elseif &filetype =~ 'help'
    " Display only file name in help buffers
    let l:str = fnamemodify(l:str, l:name) . ' [H]'
  elseif strlen(l:str) == 0
    " Try to display uppercase file type if no name is available
    let l:str = strlen(&ft) > 0 ? toupper(&ft) : 'NO NAME'
  else
    " Cwdify and tildify the current file path
    let l:str = fnamemodify(l:str, l:modifier)
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
