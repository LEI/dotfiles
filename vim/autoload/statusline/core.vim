" Core sections
" set foldenable foldmethod=marker et sts=2 sw=2 ts=2

function statusline#core#load()
  call statusline#builder#add('mode', { 'function': 'statusline#core#mode' })
endfunction

" Display mode name
function statusline#core#mode()
  let l:m = mode()
  let l:active = get(w:, 'statusline_active', 0)

  if !l:active
    let l:m='__'
  endif

  let l:mode = get(g:statusline_modes, l:m, l:m)

  " This needs to be called when the statusline is rendered
  call statusline#builder#highlight(l:active)

  return statusline#utils#truncate(l:mode, 20)
endfunction

" Returns true if paste mode is enabled
function statusline#core#hasPaste()
    if &paste
        return g:statusline_symbols.paste
    endif
    return ''
endfunction

" File encoding and format
function statusline#core#fileInfo()
  let l:info=''
  " File type %(y|Y)
  "let l:l.='%#StatusLineType#'
  "let l:l.='%( %{&filetype} %)'

  " File encoding and format
  "let l:l.='%#StatusLineInfo#'

  let l:info.=' '

  if (&filetype!='')
    let l:type=&filetype
  else
    let l:type='no ft'
  endif

  let l:info.=l:type

  let l:info.=' '
  "let l:info.=g:statusline_symbols.sep
  let l:info.=' '

  if (&fenc!='')
    let l:encoding=&fenc
  else
    let l:encoding=&enc
  endif
  if (exists("+bomb") && &bomb)
    let l:encoding.=",B"
  endif

  let l:info.=l:encoding

  let l:info.=' '
  "let l:info.=g:statusline_symbols.sep
  let l:info.=' '

  let l:info.=&fileformat
  let l:info.=' '

  return statusline#utils#truncate(l:info, 80)
endfunction

function statusline#core#filePos()
  " Percent through file
  let l:pos=' %3(%P%) '

  return statusline#utils#truncate(l:pos, 60)
endfunction

function statusline#core#cursorPos()
  " Cursor position
  let l:pos=''

  let l:pos.=' '

  " %l Line number
  " $c Column number
  " %V Virtual column
  let l:pos.='%4(%l:%)%-3(%c%V%)'

  "let l:pos.=' '
  " %P Percent through file
  "let l:pos.='%4(%p%%%)'

  let l:pos.=' '

  return statusline#utils#truncate(l:pos, 40)
endfunction

