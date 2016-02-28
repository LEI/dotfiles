" Statusline
" vim: et sts=2 sw=2 ts=2

" github.com/vim-airline/vim-airline

" Cheat sheet {{{1

" base16 colors (?)
" 0: black
" 1: red
" 2: green
" 3: yellow
" 4: blue
" 5: magenta
" 6: bright green (cyan)
" 7: white
" 8: bright black
" 9: bright red
" 10: deep gray (bright green)
" 11: gray (bright yellow)
" 12: light gray (bright blue)
" 13: white (bright magenta)
" 14: beige (bright cyan)
" 15: bright white

" Default statusline: %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
" Format markers:
"   %< truncation point
"   %n buffer number
"   %f relative path to file
"   %m modified flag [+] (modified), [-] (unmodifiable) or nothing
"   %r readonly flag [RO]
"   %y filetype [ruby]
"   %= split point for left and right justification
"   %-35. width specification
"   %l current line number
"   %L number of lines in buffer
"   %c current column number
"   %V current virtual column number (-n), if different from %c
"   %P percentage through buffer
"   %) end of width specification
"set statusline=%<\ %n:%f\ %m%r%y%=%-35.(line:\ %l\ of\ %L,\ col:\ %c%V\ (%P)%)

" Declarations {{{1

call statusline#utils#define('g:statusline', {})
call statusline#utils#define('g:statusline_theme', 'dark')
call statusline#utils#define('g:statusline_template', 'base')

" Templates {{{2

call statusline#utils#define('g:statusline_tpl_minimal', [])
call extend(g:statusline_tpl_minimal, [
  \   {
  \     'highlight': 'mode',
  \     'format': ' %{statusline#core#mode()()} ',
  \     'width': '-9',
  \     'truncate': 33,
  \   },
  \   '%<%f%( [%M%R]%)',
  \   '%=',
  \   '%( [%{&filetype}]%) ',
  \   '%-8.(%l,%c%V%) %p%% ',
  \ ], 'keep')

call statusline#utils#define('g:statusline_tpl_base', [])
call extend(g:statusline_tpl_base, [
  \   {
  \     'highlight': 'mode',
  \     'format': ' %{statusline#core#mode()} ',
  \     'width': '-8',
  \     'truncate': 20,
  \   },
  \   {
  \     'format': '%{statusline#core#paste()} ',
  \   },
  \   {
  \     'highlight': 'StatusLine',
  \     'format': ' %{statusline#extensions#fugitive#branch()} ',
  \     'truncate': 60,
  \   },
  \   {
  \     'highlight': 'StatusLineFile',
  \     'format': ' %<%n %f %([%M%R] %)'
  \   },
  \   '%=',
  \   {
  \     'highlight': 'StatusLineBG',
  \     'format': '%( %{v:register} %)',
  \   },
  \   {
  \     'highlight': 'StatusLineBase',
  \     'truncate': 80,
  \     'sep': '|',
  \     'items': [
  \       { 'format': ' %{statusline#core#format()} ' },
  \       { 'format': ' %{statusline#core#encoding()} ' },
  \       { 'format': ' %{statusline#core#type()} ' },
  \     ],
  \   },
  \   {
  \     'highlight': 'StatusLine',
  \     'format': ' %P ',
  \     'width': '5',
  \     'truncate': 60,
  \   },
  \   {
  \     'highlight': 'mode',
  \     'truncate': 40,
  \     'sep': ':',
  \     'items': [
  \       { 'format': ' %l', 'width': '4' },
  \       { 'format': '%c%V ', 'width': '-4' },
  \     ],
  \   },
  \   {
  \     'highlight': 'WarningMsg',
  \     'format': '%{statusline#extensions#syntastic#flags()}',
  \     'truncate': 60,
  \   },
  \ ], 'keep')

call statusline#utils#define('g:statusline_mode_map', {})
call extend(g:statusline_mode_map, {
  \ 'inactive' : '------',
  \ 'n': 'NORMAL',
  \ 'i': 'INSERT',
  \ 'R': 'REPLACE',
  \ 'v': 'VISUAL',
  \ 'V': 'V-LINE',
  \ 'c': 'COMMAND',
  \ '': 'V-BLOCK',
  \ 's': 'SELECT',
  \ 'S': 'S-LINE',
  \ '': 'S-BLOCK',
  \ 't': 'TERMINAL',
  \ }, 'keep')

" Symbols {{{2

