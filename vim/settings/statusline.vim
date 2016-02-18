" Status line

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

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

"autocmd ColorScheme *
"    \ hi StatusLineMode ctermbg=1 ctermfg=10 cterm=bold " Normal
"    \ hi User2 ctermbg=2 ctermfg=10 cterm=bold " Replace
"    \ hi User3 ctermbg=3 ctermfg=10 cterm=bold " Insert
"    \ hi User4 ctermbg=4 ctermfg=10 cterm=bold " Visual?

if !exists('g:statusline')
  let g:statusline={}
endif

if !exists('g:statusline.symbol')
  let g:statusline.symbol={}
endif

if !exists('g:statusline.style')
  let g:statusline.style={}
endif

" Symbols ⎇ /|•·
let g:statusline.symbol.sep = '|'
let g:statusline.symbol.branch = '⎇ '
"let g:statusline.symbol.readonly = 'RO'

" Colors
let g:statusline.style.dark = 'ctermfg=11 ctermbg=0'
let g:statusline.style.base = 'ctermfg=12 ctermbg=10'
let g:statusline.style.bright = 'ctermfg=12 ctermbg=11'
"let g:statusline.style.dark = 'ctermfg=12 ctermbg=10'
" Modes (white color: ctermfg=13)
let g:statusline.style.normal = 'ctermfg=10 ctermbg=4'
let g:statusline.style.insert = 'ctermfg=10 ctermbg=2'
let g:statusline.style.replace = 'ctermfg=13 ctermbg=1' " fg=10
let g:statusline.style.visual = 'ctermfg=10 ctermbg=3'

" Highlight groups
exec 'hi StatusLine '.g:statusline.style.base
exec 'hi StatusLineNC '.g:statusline.style.dark
" Custom
exec 'hi StatusLineBranch '.g:statusline.style.bright.' cterm=bold'
"exec 'hi StatusLineFile '.g:statusline.style.base
exec 'hi StatusLineFileInfo '.g:statusline.style.bright

hi StatusLineColor ctermbg=0
"hi StatusLineWarning ctermfg=0 ctermbg=1
" warning 9?

" Vim mode
function! StatusLineMode()
  "redraw
  let l:mode=mode()

  " Default status line style
  let l:style=g:statusline.style.base
  let l:line=g:statusline.style.base "^^^
  "let l:branch=g:statusline.style.bright
  let l:file=g:statusline.style.base

  if mode ==# "n""
    let l:mode='NORMAL'
    let l:style=g:statusline.style.normal
  elseif mode ==# "i"
    let l:mode='INSERT'
    let l:style=g:statusline.style.insert
    let l:line=g:statusline.style.insert
    "let l:branch=g:statusline.style.insert " 'ctermfg=2 ctermbg=11 cterm=bold'
    let l:file=g:statusline.style.insert
  elseif mode ==# "R"
    let l:mode='REPLACE'
    let l:style=g:statusline.style.replace
  elseif mode ==# "v"
    let l:mode='VISUAL'
    let l:style=g:statusline.style.visual
  elseif mode ==# "V"
    let l:mode='V-LINE'
    let l:style=g:statusline.style.visual
  elseif mode ==# ""
    let l:mode='V-BLOCK'
    let l:style=g:statusline.style.visual
  "else
    "let l:mode='?' "l:mode
  endif

  "hi StatusLine &l:base
  "hi StatusLineMode &l:style

  exec 'hi StatusLine '.l:line

  exec 'hi StatusLineColor '.l:style

  " Add bold to mode label
  let l:style.=' cterm=bold'

  exec 'hi StatusLineMode '.l:style
  "exec 'hi StatusLineBranch '.l:branch.' cterm=bold'

  exec 'hi StatusLineFile '.l:file
  "exec 'hi StatusLineFileInfo '.l:info

  return l:mode
endfunc

" Git
function! StatusLineBranch()
  if exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? g:statusline.symbol.branch.' '._ : ''
  endif
  return ''
endfunc

" File encoding and format
function! StatusLineFileInfo()
  if (&fenc!='')
    let l:encoding=&fenc
  else
    let l:encoding=&enc
  endif

  if (exists("+bomb") && &bomb)
    let l:encoding.=",B"
  endif

  " &filetype %y
  return l:encoding.' '.g:statusline.symbol.sep.' '.&fileformat
endfunc

function! StatusLineSyntastic()
  "if exists("SyntasticStatuslineFlag")
  if exists("g:loaded_syntastic_plugin")
    let _ = SyntasticStatuslineFlag()
    echo _
    return strlen(_) ? _ : ''
  endif
  return ''
endfunc

function! SetStatusLine()
  let l:l=''

  " Display colored mode
  let l:l.='%#StatusLineMode#'
  let l:l.=' %{StatusLineMode()} '

  " Current branch
  let l:l.='%#StatusLineBranch#'
  let l:l.='%( %{StatusLineBranch()} %)'
  " Reset color to default highlight groupe 'StatusLine'
  let l:l.='%*'

  " Buffer index, collapse marker and relative path
  "let l:l.='%#StatusLineFile#'
  let l:l.='%< %n %f '

  " No color section
  let l:l.='%#StatusLineNC#'

  " Help, readonly, and modified flags
  let l:l.='%( [%H%R%M] %)'

  " Right align past this point
  let l:l.='%='

  " Register
  let l:l.='%( %{v:register} %)'

  " File type (y/Y)
  let l:l.='%( %{&filetype} %)'

  " File type
  let l:l.='%#StatusLineFileInfo#'
  let l:l.='%( %{StatusLineFileInfo()} %)'

  " File position
  let l:l.='%#StatusLineColor#'
  " Percent through file
  let l:l.=' %p%% '
  let l:l.=g:statusline.symbol.sep
  " Line and column number
  let l:l.=' %l: %c '
  " Virtual column: %V
  " Total lines: %L

  " Syntastic
  "let l:l.='%#StatusLineWarning#'
  let l:l.='%#warningmsg#'
  let l:l.='%( %{StatusLineSyntastic()} %)'
  let l:l.='%*'

  return l:l
endfunc

if has("autocmd")
  if !has('gui_running')
    "au InsertEnter  * redraw!
    "au InsertChange * redraw!
    "au InsertLeave  * redraw!
    "au InsertLeave * call SetStatusLine()
  endif

  "autocmd ColorScheme,VimEnter * call SetStatusLine()
endif

" Set status line
set statusline=%!SetStatusLine()

