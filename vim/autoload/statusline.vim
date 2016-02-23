" Status line

" github.com/vim-airline/vim-airline

" Always show the status line
set laststatus=2

" Do not display current mode
set noshowmode

" Display incomplete commands
set showcmd

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

" g:loaded_statusline?

let s:build = {}
let statusline#Build = {}

call statusline#utils#define('g:statusline', {})

call statusline#utils#define('g:statusline#symbol', {})
call extend(g:statusline#symbol, {
  \ 'paste': 'PASTE',
  \ 'readonly': get(g:, 'powerline_fonts', 0) ? "\ue0a2" : 'RO',
  \ 'whitespace': get(g:, 'powerline_fonts', 0) ? "\u2739" : '!',
  \ 'linenr': get(g:, 'powerline_fonts', 0) ? "\ue0a1" : ':',
  \ 'branch': get(g:, 'powerline_fonts', 0) ? "\ue0a0" : '⎇ ',
  \ 'crypt': get(g:, 'crypt_symbol', nr2char(0x1F512)),
  \ 'modified': '+',
  \ 'close': '✕',
  \ 'sep': '|',
  \ })

if !exists('g:statusline#style')
  let g:statusline#style={}
endif

" Symbols ⎇ /|•·
"let ' ' = ' '
"let g:statusline#symbol.sep = '|'
"let g:statusline#symbol.branch = '⎇ '
"let g:statusline#symbol.readonly = 'RO'

call statusline#utils#define('g:statusline#style', {})
" Palette
let g:statusline#style.dark = 'ctermfg=11 ctermbg=0'
let g:statusline#style.base = 'ctermfg=12 ctermbg=10'
let g:statusline#style.white = 'ctermfg=13 ctermbg=10'
let g:statusline#style.bright = 'ctermfg=13 ctermbg=11' " fg=12|13
" Mode colors
let g:statusline#style.normal = 'ctermfg=10 ctermbg=4'
let g:statusline#style.insert = 'ctermfg=10 ctermbg=2'
let g:statusline#style.replace = 'ctermfg=13 ctermbg=1' " fg=10
let g:statusline#style.visual = 'ctermfg=10 ctermbg=3'

" Modes
call statusline#utils#define('g:statusline#mode_map', {})
call extend(g:statusline#mode_map, {
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
  \ }, 'keep')

" Apply style to highlight group
function s:build.highlight(group, style)
  exec 'hi StatusLine'.a:group.' '.a:style
endfunction

