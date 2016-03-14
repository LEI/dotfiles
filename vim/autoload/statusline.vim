" Statusline
" vim: et sts=2 sw=2 ts=2

" github.com/vim-airline/vim-airline

" Declarations
call statusline#utils#define('g:statusline', {})
call extend(g:statusline, {
\  'colorscheme': 'base16',
\  'template': 'flatline',
\  'symbols': {},
\  'mode_map': {},
\}, 'keep')

" Symbols
"  'branch_alt': get(g:, 'powerline_fonts', 0) ? '\ue0a0' : nr2char(0x2523) . nr2char(0x251B),
" Full width tilde FF5E
" Github branch octicon f020
call extend(g:statusline.symbols, {
\  'paste': 'PASTE',
\  'whitespace': get(g:, 'powerline_fonts', 0) ? '\u2739' : '!',
\  'linenr': get(g:, 'powerline_fonts', 0) ? '\ue0a1' : ':',
\  'branch': get(g:, 'powerline_fonts', 0) ? '\ue0a0' : nr2char(0x2387). ' ',
\  'readonly': get(g:, 'powerline_fonts', 0) ? '\ue0a2' : nr2char(0x1F512) . ' ',
\  'key': get(g:, 'crypt_symbol', nr2char(0x1F511) . ' '),
\  'modified': '+',
\  'close': nr2char(0x2715),
\  'separator': nr2char(0x2502),
\}, 'keep')

call extend(g:statusline.mode_map, {
\  '__' : '------',
\  'n': 'NORMAL',
\  'i': 'INSERT',
\  'R': 'REPLACE',
\  'v': 'VISUAL',
\  'V': 'V-LINE',
\  'c': 'COMMAND',
\  '': 'V-BLOCK',
\  's': 'SELECT',
\  'S': 'S-LINE',
\  '': 'S-BLOCK',
\}, 'keep')
"'t': 'TERMINAL',

" Mode Map:
"   n       Normal
"   no      Operator-pending
"   v       Visual by character
"   V       Visual by line
"   CTRL-V  Visual blockwise
"   s       Select by character
"   S       Select by line
"   CTRL-S  Select blockwise
"   i       Insert
"   R       Replace |R|
"   Rv      Virtual Replace |gR|
"   c       Command-line
"   cv      Vim Ex mode |gQ|
"   ce      Normal Ex mode |Q|
"   r       Hit-enter prompt
"   rm      The -- more -- prompt
"   r?      A confirm query of some sort
"   !       Shell or external command is executing

" Default Status Line: %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
" Format Markers:
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
" Description:
"   A template is an array describing each part of the status line
"   Each template item can be an string or a dictionary
"   Each item should have one and only one of the following:
" Properties:
"   format *string* expression       'string'
"   *function* reference             function('fn')
"   items *list* nested items array  ['item', {}]
" Optional:
"   *highlight* group                User<int> or <string>
"   *width* specification            %-0{minwid}.{maxwid}{item}
"   *truncate* minimum column number
"   *condition* for displaying the item
" Example:
"   let s:palette = [
"   \  {
"   \    'string': ' %{statusline#core#mode()} ',
"   \    'highlight': 'mode',
"   \    'width': '-9',
"   \    'truncate': 33,
"   \  },
"   \  '%<%f%( [%M%R]%)',
"   \  '%=',
"   \  '%( [%{&filetype}]%) ',
"   \  '%-8.(%l,%c%V%) %p%% ',
"   \]
"   function statusline#templates#<name>#load()
"     return s:palette
"   endfunction

let s:wins = {}

" function statusline#set()
"   if !exists('s:wins[winnr()]') "!exists('w:statusline') || w:statusline
"     call statusline#update()
"   endif
" endfunction

" function statusline#unset()
"   unlet w:statusline_overwrite
" endfunction

" Updates the status line in the current window
function statusline#update(...)
  " Init
  if !exists('g:statusline.tpl')
    call statusline#template()
  endif
  if !exists('g:statusline.color')
    call statusline#colorscheme()
  endif

  let l:winnr = a:0 > 0 ? a:1 : winnr()
  let g:statusline.debug = 1

  "for winnr in filter(range(1, winnr('$')), 'v:val != winnr()')
  "echom l:winnr . ' ------------- '
  for nr in range(1, winnr('$'))
    "let l:active = get(w:, 'statusline_active', nr != l:winnr ) ? w:statusline_active : 1
    let l:active = nr == l:winnr
    "if a:0>0 | echom l:winnr . ' == ' . a:1nr . ' | ' . (l:active ? 'active' : '') | endif

    " Update local status line
    let l:win = { 'winnr': nr, 'active': l:active, 'bufnr': winbufnr(nr) }
    " if a:0 > 2 && strlen(a:3) > 0
    "   let l:win.mode = a:3
    " endif

    let s:wins[nr] = l:win
    if nr != l:winnr
      let l:win.mode = 'inactive'
      "call setwinvar(n, 'statusline_mode', 'inactive')
    endif

    "setlocal statusline=%!statusline#set(winnr())
    "let &l:statusline = '%!statusline#build(' . l:win.winnr . ')'
    call setwinvar(nr, '&statusline', '%!statusline#build(' . nr . ')')
    "call setwinvar(l:win.winnr, '&statusline', '%!statusline#set(' . l:win.winnr . ')')
  endfor
