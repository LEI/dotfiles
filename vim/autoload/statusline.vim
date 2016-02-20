" Status line

" github.com/vim-airline/vim-airline

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

" Format the status line
"set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l

" git status, column/row number, total lines, and percentage in status
"set statusline=%F%m%r%h%w\ %{fugitive#statusline()}\ [%l,%c]\ [%L,%p%%]

"autocmd ColorScheme *
"    \ hi StatusLineMode ctermbg=1 ctermfg=10 cterm=bold " Normal
"    \ hi User2 ctermbg=2 ctermfg=10 cterm=bold " Replace
"    \ hi User3 ctermbg=3 ctermfg=10 cterm=bold " Insert
"    \ hi User4 ctermbg=4 ctermfg=10 cterm=bold " Visual?

let statusline#Build={} "loaded: 1}

if !exists('g:statusline')
  let g:statusline={}
endif

if !exists('g:statusline#symbol')
  let g:statusline#symbol={}
endif

if !exists('g:statusline#hi')
  let g:statusline#hi={}
endif

" Symbols ⎇ /|•·
let g:statusline#symbol.space = ' '
let g:statusline#symbol.sep = '|'
let g:statusline#symbol.branch = '⎇ '
"let g:statusline#symbol.readonly = 'RO'

" Colors
let g:statusline#hi.dark = 'ctermfg=11 ctermbg=0'
let g:statusline#hi.base = 'ctermfg=12 ctermbg=10'
let g:statusline#hi.bright = 'ctermfg=12 ctermbg=11'
"let g:statusline#hi.dark = 'ctermfg=12 ctermbg=10'
" Modes (white color: ctermfg=13)
let g:statusline#hi.normal = 'ctermfg=10 ctermbg=4'
let g:statusline#hi.insert = 'ctermfg=10 ctermbg=2'
let g:statusline#hi.replace = 'ctermfg=13 ctermbg=1' " fg=10
let g:statusline#hi.visual = 'ctermfg=10 ctermbg=3'

" Highlight groups
exec 'hi StatusLine '.g:statusline#hi.base
exec 'hi StatusLineNC '.g:statusline#hi.dark
" Custom
exec 'hi StatusLineBG '.g:statusline#hi.dark
exec 'hi StatusLinePaste '.g:statusline#hi.base
exec 'hi StatusLineBranch '.g:statusline#hi.bright.' cterm=bold'
"exec 'hi StatusLineFile '.g:statusline#hi.base
exec 'hi StatusLineInfo '.g:statusline#hi.bright

"hi StatusLineColor ctermbg=0
"hi StatusLineWarning ctermfg=0 ctermbg=1
" warning 9?

" Vim mode

let g:statusline#mode_map = {
  \ '__' : '------',
  \ 'n'  : 'NORMAL',
  \ 'i'  : 'INSERT',
  \ 'R'  : 'REPLACE',
  \ 'v'  : 'VISUAL',
  \ 'V'  : 'V-LINE',
  \ 'c'  : 'COMMAND',
  \ '' : 'V-BLOCK',
  \ 's'  : 'SELECT',
  \ 'S'  : 'S-LINE',
  \ '' : 'S-BLOCK',
  \ 't'  : 'TERMINAL',
  \ }

