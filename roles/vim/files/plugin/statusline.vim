" Vim statusline

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

" OSX Command: nr2char(0x2387)
" Close: nr2char(0x2715)
" Lock: nr2char(0x1F512)
call extend(g:statusline.symbols, {
      \ 'key': nr2char(0x1F511) . ' ',
      \ 'readonly': 'RO',
      \ 'paste': '(paste)',
      \ 'separator': nr2char(0x2502),
\}, 'keep')

function! Statusline(winnr)
  call setwinvar(a:winnr, 'mode', a:winnr == winnr() ? mode() : 0)
  let l:sep = get(g:statusline.symbols, 'separator')

  let l:s = ''

  if winwidth(0) > 40
    " Vim mode
    let l:s.= ' %{StatuslineMode(w:mode)}'
    let l:s.= ' ' . l:sep
  endif

  if winwidth(0) > 60
    " Fugitive
    let l:s.= '%( %{StatuslineFugitive()} ' . l:sep . '%)'
  endif

  " Truncate
  let l:s.= '%<'

  " Buffer number
  " let l:s.= ' %n'

  " File path
  let l:s.= ' %f'

  " Flags
  let l:s.= '%( [%{StatuslineFlags()}]%)'

  " Split
  let l:s.= '%= '

  " The name of the register in effect for the current normal mode
  " command (regardless of whether that command actually used a
  " register).  Or for the currently executing normal mode mapping
  " (use this in custom commands that take a register).
  " If none is supplied it is the default register '"', unless
  " 'clipboard' contains "unnamed" or "unnamedplus", then it is
  " '*' or '+'.
  " let l:s.= '%{v:register}'

  if winwidth(0) > 80
    " File format
    let l:s.= '%{&fileformat} '
    " File encoding
    let l:s.= '[%{&fenc != "" ? &fenc : &enc}%{exists("+bomb") && &bomb ? ",B" : ""}]'
    let l:s.= ' ' . l:sep . ' '
  endif

  if winwidth(0) > 60
    " File type (%y, %Y)
    let l:s.= '%{&filetype != "" ? &filetype : "no ft"}'
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

  " Syntastic
  let l:s.= '%#StatuslineWarning#'
  let l:s.= '%( %{exists("g:loaded_syntastic_plugin") ? SyntasticStatuslineFlag() : ""} %)'
  let l:s.= '%*'

  return l:s
endfunction

function! StatuslineMode(mode)
  let l:mode = get(g:statusline.modes, a:mode, '------')

  " If the window is active and has &paste
  if a:mode && &paste
    let l:mode.= ' ' . g:statusline.symbols.paste
  endif

  return l:mode
  " let l:file = expand('%:t')
  " " Cf. https://github.com/itchyny/lightline.vim
  " return l:file == '__Gundo__' ? 'Gundo' :
  "       \ l:file == '__Gundo_Preview__' ? 'Preview' :
  "       \ l:mode
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
  elseif &buftype != 'nofile' && &filetype !~ 'help\|netrw\|vim-plug'
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

function! StatuslineHighlight(mode)
  if a:mode == 'i'
    " Insert mode
    highlight! link StatusLine StatusLineInsert
  elseif a:mode == 'r'
    " Replace mode
    highlight! link StatusLine StatusLineReplace
  elseif a:mode == 'v'
    " Virtual replace mode
    highlight! link StatusLine StatusLineReplace
  else
  "   echom 'MODE: ' . a:mode
    highlight link StatusLine NONE
  endif
endfunction

" set statusline=%!Statusline(winnr())
" set noshowmode

" autocmd BufAdd,BufEnter,WinEnter * call StatusLineBuild()
" function! StatuslineBuild()
"   for nr in range(1, winnr('$'))
"     call setwinvar(nr, '&statusline', '%!Statusline(' . nr . ')')
"   endfor
" endfunction

augroup Statusline
  autocmd!
  " Create the highlight groups on startup and when the colorscheme changes
  autocmd VimEnter,ColorScheme * call StatuslineColors() | redrawstatus
  " Assign the statusline function
  autocmd BufAdd,BufEnter,WinEnter * call setwinvar(winnr(), '&statusline', '%!Statusline(' . winnr() . ')')
  " Update the statusline highlight group
  autocmd InsertEnter * call StatuslineHighlight(v:insertmode)
  autocmd InsertChange * call StatuslineHighlight(v:insertmode)
  " Clear highlight link
  autocmd InsertLeave * highlight link StatusLine NONE
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
