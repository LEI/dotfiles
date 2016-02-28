" Parts
" vim: et sts=2 sw=2 ts=2

" Register new section
function statusline#builder#add(name, opts)
  let g:statusline_parts[a:name] = get(g:statusline_parts, a:name, {})
  call extend(g:statusline_parts[a:name], a:opts, 'force')

  echom "Builder: added " . a:name
endfunction

" Highlight groups
function statusline#builder#highlight(group)

  " if l:mode =~ '^normal'
  "   let l:color = 'User4'
  " elseif l:mode =~ '^insert'
  "   let l:color = 'User5'
  " elseif l:mode =~ '^replace'
  "   let l:color = 'User6'
  " elseif l:mode =~ '^visual'
  "   let l:color = 'User7'
  " "elseif l:mode =~ '^inactive'
  " "  let l:color = 'User8'
  " endif
  let l:hi = ''

  if a:group ==# 'mode' && len(w:statusline_mode) > 0
    let l:mode = split(get(w:, 'statusline_mode'))[0]
    if has_key(g:statusline_palette, l:mode)
      let l:hi = g:statusline_palette[l:mode]
    endif
  elseif has_key(g:statusline_palette, a:group)
    let l:hi = g:statusline_palette[a:group]
  else " Must be a valid highlight group
    let l:hi = a:group
  endif

  if len(l:hi) > 0
    let l:result = ''
    " Highlight group
    let l:result.= '%#'
    let l:result.= l:hi
    let l:result.= '#'

    let l:hi = l:result

    " Reset all styles only when a new style is applied
  endif

  return l:hi
endfunction

function statusline#builder#wrap(string, item)
  let l:str = a:string

  if len(l:str) > 0
    let l:p = a:item
    let l:reset = '%*'
    let l:wid = ''
    let l:hi = ''
    "let l:str = ' ' . l:str . ' '

    " Group width
    if exists('l:p.width')
      let l:wid = l:p.width
    endif

    " Highlight group
    if exists('l:p.highlight')
      let l:hi = statusline#builder#highlight(l:p.highlight)
      "let l:hi = '%#' . l:p.highlight . '#'
    endif

    " Wrap and highlight
    let l:str = l:hi . '%' . l:wid . '(' . l:str . '%)' " . l:reset
  endif

  return l:str
endfunction

function statusline#builder#parse(item, parent, index)
  let l:p = a:item
  call extend(l:p, a:parent, 'keep')
  let l:str = ''

  if exists('l:p.format')
    " Complex expression
    let l:str = l:p.format
  elseif exists('l:p.function')
    "let l:func = l:p.function
    "if exists('*{l:func}') "|| filereadable('l:p.function')
      " Core function call
      let l:str = {l:p.function}()
    "else
    "  echom "Function not found: " . l:p.function . ' (' . l:path . ')'
    "endif
  elseif exists('l:p.items')
    let l:sub_item = ''

    if type(l:p.items) == type({})
      " Dictionnary crappy order
      for k in keys(l:p.items)
        echom "Ignored Dict subitem: " . k
        "let l:sub_item.= statusline#builder#part(k, l:p.items[k])
      endfor
    elseif type(l:p.items) == type([])

      if a:index > 0
        let l:index = a:index
      else
        let l:index = 0
      endif

      for k in l:p.items

        " if type(k) == type('')
        "   let l:item = k "l:p.item[k]
        "   let l:item.core = 1
        if type(k) == type({})
          let l:parent = deepcopy(l:p)
          call remove(l:parent, 'items')
          "call extend(l:parent, k, 'force')

          let l:sub_str = statusline#builder#parse(k, l:parent, l:index)
          let l:sub_item.= statusline#builder#wrap(l:sub_str, k)

          let l:index = l:index + 1

          if l:index < len(l:p.items)
            if exists('l:p.sep')
              let l:sub_item.= l:p.sep
            endif
          endif
        elseif
          echom "Unknown item type: " . type(k)
        endif
      endfor
    else
      echom "Unkown items type: " . type(l:p.items)
    endif

    let l:str = l:sub_item
  else
    echom "Unhandled key: " . type(a:item)
  endif

  return l:str
endfunction

function statusline#builder#part(item, parent)
  let l:p = a:parent
  let l:str = ''

  if type(a:item) == type('') && a:item =~ '^%'
    " Use the key as expression
    let l:str = a:item
  elseif type(a:item) == type({}) "exists('g:statusline_parts[a:item]')
    "let l:p = g:statusline_parts[a:item]
    if !exists('a:item.truncate') || statusline#utils#minwidth(a:item.truncate)
      let l:str = statusline#builder#parse(a:item, l:p, 0)
      let l:str = statusline#builder#wrap(l:str, a:item)
    endif
  else
    echo "Unknown part: " . a:item
    return ''
  endif

  return l:str
endfunction

" ----------------------------------------------------------------------------

"" Output statusline string
"function statusline#builder#render()
"  let l:line = ''
"
"  "call s:invoke(map(g:statusline_parts, 'v:val.function'))
"  "for slug in keys(g:statusline_parts)
"  "  let l:line.='%( %{' . g:statusline_parts[slug].function . '()} %)'
"  "endfor
"
"  " Main loop
"  for key in g:statusline_list
"    let l:line.= statusline#builder#part(key, {})
"  endfor
"
"  return l:line
"endfunction

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


" function s:main()
"   let l:l=''
"
"   " Display colored mode
"   let l:l.='%#StatusLineModeBold#'
"   let l:l.='%( %{statusline#core#mode()} %)'
"
"   let l:l.='%#StatusLineMode#'
"   let l:l.='%(%{statusline#core#hasPaste()} %)'
"
"
"   " Current branch
"   "let l:l.='%#StatusLineBrightBold#'
"   "let l:l.='%( %{statusline#extensions#fugitive()} %)'
"
"
"   " Reset color to default highlight groupe 'StatusLine'
"   let l:l.='%*'
"
"   " File segment
"   let l:l.='%#StatusLineFile#'
"   " Break point
"   let l:l.=' %<'
"   " %n Buffer index
"   let l:l.='%n'
"   " %f Relative path
"   let l:l.=' %f '
"
"   " File flags
"   " %H Help buffer
"   " %R Readonly
"   " %M Modified or unmodifiable
"   let l:l.='%([%R%M] %)'
"
"   " No color section
"   "let l:l.='%#StatusLineNC#'
"
"   let l:l.='%#StatusLineBG#'
"
"   " Right align past this point
"   let l:l.='%='
"
"
"   " Syntastic "let l:l.='%#StatusLineWarning#'
"   "let l:l.='%#warningmsg#'
"   "let l:l.='%( %{statusline#extensions#syntastic()} %)'
"   ""let l:l.='%*'
"
"   let l:l.='%#StatusLineBG#'
"
"   " Register
"   let l:l.='%( %{v:register} %)'
"
"   " File details
"   let l:l.='%#StatusLineBase#'
"   let l:l.=statusline#core#fileInfo()
"
"   let l:l.='%#StatusLineBright#'
"   let l:l.=statusline#core#filePos()
"
"   let l:l.='%#StatusLineMode#'
"   let l:l.=statusline#core#cursorPos()
"
"   return l:l
" endfunction