function statusline#Build.mode()
  "redraw
  let l:m=mode()
  let l:highlights = [['FileType', 'ctermfg=12']]

  " Default status line style
  let l:hi_bright=g:statusline#hi.bright
  let l:hi_color=g:statusline#hi.base
  let l:hi_line=g:statusline#hi.base "base
  "let l:hi_file=g:statusline#hi.base
  let l:hi_bg=g:statusline#hi.dark

  "if get(w:,'statusline_active', 1)
  if get(w:, 'statusline_active', 1)
    if l:m ==# "n""
      let l:hi_color=g:statusline#hi.normal
    elseif l:m ==# "i"
      let l:hi_color=g:statusline#hi.insert
      let l:hi_line=g:statusline#hi.insert
      "let l:branch=g:statusline#hi.insert " 'ctermfg=2 ctermbg=11 cterm=bold'
      "let l:hi_file=g:statusline#hi.insert
      let l:hi_bg=g:statusline#hi.insert
      "call s:highlight('', 'ctermfg=2')
    elseif l:m ==# "R"
      let l:hi_color=g:statusline#hi.replace
    elseif l:m ==# "v"
      let l:hi_color=g:statusline#hi.visual
    elseif l:m ==# "V"
      let l:hi_color=g:statusline#hi.visual
    elseif l:m ==# ""
      let l:hi_color=g:statusline#hi.visual
    endif
  else
    let l:m='__'
    "let l:hi_color='ctermfg=12'
    let l:hi_line='ctermfg=12 ctermbg=0'
    let l:hi_bright=g:statusline#hi.dark
  endif

  "let w:statusline_mode
  let l:mode = get(g:statusline#mode_map, l:m, l:m)

  "hi StatusLine &l:base
  "hi StatusLineMode &l:hi_color

  " Set the base color
  "exec 'hi StatusLine '.l:hi_line
  "exec 'hi StatusLineBG '.l:hi_bg

  call add(l:highlights, ['File', l:hi_line])
  call add(l:highlights, ['BG', l:hi_bg])

  " Use mode color for other parts
  "exec 'hi StatusLineColor '.l:hi_color
  " Then add bold to mode label
  "let l:hi_color.=' cterm=bold'
  "exec 'hi StatusLineMode '.l:hi_color.' cterm=bold'
  "exec 'hi StatusLineBranch '.l:branch.' cterm=bold'
  call add(l:highlights, ['Color', l:hi_color])
  call add(l:highlights, ['Mode', l:hi_color.' cterm=bold'])



  "exec 'hi StatusLineFile '.l:hi_file
  "exec 'hi StatusLineInfo '.l:hi_bright
  call add(l:highlights, ['Branch', l:hi_bright.' cterm=bold'])
  call add(l:highlights, ['Info', l:hi_bright])

  for [g,s] in l:highlights
    call s:build.highlight(g, s)
  endfor

  return l:mode
endfunction

let s:build = {}
function s:build.highlight(group, style)
  exec 'hi StatusLine'.a:group.' '.a:style
endfunction

" Returns true if paste mode is enabled
function statusline#Build.hasPaste()
    if &paste
        return 'PASTE'
    endif
    return ''
endfunction

" Git
function statusline#Build.branch()
  if exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? g:statusline#symbol.branch.' '._ : ''
  endif
  return ''
endfunction

" File encoding
function statusline#Build.fileEncoding()
  if (&fenc!='')
    let l:encoding=&fenc
  else
    let l:encoding=&enc
  endif

  if (exists("+bomb") && &bomb)
    let l:encoding.=",B"
  endif

  return l:encoding
endfunction

function statusline#Build.warningMsg()
  "if exists("SyntasticStatuslineFlag")
  if exists("g:loaded_syntastic_plugin")
    let _ = SyntasticStatuslineFlag()
    echo _
    return strlen(_) ? _ : ''
  endif
  return ''
endfunction

function statusline#Build.render()
  let l:l=''

  " Display colored mode
  let l:l.='%#StatusLineMode#'
  let l:l.=' %{statusline#Build.mode()} '

  let l:l.='%#StatusLinePaste#'
  let l:l.='%( %{statusline#Build.hasPaste()} %)'

  " Current branch
  let l:l.='%#StatusLineBranch#'
  let l:l.='%( %{statusline#Build.branch()} %)'
  "
  " Reset color to default highlight groupe 'StatusLine'
  let l:l.='%*'


  " Buffer index and relative path
  let l:l.='%#StatusLineFile#'
  " Break point
  let l:l.=' %<'
  let l:l.='%n %f '

  " Help, readonly, and modified flags
  let l:l.='%([%H%R%M] %)'

  " No color section
  let l:l.='%#StatusLineNC#'
  "let l:l.='%#StatusLineBG#'

  " Right align past this point
  let l:l.='%='

  " Register
  let l:l.='%( %{v:register} %)'

  " File type %(y|Y)
  let l:l.='%#StatusLineType#'
  let l:l.='%( %{&filetype} %)'

  " File encoding and format
  let l:l.='%#StatusLineInfo#'
  let l:l.=g:statusline#symbol.space
  let l:l.='%{statusline#Build.fileEncoding()}'
  let l:l.=g:statusline#symbol.space.g:statusline#symbol.sep.g:statusline#symbol.space
  let l:l.=&fileformat
  let l:l.=g:statusline#symbol.space

  " File position
  let l:l.='%#StatusLineColor#'
  " Percent through file
  let l:l.=' %p%% '
  let l:l.=g:statusline#symbol.sep
  " Line and column number
  let l:l.=' %l: %c '
  " Virtual column: %V
  " Total lines: %L

  " Syntastic
  "let l:l.='%#StatusLineWarning#'
  let l:l.='%#warningmsg#'
  let l:l.='%( %{statusline#Build.warningMsg()} %)'
  let l:l.='%*'

  return l:l
endfunction

function! statusline#set()
  setl statusline=%!statusline#Build.render()

endfunction

if has("autocmd") && get(g:, 'statusline_loaded_autocmd', 1)
  let g:statusline_loaded_autocmd = 1

  if !has('gui_running')
    "au InsertEnter  * redraw!
    "au InsertChange * redraw!
    "au InsertLeave  * redraw!
    "au InsertLeave * call SetStatusLine()
    "call setwinvar(s:render
    "au WinEnter * exec 'hi StatusLineBG '.g:statusline#hi.dark
    "au WinLeave * hi clear StatusLineBG
  endif

  "autocmd ColorScheme,VimEnter * call SetStatusLine()
  au BufEnter,WinEnter * let w:statusline_active = 1
  au BufLeave,WinLeave * let w:statusline_active = 0
  au BufEnter,BufLeave,BufAdd,WinEnter,WinLeave * setl statusline=%!statusline#Build.render()
endif
