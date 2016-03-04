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
  if len(l:mode) > 0
    let l:mode = split(l:mode)[0]
  endif

  if l:mode ==# 'inactive'
    " Override colors when inactive
    let l:highlight = g:statusline_palette[l:mode]
  elseif l:highlight ==# 'mode' && has_key(g:statusline_palette, l:mode)
    " Mode interactive highlighting
    let l:highlight = g:statusline_palette[l:mode]
  elseif has_key(g:statusline_palette, l:highlight)
    " Group highlighting
    let l:highlight = g:statusline_palette[l:highlight]
  "else
  "  let l:highlight = l:highlight
  endif

  " Build the highlight string
  let l:str = statusline#utils#highlight(l:str, l:highlight)
  "let l:reset = '%*'

  return l:str
endfunction

function s:parse(item, parent, index)
  let l:item = a:item
  let l:str = ''

  " Display only if not truncated
  if exists('l:item.truncate') && statusline#utils#truncate(l:item.truncate)
    return l:str
  endif

  call extend(l:item, a:parent, 'keep')

  if exists('l:item.string')
    " Custom expression
    let l:str = l:item.string
  elseif exists('l:item.function')
    " Function call (unused?)
    "exists('*{l:item.function}') "|| filereadable('l:item.function')
    try
      let l:str = {l:item.function}()
    catch
      echom "Function not found: " . l:item.function
    endtry
  elseif exists('l:item.list')
    let l:sub_item = ''

    "if type(l:item.list) == type({})
    "  for k in keys(l:item.list)
    "    echom "Dict subitem: " . k
    "  endfor
    if type(l:item.list) == type([])

      if a:index > 0
        let l:index = a:index
      else
        let l:index = 0
      endif

      for k in l:item.list
        if type(k) == type('')
          let l:sub_item.= k
        elseif type(k) == type({})
          let l:parent = deepcopy(l:item)
          call remove(l:parent, 'list')
          call remove(l:parent, 'highlight')
          "call extend(l:parent, k, 'force')

          let l:sub_item.= s:parse(k, l:parent, l:index)
          "let l:sub_item.= s:wrap(l:sub_string, k)

          let l:index = l:index + 1
          if l:index < len(l:item.list)
            if exists('l:item.sep')
              let l:sub_item.= l:item.sep
            endif
          endif
        else
          echom "Unknown item type: " . type(k)
        endif
        unlet k
      endfor
    else
      echom "Unkown item type: " . type(l:item.list)
    endif

    let l:str = l:sub_item
  else
    echom "Unhandled key: " . type(l:item)
  endif

  " Wrap string
  if strlen(l:str) > 0
    " Display condition
    if exists('l:item.condition')
      "let l:str = s:condition(l:str, l:item)
      let l:str = substitute(l:str, '{', '\="{".(l:item.condition)."?"', '')
      let l:str = substitute(l:str, '}', ':""}', '')
    endif
    " Highlight group
    if exists('l:item.highlight')
      let l:str = s:highlight(l:str, l:item)
    endif
  endif

  " Width specification
  if exists('l:item.width')
    let l:width = l:item.width
  else
    let l:width = ''
  endif

  " Section wrap
  let l:str = statusline#utils#construct(l:str, l:width)

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
