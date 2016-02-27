" Parts
" vim: foldenable foldmethod=marker et sts=2 sw=2 ts=2

" Register new section
function statusline#builder#add(name, opts)
  let g:statusline_parts[a:name] = get(g:statusline_parts, a:name, {})
  call extend(g:statusline_parts[a:name], a:opts, 'force')
endfunction

" Output statusline string
function statusline#builder#render()
  return s:main()
endfunction

function s:main()
  let l:l=''

  " Display colored mode
  let l:l.='%#StatusLineModeBold#'
  let l:l.='%( %{statusline#core#mode()} %)'

  let l:l.='%#StatusLineMode#'
  let l:l.='%(%{statusline#core#hasPaste()} %)'


  " Current branch
  "let l:l.='%#StatusLineBrightBold#'
  "let l:l.='%( %{statusline#extensions#fugitive()} %)'


  " Reset color to default highlight groupe 'StatusLine'
  let l:l.='%*'

  " File segment
  let l:l.='%#StatusLineFile#'
  " Break point
  let l:l.=' %<'
  " %n Buffer index
  let l:l.='%n'
  " %f Relative path
  let l:l.=' %f '

  " File flags
  " %H Help buffer
  " %R Readonly
  " %M Modified or unmodifiable
  let l:l.='%([%R%M] %)'

  " No color section
  "let l:l.='%#StatusLineNC#'

  let l:l.='%#StatusLineBG#'

  " Right align past this point
  let l:l.='%='


  " Syntastic "let l:l.='%#StatusLineWarning#'
  "let l:l.='%#warningmsg#'
  "let l:l.='%( %{statusline#extensions#syntastic()} %)'
  ""let l:l.='%*'

  let l:l.='%#StatusLineBG#'

  " Register
  let l:l.='%( %{v:register} %)'

  " File details
  let l:l.='%#StatusLineBase#'
  let l:l.=statusline#core#fileInfo()

  let l:l.='%#StatusLineBright#'
  let l:l.=statusline#core#filePos()

  let l:l.='%#StatusLineMode#'
  let l:l.=statusline#core#cursorPos()

  return l:l
endfunction

" Highlight groups
function statusline#builder#highlight(active)
  let l:m = mode()
  "redraw
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
  let l:mode_color=g:statusline_colors.dark
  let l:hi_line=g:statusline_colors.base
  let l:hi_file=g:statusline_colors.white
  let l:hi_bg=g:statusline_colors.dark "base dark?

  "if get(w:, 'statusline_active', 1)
  if get(a:, 'active', 0)
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
    "let l:mode_color='ctermfg=12'
    "let l:hi_line='ctermfg=12 ctermbg=0'
    let l:mode_color = g:statusline_colors.base
    "let l:hi_bg = g:statusline_colors.base
    let l:hi_file = g:statusline_colors.base
    let l:hi_bright=g:statusline_colors.base
  endif

  "let w:statusline_mode

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

  " Apply highlightings
  for [g,s] in l:highlights
    call statusline#utils#highlight(g, s)
  endfor
endfunction