endfunction

" Build status string
function statusline#build(winnr)
  let l:win = s:wins[a:winnr]
  let l:mode = exists('l:win.mode') ? l:win.mode : s:mode()
  "echom "mode " . l:mode . ' / ' . l:win.winnr . " active? " . l:win.active

  " Refresh the status line string
  " Only if the mode changed, the window was resized or the string is undefined
  if get(w:, 'statusline_mode', '') != l:mode
      \ || (exists('l:win.columns') && l:win.columns != &columns)
      \ || !exists('l:win.line')

    " Update last window mode (used in autoload/builder s:highlight)
    let w:statusline_mode = l:mode

    " Build line
    let l:line = ''

    "if exists('g:statusline.debug') && g:statusline.debug
    "  let l:line.= mode() . ' nr' . l:win.winnr . ':' . l:win.bufnr . ' (' . l:win.active . ')'
    "  "call add(g:statusline.tpl, { 'string': l:win.debug_string })
    "endif

    " if exists('w:statusline_overwrite')
    "   let l:line.= w:statusline_overwrite
    " endif
    "let l:list = s:template_{g:statusline.template}
    for item in g:statusline.tpl
      let l:line.= statusline#builder#add(item, l:win)
      unlet item
    endfor

    " Update window object
    let l:win.line = l:line
    let l:win.columns = &columns
    "let s:wins[a:winnr] = l:win
  "else
    "let l:line = l:win.line
  endif

  " Send final string
  return l:win.line
endfunction

function statusline#template(...)
  let l:template = a:0 > 0 ? a:1 : g:statusline.template
  call s:load('tpl', 'g:statusline#templates', l:template, 'default')
endfunction

" github.com/vim-airline/vim-airline/blob/master/autoload/airline/colorschemes.vim
function statusline#colorscheme(...)
  let l:colorscheme = a:0 > 0 ? a:1 : g:statusline.colorscheme
  " Match &colorscheme?
  call s:load('color', 'g:statusline#colorschemes', l:colorscheme, 'base16')

  " Update highlight groups (User#)
  call statusline#highlight()
endfunction

function statusline#highlight()
  if !exists('g:statusline.color') | return | endif
  let l:cterm = g:statusline.color.map.cterm
  let l:gui = g:statusline.color.map.gui
  for group in g:statusline.color.scheme "[key, colors] in items(s:colorscheme)
    let l:index = 0
    if has_key(group, 'mode') && has_key (group, 'map') && len(group.map) > 0
      for color in group.map
        if len(color) != 2 | continue | endif
        let l:index = l:index + 1
        let l:hi = 'highlight StatusLine' . group.mode . l:index
        " let l:hi = 'highlight statusline' . key . (l:index > 0 ? l:index + 1 : '')
        " TODO: check has_key
        let l:hi.= ' ctermfg=' . l:cterm[color[0]] . ' ctermbg=' . l:cterm[color[1]]
        let l:hi.= ' guifg=' . l:gui[color[0]] . ' guibg=' . l:gui[color[1]]
        execute l:hi
        unlet color
      endfor
    endif
    unlet group
  endfor
endfunction

function s:load(var, func, name, default)
  " var: script variable to assign
  " func: autoload path
  " name: autoload file name
  " default: fallback if name is empty or autoload failed
  if strlen(a:name) > 0 && strlen(a:var) > 0
    try
      let g:statusline[a:var] = {a:func}#{a:name}#load()
    catch
      echom 'Could not load "' . a:func . '#' . a:name . '#load()"'
    endtry
  endif
  "if !get(g:statusline, a:var, [])
  if !has_key(g:statusline, a:var)
    let g:statusline[a:var] = {a:func}#{a:default}#load()
  endif
endfunction

" Output mode string
function s:mode()
  let l:mode = mode()

  " if !a:active
  "   let l:mode = 'inactive'
  if l:mode ==# 'n'
    let l:mode = 'normal'
  elseif l:mode ==# 'i'
    let l:mode = 'insert'
  elseif l:mode ==# 'R'
    let l:mode = 'replace'
  elseif l:mode =~# '\v(v|V||s|S|)'
    let l:mode = 'visual'
  elseif l:mode ==# 'c'
    let l:mode = 'command'
  elseif l:mode ==# 't'
    let l:mode = 'terminal'
  endif

  return l:mode "join(l:mode)
endfunction

