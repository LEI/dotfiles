" Builder
" set foldenable foldmethod=marker et sts=2 sw=2 ts=2

" Handle colors and mode
function statusline#build#mode()
  "redraw
  let l:m=mode()
  let l:highlights = [['FileType', 'ctermfg=12']]

  " Default highlight groups
  call add(l:highlights,['', g:statusline_colors.base])
  call add(l:highlights,['NC', g:statusline_colors.dark])
  " Custom highlight groups
  "Color,Warning?
  call add(l:highlights,['BG', g:statusline_colors.dark])
  "call add(l:highlights,['BrightBold', g:statusline_colors.bright]) " .' cterm=bold'])
  "File?
  call add(l:highlights,['Info', g:statusline_colors.bright])

  " Default status line style
  let l:hi_bright=g:statusline_colors.bright
  let l:mode_color=g:statusline_colors.white
  let l:hi_line=g:statusline_colors.base
  let l:hi_file=g:statusline_colors.white
  let l:hi_bg=g:statusline_colors.dark "base dark?

  "if get(w:,'statusline_active', 1)
  if get(w:, 'statusline_active', 1)
    if l:m ==# "n""
      let l:mode_color=g:statusline_colors.normal
    elseif l:m ==# "i"
      let l:mode_color=g:statusline_colors.insert
      let l:hi_line=g:statusline_colors.insert
      "let l:branch=g:statusline_colors.insert " 'ctermfg=2 ctermbg=11 cterm=bold'
      let l:hi_file=g:statusline_colors.insert
      let l:hi_bg=g:statusline_colors.insert
      let l:hi_bright='ctermfg=12'
    elseif l:m ==# "R"
      let l:mode_color=g:statusline_colors.replace
    elseif l:m ==# "v"
      let l:mode_color=g:statusline_colors.visual
    elseif l:m ==# "V"
      let l:mode_color=g:statusline_colors.visual
    elseif l:m ==# ""
      let l:mode_color=g:statusline_colors.visual
    endif
  else
    let l:m='__'
    "let l:mode_color='ctermfg=12'
    "let l:hi_line='ctermfg=12 ctermbg=0'
    let l:hi_bg = g:statusline_colors.base
    let l:hi_file = g:statusline_colors.base
    let l:hi_bright=g:statusline_colors.base
  endif

  "let w:statusline_mode
  let l:mode = get(g:statusline#mode_map, l:m, l:m)

  "hi StatusLine &l:base
  "hi StatusLineMode &l:mode_color

  " Set the base color
  "exec 'hi StatusLine '.l:hi_line
  "exec 'hi StatusLineBG '.l:hi_bg
  call add(l:highlights, ['Base', l:hi_line])
  call add(l:highlights, ['BG', l:hi_bg])

  " Use mode color for other parts
  "exec 'hi StatusLinePost '.l:mode_color
  " Then add bold to mode label
  "let l:mode_color.=' cterm=bold'
  "exec 'hi StatusLineMode '.l:mode_color.' cterm=bold'
  "exec 'hi StatusLineBranch '.l:branch.' cterm=bold'
  call add(l:highlights, ['Mode', l:mode_color])
  call add(l:highlights, ['ModeBold', l:mode_color.' cterm=bold'])

  call add(l:highlights, ['File', l:hi_file])
  "exec 'hi StatusLineFile '.l:hi_file
  "exec 'hi StatusLineInfo '.l:hi_bright
  call add(l:highlights, ['BrightBold', l:hi_bright]) " .' cterm=bold'])
  call add(l:highlights, ['Bright', l:hi_bright])

  for [g,s] in l:highlights
    call statusline#utils#highlight(g, s)
  endfor

  return statusline#utils#truncate(l:mode, 20)
endfunction

" Returns true if paste mode is enabled
function statusline#build#hasPaste()
    if &paste
        return g:statusline_symbols.paste
    endif
    return ''
endfunction

" File encoding and format
function statusline#build#fileInfo()
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

function statusline#build#filePos()
  " Percent through file
  let l:pos=' %3(%P%) '

  return statusline#utils#truncate(l:pos, 60)
endfunction

function statusline#build#cursorPos()
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