" Handle colors
function statusline#Build.mode()
  "redraw
  let l:m=mode()
  let l:highlights = [['FileType', 'ctermfg=12']]

  " Default highlight groups
  call add(l:highlights,['', g:statusline#style.base])
  call add(l:highlights,['NC', g:statusline#style.dark])
  " Custom highlight groups
  "Color,Warning?
  call add(l:highlights,['BG', g:statusline#style.dark])
  "call add(l:highlights,['BrightBold', g:statusline#style.bright]) " .' cterm=bold'])
  "File?
  call add(l:highlights,['Info', g:statusline#style.bright])

  " Default status line style
  let l:hi_bright=g:statusline#style.bright
  let l:mode_color=g:statusline#style.base
  let l:hi_line=g:statusline#style.base
  let l:hi_file=g:statusline#style.white
  let l:hi_bg=g:statusline#style.dark "base dark?

  "if get(w:,'statusline_active', 1)
  if get(w:, 'statusline_active', 1)
    if l:m ==# "n""
      let l:mode_color=g:statusline#style.normal
    elseif l:m ==# "i"
      let l:mode_color=g:statusline#style.insert
      let l:hi_line=g:statusline#style.insert
      "let l:branch=g:statusline#style.insert " 'ctermfg=2 ctermbg=11 cterm=bold'
      let l:hi_file=g:statusline#style.insert
      let l:hi_bg=g:statusline#style.insert
      "let l:hi_bright='ctermfg=13'
    elseif l:m ==# "R"
      let l:mode_color=g:statusline#style.replace
    elseif l:m ==# "v"
      let l:mode_color=g:statusline#style.visual
    elseif l:m ==# "V"
      let l:mode_color=g:statusline#style.visual
    elseif l:m ==# ""
      let l:mode_color=g:statusline#style.visual
    endif
  else
    let l:m='__'
    "let l:mode_color='ctermfg=12'
    "let l:hi_line='ctermfg=12 ctermbg=0'
    let l:hi_bg = g:statusline#style.base
    let l:hi_file = g:statusline#style.base
    let l:hi_bright=g:statusline#style.base
  endif

  "let w:statusline_mode
  let l:mode = get(g:statusline#mode_map, l:m, l:m)

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

  for [g,s] in l:highlights
    call s:build.highlight(g, s)
  endfor

  return statusline#utils#truncate(l:mode, 20)
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
    return strlen(_) ? statusline#utils#truncate(g:statusline#symbol.branch.' '._, 60) : ''
  endif
  return ''
endfunction

" File encoding and format
function statusline#Build.fileInfo()
  let l:info=''
  " File type %(y|Y)
  "let l:l.='%#StatusLineType#'
  "let l:l.='%( %{&filetype} %)'

  " File encoding and format
  "let l:l.='%#StatusLineInfo#'

  let l:info.=' '

  if (&filetype!='')
    let l:type=&filetype
  else
    let l:type='no ft'
  endif

  let l:info.=l:type

  let l:info.=' '
  let l:info.=g:statusline#symbol.sep
  let l:info.=' '

  if (&fenc!='')
    let l:encoding=&fenc
  else
    let l:encoding=&enc
  endif
  if (exists("+bomb") && &bomb)
    let l:encoding.=",B"
  endif

  let l:info.=l:encoding

  let l:info.=' '
  let l:info.=g:statusline#symbol.sep
  let l:info.=' '

  let l:info.=&fileformat
  let l:info.=' '

  return statusline#utils#truncate(l:info, 80)
endfunction

function statusline#Build.filePos()
  " Percent through file
  let l:pos=' %3(%P%) '

  return statusline#utils#truncate(l:pos, 60)
endfunction

function statusline#Build.cursorPos()
  " Cursor position
  let l:pos=''

  let l:pos.=' '

  " %l Line number
  " $c Column number
  " %V Virtual column
  let l:pos.='%4(%l:%)%-3(%c%V%)'

  "let l:pos.=' '
  " %P Percent through file
  "let l:pos.='%4(%p%%%)'

  let l:pos.=' '

  return statusline#utils#truncate(l:pos, 40)
endfunction

function statusline#Build.warningMsg()
  if exists("g:loaded_syntastic_plugin")
    let _ = SyntasticStatuslineFlag()
    return strlen(_) ? _ : ''
  endif
  return ''
endfunction

function statusline#Build.render()
  let l:l=''

  " Display colored mode
  let l:l.='%#StatusLineModeBold#'
  let l:l.='%( %{statusline#Build.mode()} %)'

  let l:l.='%#StatusLineMode#'
  let l:l.='%( %{statusline#Build.hasPaste()} %)'

  " Current branch
  let l:l.='%#StatusLineBrightBold#'
  let l:l.='%( %{statusline#Build.branch()} %)'
  "
  " Reset color to default highlight groupe 'StatusLine'
  let l:l.='%*'

  " File segment
  let l:l.='%#StatusLineFile#'
  " Break point
  let l:l.=' %<'
  " %n Buffer index
  let l:l.='%n'
  " %f Relative path
  let l:l.=' %f '

  " File flags
  " %H Help buffer
  " %R Readonly
  " %M Modified or unmodifiable
  let l:l.='%([%R%M] %)'

  " No color section
  "let l:l.='%#StatusLineNC#'

  let l:l.='%#StatusLineBG#'

  " Right align past this point
  let l:l.='%='

  " Register
  let l:l.='%( %{v:register} %)'

  " File details
  let l:l.='%#StatusLineBase#'
  let l:l.=self.fileInfo()

  let l:l.='%#StatusLineBright#'
  let l:l.=self.filePos()

  let l:l.='%#StatusLineMode#'
  let l:l.=self.cursorPos()

  " Syntastic "let l:l.='%#StatusLineWarning#'
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
    "au WinEnter * exec 'hi StatusLineBG '.g:statusline#style.dark
    "au WinLeave * hi clear StatusLineBG
  endif

  "autocmd ColorScheme,VimEnter * call SetStatusLine()

  " BufWinEnter/Leave?
  au BufEnter,WinEnter * let w:statusline_active = 1
  au BufLeave,WinLeave * let w:statusline_active = 0
  au BufEnter,BufLeave,BufAdd,WinEnter,WinLeave * setl statusline=%!statusline#Build.render()
endif

"setl statusline=%!statusline#Build.render()