" ⎇ /|•·
call statusline#utils#define('g:statusline_symbols', {})
call extend(g:statusline_symbols, {
  \ 'paste': 'PASTE',
  \ 'readonly': get(g:, 'powerline_fonts', 0) ? "\ue0a2" : 'RO',
  \ 'whitespace': get(g:, 'powerline_fonts', 0) ? "\u2739" : '!',
  \ 'linenr': get(g:, 'powerline_fonts', 0) ? "\ue0a1" : ':',
  \ 'branch': get(g:, 'powerline_fonts', 0) ? "\ue0a0" : '⎇ ',
  \ 'crypt': get(g:, 'crypt_symbol', nr2char(0x1F512)),
  \ 'modified': '+',
  \ 'close': '✕',
  \ 'sep': '|',
  \ }, 'keep')

" Main {{{1

" github.com/vim-airline/vim-airline/blob/master/autoload/airline/themes.vim
function statusline#theme(theme)
  " Load theme (statusline#themes#{name}#colors -> g:statusline_color)
  "let g:statusline_colors = g:statusline#themes#{a:theme}#colors

  let g:statusline_palette = g:statusline#themes#{a:theme}#palette

endfunction
call statusline#theme(g:statusline_theme)

let s:wins = {}

" TODO: highlight
" function statusline#active(...)
"   "let l:a = get(w:, 'statusline_active', 0)
"   let l:active = a:0 > 0 ? a:1 : 'nope'
"   return l:active
" endfunction

function statusline#update()
  for nr in filter(range(1, winnr('$')), 'v:val != winnr()')
  "for nr in range(1, winnr('$'))
    call statusline#win(nr, 0)
  endfor

  call statusline#win(winnr(), 1)
  "statusline#utils#getwinvar(l:winnr, 'statusline_active', 0)
endfunction

function statusline#win(nr, active)
  let l:win = { 'nr': a:nr, 'active': a:active, 'bufnr': winbufnr(a:nr) }
  let s:wins[a:nr] = l:win
  "setlocal statusline=%!statusline#set(winnr())
  let &l:statusline = '%!statusline#build(' . l:win.nr . ')'
  "call setwinvar(l:win.nr, '&statusline', '%!statusline#set(' . l:win.nr . ')')
endfunction

function statusline#build(winnr)
  let l:win = s:wins[a:winnr]
  let l:m = mode()

  if l:win.active
    if l:m ==# 'n'
      let l:mode = ['normal']
    elseif l:m ==# 'i'
      let l:mode = ['insert']
    elseif l:m ==# 'R'
      let l:mode = ['replace']
    elseif l:m =~# '\v(v|V||s|S|)'
      let l:mode = ['visual']
    elseif l:m ==# 't'
      let l:mode = ['terminal']
    else
      let l:mode = [l:m]
    endif
  else
    let l:mode = ['inactive']
  endif

  let l:mode_string = join(l:mode)

  if get(w:, 'statusline_mode', '') != l:mode_string || !exists('l:win.line')
    call setwinvar(l:win.nr, 'statusline_mode', l:mode_string)

    let l:line = ''
    "call statusline#highlight(l:mode_string)
    let w:statusline_mode = l:mode_string
    "let l:line.= l:mode_string

    let l:items = g:statusline_tpl_{g:statusline_template}
    for item in l:items
      let l:line.= statusline#builder#part(item, l:win)
      unlet item
    endfor

    let l:win.line = l:line
    "let s:wins[a:winnr] = l:win
  "else
    "let l:line = l:win.line
  endif

  "echom l:win.line

  return l:win.line
endfunction

function statusline#hi(mode)
  let l:mode = a:mode "get(w:, 'statusline_lastmode', '')
  "let l:active = get(w:, 'statusline_active', 1)
  "let l:active = statusline#utils#getwinvar(a:winnr, 'statusline_active', 0)
  "echom "winnr" . winnr() . " active?" . a:active

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
  if l:mode ==# 'normal'
    let l:mode_color=g:statusline_colors.normal
  elseif l:mode ==# 'insert'
    let l:mode_color=g:statusline_colors.insert
    let l:hi_line=g:statusline_colors.insert
    "let l:branch=g:statusline_colors.insert " 'ctermfg=2 ctermbg=11 cterm=bold'
    let l:hi_file=g:statusline_colors.insert
    let l:hi_bg=g:statusline_colors.insert
    let l:hi_bright='ctermfg=12'
  elseif l:mode ==# 'replace'
    let l:mode_color=g:statusline_colors.replace
  elseif l:mode ==# 'visual'
    let l:mode_color=g:statusline_colors.visual
  elseif l:mode ==# 'inactive'
    "let l:mode_color='ctermfg=12'
    "let l:hi_line='ctermfg=12 ctermbg=0'
    let l:mode_color = g:statusline_colors.base
    "let l:hi_bg = g:statusline_colors.base
    let l:hi_file = g:statusline_colors.base
    let l:hi_bright=g:statusline_colors.base
  else
    let l:mode_color = 'ctermfg=red'
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
    "call statusline#utils#highlight(g, s)
    exec 'hi StatusLine'.g.' '.s
  endfor
endfunction

