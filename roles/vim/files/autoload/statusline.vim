" Vim statusline utils

function! statusline#parse(item) abort
  if type(a:item) == type(0) && a:item == 0
    " False
    return ''
  elseif type(a:item) == type('') && strlen(a:item) > 0
    " String
    return a:item
  elseif type(a:item) == type(function('tr'))
    " Function reference
    return '%{' . string(a:item) . '()}'
  else
    echoerr 'Unkown type: ' . a:item
    return a:item
  endif
endfunction

function! statusline#truncate(string, ...) abort
  let str = a:string
  let minwidth = a:0 ? a:1 : 0

  if minwidth > 0
    if str =~ '^%{'
      let condition = 'winwidth(0) >= ' . minwidth
      let str = substitute(str, '{', '\="{" . condition . " ? "', 'g')
      let str = substitute(str, '}', ' : ""}', 'g')
    " else
    "   echoerr 'Component should start with "%{", got: ' . str
    endif
  endif

  return str
endfunction

function! statusline#surround(string, ...) abort
  let str = a:string
  let surround = a:0 ? a:1 : ''

  if empty(surround)
    return str
  elseif type(surround) == type([]) && len(surround) == 2
    let str = surround[0] . str . surround[1]
  elseif strlen(surround) > 0
    let match = {'[': ']', '{': '}', '(': ')', '<': '>', ',': ''}
    let str = surround . str . get(match, surround, surround)
  endif

  return str
endfunction

function! statusline#symbol(dict, key) abort
  let s = get(a:dict, a:key, '')

  if has_key(g:statusline.states, s)
    let s = get(g:statusline.states, s, s)
  else
    let s = get(g:statusline.symbols, s, s)
  endif

  return s
endfunction

function! statusline#wrap(string, ...) abort
  let wrap = a:0 ? a:1 : 0

  if wrap > 0
    " TODO width, align (%-35.)
    let str = '%(' . a:string . '%)'
  else
    let str = a:string
  endif

  return str
endfunction

function! statusline#highlight(string, ...) abort
  let group = a:0 ? a:1 : ''

  if strlen(group) > 0
    let str = '%#' . group . '#' . a:string . '%*'
  else
    let str = a:string
  endif

  return str
endfunction

function! statusline#build()
  " setglobal statusline=%!statusline.build()
  " let &g:statusline = g:statusline.build()

  " Overrides
  if exists('g:loaded_gundo')
    let g:gundo_tree_statusline = g:statusline.build(g:statusline.states.gundo)
    let g:gundo_preview_statusline = g:statusline.build(g:statusline.states.gundo)
  endif

  return g:statusline.build()
endfunction
