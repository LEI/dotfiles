" Vim statusline

" https://github.com/itchyny/lightline.vim

if get(g:, 'loaded_statusline', 0)
  finish
endif
let g:loaded_statusline = 1

let s:save_cpo = &cpo
set cpo&vim

" Default Status Line:
"   %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

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

if !exists('g:statusline')
  let g:statusline = {}
endif

call extend(g:statusline, { 'modes': {}, 'symbols': {}, }, 'keep')

call extend(g:statusline.modes, {
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
\}, 'keep')

" Branch: system('uname -s')[:5] ==? 'Darwin' ? nr2char(0x2387) . ' ' : ''
" Close: nr2char(0x2715)
" Lock: nr2char(0x1F512)
" |- nr2char(0x251C),
call extend(g:statusline.symbols, {
      \ 'branch': '',
      \ 'key': nr2char(0x1F511) . ' ',
      \ 'readonly': 'RO',
      \ 'paste': '(paste)',
      \ 'separator': nr2char(0x2502),
\}, 'keep')

" set statusline=%!Statusline(winnr())
" set noshowmode

" autocmd BufAdd,BufEnter,WinEnter * call StatusLineBuild()
" for nr in range(1, winnr('$'))
"   call setwinvar(nr, '&statusline', '%!Statusline(' . nr . ')')
" endfor

augroup Statusline
  autocmd!
  " Create the highlight groups on startup and when the colorscheme changes
  autocmd VimEnter,ColorScheme * call StatuslineColors() | redrawstatus
  " Assign the statusline to the window
  autocmd BufAdd,BufEnter,WinEnter * call SetStatusline(winnr())
  " Command line mode
  autocmd CmdWinEnter * let &l:statusline='%!Statusline(' . winnr() . ', "", 1)'
  " Quickfix location list
  autocmd FileType qf let &l:statusline='%!Statusline(' . winnr() . ', "%f %{w:quickfix_title}", 2)'
  " Update the statusline highlight group
  autocmd InsertEnter * call StatuslineHighlight(v:insertmode)
  autocmd InsertChange * call StatuslineHighlight(v:insertmode)
  autocmd InsertLeave * call StatuslineHighlight()
augroup END

function! SetStatusline(nr)
  let l:stl = ''
  let l:file = expand('%:t')
  if l:file == '__Gundo__'
    let l:stl = '%!Statusline(' . a:nr . ', "[Gundo]", 2)'
  elseif l:file == '__Gundo_Preview__'
    let l:stl = '%!Statusline(' . a:nr . ', "[Preview]", 2)'
  elseif &filetype != 'qf'
    let l:stl = '%!Statusline(' . a:nr . ')'
  endif

  if strlen(l:stl) > 0
    call setwinvar(a:nr, '&statusline', l:stl)
  endif
endfunction

function! Statusline(winnr, ...)
  let l:mode = a:winnr == winnr() ? mode() : 0
  call setwinvar(a:winnr, 'mode', l:mode)

  let l:title = a:0 > 0 ? a:1 : ''

  " Readonly: hide non relevant parts
  " (1: branch, 2: mode, ft)
  let l:ro = a:0 > 1 ? a:2 : 0

  let l:sep = get(g:statusline.symbols, 'separator')

  let l:s = ''

  if winwidth(0) > 40 && l:ro < 2
    " Vim mode
    let l:s.= ' %{StatuslineMode(w:mode)}'
    let l:s.= ' ' . l:sep
  endif

  if winwidth(0) > 60 && l:ro < 1
    " Fugitive
    let l:s.= '%( ' . get(g:statusline.symbols, 'branch')
    let l:s.='%{StatuslineFugitive()}'
    let l:s.= ' ' . l:sep . '%)'
  endif

  " Truncate
  let l:s.= '%<'

  " Buffer number
  " let l:s.= ' %n'

  if strlen(l:title) > 0
    let l:s.= ' ' . l:title
  else
    " File path
    let l:s.= ' %f'
  endif

  " Flags
  " let l:s.= '%( [%H%R%M]%)'
  let l:s.= '%( [%{StatuslineFlags()}]%)'

  " Split
  let l:s.= '%='

  " Syntastic
  let l:s.= ' %#StatuslineWarning#'
  let l:s.= '%( %{exists("g:loaded_syntastic_plugin") ? SyntasticStatuslineFlag() : ""} %)'
  let l:s.= '%*'

  " let l:s.= '%{v:register}'

  " if winwidth(0) > 80 && l:ro < 1
  "   " File format
  "   let l:s.= ' %{&fileformat} '
  "   " File encoding
  "   let l:s.= '[%{&fenc != "" ? &fenc : &enc}%{exists("+bomb") && &bomb ? ",B" : ""}]'
  "   let l:s.= ' ' . l:sep
  " endif

  if winwidth(0) > 60 && l:ro < 2
    " File type (%y, %Y)
    let l:s.= ' %{&filetype != "" ? &filetype : "no ft"}'
    " let l:s.= '%([%{&filetype}]%)'
    let l:s.= ' ' . l:sep . ' '
  endif

  " Encrypted buffer (TODO: symbol)
  " if exists('+key') && !empty(&key)
  "   let l:s.= get(g:statusline.symbols, 'key', '')
  " endif

  if winwidth(0) > 40
    " Cursor position
    " let l:s.= ' %-12.(%l,%c%V%)'
    " <line>,<column>/<total>
    let l:s.= '%-14.(%l,%c%V/%L %)'

    " File position
    let l:s.= '%P '
  endif

  return l:s
