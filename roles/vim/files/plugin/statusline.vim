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

call extend(g:statusline.symbols, {
      \ 'branch': get(g:, 'powerline_fonts', 0) ? '\ue0a0' : nr2char(0x2387). ' ',
      \ 'key': nr2char(0x1F511) . ' ',
      \ 'readonly': 'RO',
      \ 'paste': '(paste)',
\}, 'keep')
" 'whitespace': get(g:, 'powerline_fonts', 0) ? '\u2739' : '!',
" 'linenr': get(g:, 'powerline_fonts', 0) ? '\ue0a1' : ':',
" 'close': nr2char(0x2715),
" 'readonly': get(g:, 'powerline_fonts', 0) ? '\ue0a2' : nr2char(0x1F512) . ' ',
" 'separator': nr2char(0x2502),

function! Statusline(winnr)
  call setwinvar(a:winnr, 'mode', a:winnr == winnr() ? mode() : 0)

  let l:s = ''

  if winwidth(0) > 40
    " Mode

    let l:s.= ' %{StatuslineMode(w:mode)} '
  endif

  if winwidth(0) > 60
    " Fugitive
    if exists('*fugitive#head') && strlen(fugitive#head(7)) > 0
      let l:s.= '%{g:statusline.symbols.branch} %{fugitive#head(7)} '
    endif
  endif

  " Truncate
  let l:s.= '%<'

  " Buffer number
  " let l:s.= '%n'
  " File path
  let l:s.= '%f '

  " Flags
  " %H HLP (help buffer)
  " %R RO (readonly)
  " %M +,- (modifiable)
  let l:s.= '%([%{StatuslineFlags()}]%)'
  " if &filetype !~ 'help\|netrw\|vim-plug'
  "   let l:s.= '[%R%M]'
  " elseif &filetype ==  'help'
  "   let l:s.= '[H]'
  " endif

  " Split
  let l:s.= '%='

  " Syntastic
  let l:s.= '%#StatuslineWarning#'
  let l:s.= '%( %{exists("g:loaded_syntastic_plugin") ? SyntasticStatuslineFlag() : ""} %)'
  let l:s.= '%*'

  if winwidth(0) > 80
    " Register
    let l:s.= ' %{v:register}'

    " " File format
    " let l:s.= ' %{&fileformat}'
    " " File encoding
    " let l:s.= ' [%{&fenc != "" ? &fenc : &enc}%{exists("+bomb") && &bomb ? ",B" : ""}]'

    " File type
    let l:s.= ' %y'
    " let l:s.= ' %{&ft != "" ? "[" . &ft . "]" : ""}'
    " let l:s.= '%([%{&filetype}]%)'

    " Encrypted buffer (TODO: symbol)
    " if exists('+key') && !empty(&key)
    "   let l:s.= get(g:statusline.symbols, 'key', '')
    " endif
  endif

  " Cursor position
  " let l:s.= ' %-12.(%l,%c%V%)'
  " <line>,<column>/<total>
  let l:s.= ' %-12.(%l,%c%V/%L%)'

  " File position
  let l:s.= ' %P '

  return l:s
endfunction

function! StatuslineMode(mode)
  let l:mode = get(g:statusline.modes, a:mode, '------')

  " If the window is active and has &paste
  if a:mode && &paste
    let l:mode.= ' ' . g:statusline.symbols.paste
  endif

  return l:mode
endfunction

function! StatuslineFlags()
  let l:flags = []

  " Note: gundo, help and vim-plug set &buftype to 'nofile'
  "   %w,%W -> [Preview],PRV
  "   %a -> Argument list status if > 1
  "   %T,%X <N> -> 'tabline'

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

" Solarized Statusline Colors:
" Red: 1
" Green: 2
" Yellow: 3
" Blue: 4
" Magenta: 5
" Cyan: 6
" Brightred: 9
function! StatuslineColors()
  if &background == 'dark'
    highlight Statusline term=reverse cterm=reverse ctermfg=14 ctermbg=0 gui=bold,reverse
    highlight StatuslineNC term=reverse cterm=reverse ctermfg=11 ctermbg=0 gui=reverse

    " highlight Statusline term=none cterm=none ctermfg=14 ctermbg=0 gui=bold
    " highlight StatuslineNC term=none cterm=none ctermfg=11 ctermbg=0 gui=none

    highlight StatuslineInsert ctermfg=0 ctermbg=2
    highlight StatuslineReplace ctermfg=0 ctermbg=1
  else
    highlight Statusline term=reverse cterm=reverse ctermfg=10 ctermbg=7 gui=bold,reverse
    highlight StatuslineNC term=reverse cterm=reverse ctermfg=12 ctermbg=7 gui=reverse

    " highlight Statusline term=none cterm=none ctermfg=10 ctermbg=7 gui=bold
    " highlight StatuslineNC term=none cterm=none ctermfg=12 ctermbg=7 gui=none

    highlight StatuslineInsert ctermfg=7 ctermbg=2
    highlight StatuslineReplace ctermfg=7 ctermbg=1
  endif

  " highlight link StatuslineWarning WarningMsg
  highlight StatuslineWarning term=reverse cterm=reverse ctermfg=1 guifg=Red
endfunction

function! StatuslineHighlight(mode)
  if a:mode == 'i'
    highlight! link Statusline StatuslineInsert
  elseif a:mode == 'r'
    highlight! link Statusline StatuslineReplace
  else
    echom 'MODE: ' . a:mode
    " highlight link Statusline NONE
  endif
endfunction

function! StatuslineBuild()
  for nr in range(1, winnr('$'))
    call setwinvar(nr, '&statusline', '%!Statusline(' . nr . ')')
  endfor
endfunction

" set statusline=%!Statusline(winnr())
" set noshowmode

augroup Statusline
  autocmd!
  " Create the highlight groups on startup and when the colorscheme changes
  autocmd VimEnter,ColorScheme * call StatuslineColors() | redrawstatus
  " Update the statusline function (setlocal statusline=%!)
  autocmd BufAdd,BufEnter,WinEnter * call StatuslineBuild()
  " Update the statusline highlight group
  autocmd InsertEnter * call StatuslineHighlight(v:insertmode)
  autocmd InsertChange * call StatuslineHighlight(v:insertmode)
  " Clear highlight link
  autocmd InsertLeave * highlight link Statusline NONE
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
