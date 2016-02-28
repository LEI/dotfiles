" Parts
" vim: et sts=2 sw=2 ts=2

" Register new section
function statusline#builder#add(name, opts)
  let g:statusline_parts[a:name] = get(g:statusline_parts, a:name, {})
  call extend(g:statusline_parts[a:name], a:opts, 'force')
endfunction

function statusline#builder#wrap(string, part)
  let l:str = a:string
  let l:p = a:part

  let l:reset = '%*'
  let l:wid = ''
  let l:hi = ''
  if len(l:str) > 0
    let l:str = ' ' . l:str . ' '

    " Group width
    if exists('l:p.width')
      let l:wid = l:p.width
    endif

    " Highlight group
    if exists('l:p.highlight')
      let l:hi = '%#' . l:p.highlight . '#'
    endif
  endif

  " Wrap and highlight
  let l:str = l:hi . '%' . l:wid . '(' . l:str . '%)' . l:reset

  return l:str
endfunction

function statusline#builder#parse(key, part, index)
  let l:p = a:part
  let l:str = ''

  if exists('l:p.expr')
    " Complex expression
    let l:str = l:p.expr
  elseif exists('l:p.core') "&& l:p.core != 0
    " Core function call
    if exists('*statusline#core#{a:key}')
      let l:str = statusline#core#{a:key}()
    elseif type(l:p.core) == type('')
    "elseif exists('*statusline#core#{l:p.core)')
      " info/type,encoding,formar -> WHY not found
      let l:str = statusline#core#{l:p.core}()
    else
      echom "Core function not found: " . l:p.core . ' / ' . a:key
    endif
  elseif exists('l:p.items')
    let l:sub_part = ''

    if type(l:p.items) == type({})
      " Dictionnary crappy order
      for k in keys(l:p.items)
        echom "Ignored Dict subitem: " . k
        "let l:sub_part.= statusline#builder#part(k, l:p.items[k])
      endfor
    elseif type(l:p.items) == type([])

      if a:index > 0
        let l:index = a:index
      else
        let l:index = 0
      endif

      for k in l:p.items
        let l:key = a:key

        " if type(k) == type('')
        "   let l:key = k "l:p.item[k]
        "   let l:item.core = 1
        if type(k) == type({})
          let l:parent = deepcopy(l:p)
          call remove(l:parent, 'items')
          call extend(l:parent, k, 'force')

          let l:sub_part.= statusline#builder#parse(l:key, l:parent, l:index)

          let l:index = l:index + 1

          if l:index < len(l:p.items)
            if exists('l:p.item')
              if exists('l:p.item.sep')
                let l:sub_part.= l:p.item.sep
              endif
            endif
          endif
        elseif
          echom "Unknown item type: " . type(k)
        endif

        " Recursive part
        "echo l:item
      endfor
    else
      echom "Unkown items type: " . type(l:p.items)
    endif

    let l:str = l:sub_part
  else
    echom "Unhandled key: " . a:key
  endif

  return l:str
endfunction

function statusline#builder#part(key, part)
  let l:p = a:part
  let l:str = ''

  if a:key =~ '^%'
    " Use the key as expression
    let l:str = a:key
  elseif exists('g:statusline_parts[a:key]')
    let l:p = g:statusline_parts[a:key]
    let l:str = statusline#builder#parse(a:key, l:p, 0)
    let l:str = statusline#builder#wrap(l:str, l:p)
  else
    echo "Unknown part: " . a:key
    return ''
  endif

  return l:str
endfunction

" Output statusline string
function statusline#builder#render()
  let l:line = ''

  "call s:invoke(map(g:statusline_parts, 'v:val.function'))
  "for slug in keys(g:statusline_parts)
  "  let l:line.='%( %{' . g:statusline_parts[slug].function . '()} %)'
  "endfor

  " Main loop
  for key in g:statusline_list
    let l:line.= statusline#builder#part(key, {})
  endfor

  return l:line
endfunction

"call s:invoke(map(g:statusline_parts, 'v:val.function'))
" github.com/vim-scripts/genutils/blob/master/autoload/genutils.vim
" v:version >= 704
function s:invoke(list, ...)
  if len(a:list) != 0
    for name in keys(a:list)
      echom a:list[name]

      "let result = call(funcName, [])
      "if result != -1
      "  echom result
      "endif
    endfor
  endif
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
function statusline#builder#highlight()
  let l:m = mode()
  let l:active = get(w:, 'statusline_active', 0)

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
  if l:active
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