endfunction

function! StatuslineMode(mode)
  let l:inactive = '------'
  let l:mode = get(g:statusline.modes, a:mode, l:inactive)

  " If the window is active and paste mode is enabled
  if a:mode != l:inactive && &paste
    let l:mode.= ' ' . g:statusline.symbols.paste
  endif

  return l:mode
endfunction

function! StatuslineFugitive()
  if !exists('*fugitive#head')
    return ''
  endif

  " system('git status --porcelain ' . shellescape(expand('%')))
  return fugitive#head(7)
endfunction

function! StatuslineFlags()
  let l:flags = []

  " %H HLP (help buffer)
  " %R RO (readonly)
  " %M +,- (modifiable)

  " %w,%W -> [Preview],PRV
  " %a -> Argument list status if argv() > 1
  " %T,%X <N> -> 'tabline'

  " Note: gundo, help and vim-plug set &buftype to 'nofile'

  if &buftype == 'help'
    call add(l:flags, 'H')
  elseif &buftype != 'nofile' && &filetype !~ 'help\|netrw\|qf\|vim-plug'
    if &readonly
      call add(l:flags, g:statusline.symbols.readonly)
    endif
    if &modified
      call add(l:flags, '+')
    elseif !&modifiable
      call add(l:flags, '-')
    endif
  endif

  return join(l:flags, ',')
endfunction

function! StatuslineColors()
  " Solarized Statusline Colors:
  " Red: 1
  " Green: 2
  " Yellow: 3
  " Blue: 4
  " Magenta: 5
  " Cyan: 6
  " Brightred: 9
  if &background == 'dark'
    " Base16 Solarized Dark
    " StatusLine: term=bold,reverse ctermfg=12 ctermbg=11 guifg=#839496 guibg=#586e75
    " StatusLineNC: term=reverse ctermfg=8 ctermbg=10 guifg=#657b83 guibg=#073642
    " highlight StatusLine term=bold,reverse ctermfg=13 ctermbg=11 guifg=#839496 guibg=#586e75
    " highlight StatusLineNC term=reverse ctermfg=8 ctermbg=10 guifg=#657b83 guibg=#073642
    " highlight StatusLineInsert ctermfg=0 ctermbg=2
    " highlight StatusLineReplace ctermfg=13 ctermbg=1

    " highlight StatusLine term=reverse cterm=reverse ctermfg=14 ctermbg=0 gui=bold,reverse
    " highlight StatusLineNC term=reverse cterm=reverse ctermfg=11 ctermbg=0 gui=reverse

    highlight StatusLineInsert ctermfg=0 ctermbg=2
    highlight StatusLineReplace ctermfg=0 ctermbg=1
  else
    " Base16 Solarized Light
    " StatusLine: term=bold,reverse ctermfg=8 ctermbg=7 guifg=#657b83 guibg=#93a1a1
    " StatusLineNC: term=reverse ctermfg=12 ctermbg=13 guifg=#839496 guibg=#eee8d5
    " highlight StatusLine term=bold,reverse ctermfg=15 ctermbg=7 guifg=#657b83 guibg=#93a1a1
    " highlight StatusLineNC term=reverse ctermfg=12 ctermbg=13 guifg=#839496 guibg=#eee8d5
    " highlight StatusLineInsert ctermfg=13 ctermbg=2
    " highlight StatusLineReplace ctermfg=13 ctermbg=1

    " highlight StatusLine term=reverse cterm=reverse ctermfg=10 ctermbg=7 gui=bold,reverse
    " highlight StatusLineNC term=reverse cterm=reverse ctermfg=12 ctermbg=7 gui=reverse

    highlight StatusLineInsert ctermfg=7 ctermbg=2
    highlight StatusLineReplace ctermfg=7 ctermbg=1
  endif

  " highlight link StatusLineWarning WarningMsg
  highlight StatusLineWarning term=reverse cterm=reverse ctermfg=1 guifg=Red
endfunction

function! StatuslineHighlight(...)
  let l:mode = a:0 > 0 ? a:1 : ''
  if l:mode == 'i'
    " Insert mode
    highlight! link StatusLine StatusLineInsert
  elseif l:mode == 'r'
    " Replace mode
    highlight! link StatusLine StatusLineReplace
  elseif l:mode == 'v'
    " Virtual replace mode
    highlight! link StatusLine StatusLineReplace
  elseif strlen(l:mode) > 0
    echoerr 'Unknown mode: ' . l:mode
  else
    highlight link StatusLine NONE
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
