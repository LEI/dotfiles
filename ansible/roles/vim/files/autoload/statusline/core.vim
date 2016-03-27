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
  let l:cwd = ':s?' . getcwd() . '?.?' " pwd -> '.'
  let l:dir = ':s?/$??' " Trailing slash
  let l:name = ':t:r' " File name without extension
  let l:modifier = ':p' . l:cwd . ':~' . l:dir

  " [Command Line] ...
  let l:brackets_pattern = '\[\([^\]]\+\)\]'
  " __Gundo_Preview__ ...
  let l:underscores_pattern = '__\(\w\+\)__'
  " Title case
  " let l:title_case_pattern = '\(\<\w\+\>\)'

  " Get the current file name
  let l:str = expand('%') " :t?

  if l:str =~ l:brackets_pattern
    " Remove surrounding brackets
    " Uppercase matched string: \U\1\E
    let l:str = substitute(l:str, l:brackets_pattern, '\1', '')
  elseif l:str =~ l:underscores_pattern
    let l:str = substitute(l:str, l:underscores_pattern, '\1', '')
    let l:str = substitute(l:str, '_', ' ', 'g')
  elseif &filetype =~ 'help'
    " Display only file name in help buffers
    let l:str = fnamemodify(l:str, l:name)
  elseif strlen(l:str) == 0
    let l:str = 'No Name'
    " Try to display filetype if no name is available
    " if strlen(&ft) > 0
    "   " UPPER CASE
    "   " let l:str = toupper(&ft)
    "   " Title Case
    "   " let l:str = substitute(&ft, l:title_case_pattern, '\u\1', 'g')
    "   let l:str = &ft
    " else
    "   let l:str = '?'
    " endif
  else
    " Cwdify and tildify the current file path
    let l:str = fnamemodify(l:str, l:modifier)
  endif

  return l:str
endfunction

function statusline#core#flags()
  let l:file = expand('%')
  let l:flags = ''

  if l:file !~ 'gundo' &&
  \ &filetype !~ 'help\|netrw\|vim-plug' &&
  \ &buftype !=# 'nofile'
    let l:flags.= &modified ? "+" : &modifiable ? "" : "-"
    if &readonly
      let l:flags.= ',RO' " . get(g:statusline.symbols, 'readonly', 'RO')
    endif
  elseif &filetype =~ 'help'
    let l:flags.= 'H'
  endif

  return l:flags
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
