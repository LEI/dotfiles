" Parts
" vim: et sts=2 sw=2 ts=2

" Register new section
"function statusline#builder#add(name, opts)
"  let g:statusline_parts[a:name] = get(g:statusline_parts, a:name, {})
"  call extend(g:statusline_parts[a:name], a:opts, 'force')
"
"  echom "Builder: added " . a:name
"endfunction

" Highlight groups
function statusline#builder#highlight(winnr, group)
  let l:hi = ''

  let l:mode = get(w:, 'statusline_mode', '')
  "let l:mode = statusline#utils#getwinvar(a:winnr, 'statusline_mode', '')

  if len(l:mode) > 0 && l:mode =~ '^inactive'
    let l:hi = g:statusline_palette['inactive']
  elseif len(l:mode) > 0 && a:group ==# 'mode'
    if has_key(g:statusline_palette, split(l:mode)[0])
      let l:hi = g:statusline_palette[l:mode]
    endif
  elseif has_key(g:statusline_palette, a:group)
    let l:hi = g:statusline_palette[a:group]
  elseif len(a:group) > 0 " Must be a valid highlight group
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
      let l:hi = statusline#builder#highlight(l:p.nr, l:p.highlight)
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
