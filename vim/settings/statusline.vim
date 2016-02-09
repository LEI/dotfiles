" Status line

" base16 colors
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

if !exists('g:statusline')
  let g:statusline={}
endif

if !exists('g:statusline.colors')
  let g:statusline.colors={}
endif

if !exists('g:statusline.symbols')
  let g:statusline.symbols={}
endif

let g:statusline.colors.bold = 'cterm=bold'
let g:statusline.colors.line = 'ctermfg=12 ctermbg=11'
let g:statusline.colors.branch = 'ctermfg=12 ctermbg=10'
let g:statusline.colors.filetype = 'ctermfg=12 ctermbg=none'
" Modes
let g:statusline.colors.normal = 'ctermfg=10 ctermbg=4'
let g:statusline.colors.insert = 'ctermfg=10 ctermbg=2'
let g:statusline.colors.replace = 'ctermfg=7 ctermbg=1'
let g:statusline.colors.visual = 'ctermfg=10 ctermbg=3'

let g:statusline.symbols.sep = '|'
let g:statusline.symbols.branch = '⎇'
let g:statusline.symbols.readonly = 'RO'

exec 'hi StatusLine '.g:statusline.colors.line
hi StatusLineNC ctermfg=8 ctermbg=0

exec 'hi User2 '.g:statusline.colors.branch.' '.g:statusline.colors.bold
exec 'hi User3 '.g:statusline.colors.filetype


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

"autocmd ColorScheme *
"    \ hi User1 ctermbg=1 ctermfg=10 cterm=bold " Normal
"    \ hi User2 ctermbg=2 ctermfg=10 cterm=bold " Replace
"    \ hi User3 ctermbg=3 ctermfg=10 cterm=bold " Insert
"    \ hi User4 ctermbg=4 ctermfg=10 cterm=bold " Visual?


function! statusline#set()
  " Collapse to the left
  let &stl=""

  " Display mode with color
  let &stl.="%1* %{statusline#mode()} %0*"

  " Current branch
  let &stl.="%2* %{statusline#fugitive()} %0*"

  " Buffer index and relative path
  let &stl.=" %n:%<%f "

  " Readonly, modified and modifiable flags in brackets
  let &stl.="%([%R%M]%) "

	" Right align past this point
  let &stl.="%= "

  " File type
  let &stl.="%3*%( %{&filetype} %)%0* "         " g:statusline.symbols.sep %y %Y
  " File format
  let &stl.="%{&fileformat} ".g:statusline.symbols.sep." "
  " File encoding
  let &stl.="%(%{(&fenc!=''?&fenc:&enc)} ".g:statusline.symbols.sep." %)"

  ""let &stl.=%{getcwd()}
  ""let &stl.=%{g:statusline.symbols.sep}

  let &stl.="[%l,%c%V] "
  let &stl.="[%L,%p%%] "
  "let &stl.=\
endfunc

function! statusline#mode()
  redraw
  let l:mode = mode()
  exec 'hi StatusLine '.g:statusline.colors.line
  if mode ==# "n""
    exec 'hi User1 '.g:statusline.colors.normal.' '.g:statusline.colors.bold
    return "NORMAL"
  elseif mode ==# "i"
    exec 'hi StatusLine '.g:statusline.colors.insert
    exec 'hi User1 '.g:statusline.colors.insert.' '.g:statusline.colors.bold
    return "INSERT"
  elseif mode ==# "R"
    exec 'hi User1 '.g:statusline.colors.replace.' '.g:statusline.colors.bold
    return "REPLACE"
  elseif mode ==# "v"
    exec 'hi User1 '.g:statusline.colors.visual.' '.g:statusline.colors.bold
    return "VISUAL"
  elseif mode ==# "V"
    exec 'hi User1 '.g:statusline.colors.visual.' '.g:statusline.colors.bold
    return "V-LINE"
  elseif mode ==# ""
    exec 'hi User1 '.g:statusline.colors.visual.' '.g:statusline.colors.bold
    return "V-BLOCK"
  else
    return l:mode
  endif
endfunc

function! statusline#fugitive()
  if exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? g:statusline.symbols.branch.' '._ : ''
  endif
  return ''
endfunc

function! statusline#syntastic()
  if exists("SyntasticStatuslineFlag")
    let _ = SyntasticStatuslineFlag()
    return strlen(_) ? '%#warningmsg#'._.'%*' : ''
  endif
  return ''
endfunc

"if has("autocmd")
"  autocmd InsertEnter * call statusline#color(v:insertmode)
"  autocmd InsertChange * call statusline#color(v:insertmode)
"  autocmd InsertLeave * hi statusline guibg=green
"endif

function! statusline#color(mode)
  if a:mode == 'i'
    hi StatusLine ctermfg=0 ctermbg=2
  elseif a:mode == 'r'
    hi StatusLine ctermfg=12 ctermbg=11
  else
    hi StatusLine ctermbg=12 ctermbg=11
  endif
endfunc

if has("autocmd")

  if !has('gui_running')
    au InsertEnter  * redraw!
    au InsertChange * redraw!
    au InsertLeave  * redraw!
  endif

  " Highlight the status bar in insert mode
  "autocmd InsertEnter * hi StatusLine ctermfg=235 ctermbg=2
  "autocmd InsertLeave * hi StatusLine ctermfg=12 ctermbg=11

  autocmd ColorScheme,VimEnter * call statusline#set()

endif
