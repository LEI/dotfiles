" Parts
" vim: et sts=2 sw=2 ts=2

" TODO:
" Highlight(string, item) /// wrap?
" Recursive items: copy() or deepcopy()?

" Apply highlight group
function s:highlight(string, item)
  let l:str = a:string
  let l:item = a:item
  let l:highlight = l:item.highlight

  let l:mode = get(w:, 'statusline_mode', '')

  " Gets the first part of the mode string
  "if len(l:mode) > 0
  "  let l:mode = split(l:mode)[0]
  "endif

  if type(l:highlight) == type(0)
    let l:highlight = 'StatusLine' . l:mode . l:highlight
  endif

  "if l:mode ==# 'inactive' && l:highlight !=# 'bg'
  "  " Override colors when inactive, unless bg color is already used
  "  let l:highlight = g:statusline.colors[l:mode]
  "elseif l:highlight ==# 'mode' && has_key(g:statusline.colors, l:mode)
  "  " Mode interactive highlighting
  "  let l:highlight = g:statusline.colors[l:mode]
  "elseif has_key(g:statusline.colors, l:highlight)
  "  " Group highlighting
  "  let l:highlight = g:statusline.colors[l:highlight]
  ""else
  ""  let l:highlight = l:highlight
  "endif

  " echom l:mode . ' # ' . l:highlight

  " Build the highlight string
  let l:str = statusline#utils#highlight(l:str, l:highlight)
  "let l:reset = '%*'

  return l:str
endfunction

function s:parse(item, parent, ...)
  let l:item = a:item
  let l:str = ''
  " Truncate if the window is too small
  if exists('l:item.truncate') && statusline#utils#truncate(l:item.truncate)
    return l:str
  endif

  " Inherit properties
  call extend(l:item, a:parent, 'keep')

  if exists('l:item.string')
    " Custom expression
    let l:str = l:item.string
  elseif exists('l:item.function')
    let l:str = l:item.function()
    "exists('*{l:item.function}') "|| filereadable('l:item.function')
    " try
    "   let l:str = {l:item.function}()
    " catch
    "   echom "Function not found: " . l:item.function
    " endtry
  elseif exists('l:item.list')
    let l:str = ''
    "if type(l:item.list) == type({})
    "  for k in keys(l:item.list)
    "    echom "Dict subitem: " . k
    "  endfor
    if type(l:item.list) == type([]) && len(l:item.list) > 0
      " Recursive items
      "if a:index > 0
      "  let l:index = a:index
      "else
      "  let l:index = 0
      "endif

      let l:index = 0
      for k in l:item.list
        let l:sub_item = ''
        if type(k) == type('')
          " Use string as is
          let l:sub_item.= k
        elseif type(k) == type({})
          " Object sub item
          let l:parent = deepcopy(l:item)
          call remove(l:parent, 'list')
          call remove(l:parent, 'highlight')
          "call extend(l:parent, k, 'force')
          " Self function call
          let l:sub_item.= s:parse(k, l:parent)
          "let l:sub_item.= s:wrap(l:sub_string, k)
        else
          echom "Unknown item type: " . type(k)
        endif

        let l:index = l:index + 1
        " strlen(l:sub_item)?
        if l:index > 1 && l:index <= len(l:item.list) && exists('l:item.separator')
          let l:sub_item = '%(' . l:item.separator . l:sub_item . '%)'
        endif

        " Final loop result
        let l:str.= l:sub_item

        unlet k
      endfor
    else
      echom "Unkown item list type: " . type(l:item.list)
    endif
  else
    echom "Unhandled key (looking for string, function or type)"
    "echo type(l:item)
  endif

  " Wrap string
  if strlen(l:str) > 0
    " Display condition
    if exists('l:item.condition')
      "let l:str = s:condition(l:str, l:item)
      let l:str = substitute(l:str, '{', '\="{".(l:item.condition)."?"', '')
      let l:str = substitute(l:str, '}', ':""}', '')
    endif

    " Width specification
    if exists('l:item.width')
      let l:width = l:item.width
    else
      let l:width = ''
    endif
    let l:str = statusline#utils#construct(l:str, l:width)

    " Highlight group
    if exists('l:item.highlight')
      let l:str = s:highlight(l:str, l:item)
    endif
  endif

  return l:str
endfunction

function statusline#builder#add(item, parent)
  let l:item = a:item
  let l:parent = a:parent
  let l:str = ''

  if type(l:item) == type('')
    " Treat as expression
    " && l:item =~ '^%'
    let l:str = l:item
  elseif type(l:item) == type({}) "exists('g:statusline_parts[l:item]')
    let l:str = s:parse(l:item, l:parent, 0)
  else
    echom "Unhandled section type: " . type(l:item)
    return ''
  endif

  return l:str
endfunction

" Register new section
"function statusline#builder#add(name, opts)
"  let g:statusline_parts[a:name] = get(g:statusline_parts, a:name, {})
"  call extend(g:statusline_parts[a:name], a:opts, 'force')
"
"  echom "Builder: added " . a:name
"endfunction
