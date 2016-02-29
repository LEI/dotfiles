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
function statusline#builder#highlight(item)
  let l:item = a:item
  let l:hi = l:item.highlight

  let l:mode = get(w:, 'statusline_mode', '')
  " Gets the first part of the mode string
  if len(l:mode) > 0
    let l:mode = split(l:mode)[0]
  endif

  if l:mode ==# 'inactive'
    " Override colors when inactive
    let l:hi = g:statusline_palette[l:mode]
  elseif l:hi ==# 'mode' && has_key(g:statusline_palette, l:mode)
    " Mode highlighting using theme palette
    let l:hi = g:statusline_palette[l:mode]
  elseif has_key(g:statusline_palette, l:hi)
    " Group highlighting using theme palette
    let l:hi = g:statusline_palette[l:hi]
  endif

  " Uses the highlight property as a highlight group if nothing else matches
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
    let l:item = a:item
    let l:reset = '%*'
    let l:wid = ''
    let l:hi = ''
    "let l:str = ' ' . l:str . ' '

    " Group width
    if exists('l:item.width')
      let l:wid = l:item.width
    endif

    " Highlight group
    if exists('l:item.highlight')
      let l:hi = statusline#builder#highlight(l:item)
      "let l:hi = '%#' . l:item.highlight . '#'
    endif

    " Wrap and highlight
    let l:str = l:hi . '%' . l:wid . '(' . l:str . '%)' " . l:reset
  endif

  return l:str
endfunction

function statusline#builder#parse(item, parent, index)
  let l:item = a:item
  call extend(l:item, a:parent, 'keep')
  let l:str = ''

  if exists('l:item.format')
    " Complex expression
    let l:str = l:item.format
  elseif exists('l:item.function')
    "let l:func = l:item.function
    "if exists('*{l:func}') "|| filereadable('l:item.function')
      " Core function call
      let l:str = {l:item.function}()
    "else
    "  echom "Function not found: " . l:item.function . ' (' . l:itemath . ')'
    "endif
  elseif exists('l:item.items')
    let l:sub_item = ''

    if type(l:item.items) == type({})
      " Dictionnary crappy order
      for k in keys(l:item.items)
        echom "Ignored Dict subitem: " . k
        "let l:sub_item.= statusline#builder#part(k, l:item.items[k])
      endfor
    elseif type(l:item.items) == type([])

      if a:index > 0
        let l:index = a:index
      else
        let l:index = 0
      endif

      for k in l:item.items

        " if type(k) == type('')
        "   let l:item = k "l:item.item[k]
        "   let l:item.core = 1
        if type(k) == type({})
          let l:parent = deepcopy(l:item)
          call remove(l:parent, 'items')
          "call extend(l:parent, k, 'force')

          let l:sub_str = statusline#builder#parse(k, l:parent, l:index)
          let l:sub_item.= statusline#builder#wrap(l:sub_str, k)

          let l:index = l:index + 1

          if l:index < len(l:item.items)
            if exists('l:item.sep')
              let l:sub_item.= l:item.sep
            endif
          endif
        else
          echom "Unknown item type: " . type(k)
        endif
      endfor
    else
      echom "Unkown items type: " . type(l:item.items)
    endif

    let l:str = l:sub_item
  else
    echom "Unhandled key: " . type(l:item)
  endif

  return l:str
endfunction

function statusline#builder#part(item, parent)
  let l:item = a:item
  let l:p = a:parent
  let l:str = ''

  if type(l:item) == type('') && l:item =~ '^%'
    " Use the key as expression
    let l:str = l:item
  elseif type(l:item) == type({}) "exists('g:statusline_parts[l:item]')
    "let l:p = g:statusline_parts[l:item]
    if !exists('l:item.truncate') || statusline#utils#minwidth(l:item.truncate)
      let l:str = statusline#builder#parse(l:item, l:p, 0)
      let l:str = statusline#builder#wrap(l:str, l:item)
    endif
  else
    echo "Unknown part: " . l:item
    return ''
  endif

  return l:str
endfunction
