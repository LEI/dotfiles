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
  call setwinvar(a:winnr, 'mode', a:winnr == winnr() ? mode() : v:false)

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
    " The name of the register in effect for the current normal mode
    " command (regardless of whether that command actually used a
    " register).  Or for the currently executing normal mode mapping
    " (use this in custom commands that take a register).
    " If none is supplied it is the default register '"', unless
    " 'clipboard' contains "unnamed" or "unnamedplus", then it is
    " '*' or '+'.
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
  " let l:file = expand('%:t')
  " " Cf. https://github.com/itchyny/lightline.vim
  " return l:file == '__Gundo__' ? 'Gundo' :
  "       \ l:file == '__Gundo_Preview__' ? 'Preview' :
  "       \ l:mode
endfunction

function! StatuslineFlags()
  let l:flags = []

  " Note: gundo, help and vim-plug set &buftype to 'nofile'
  "   %w,%W -> [Preview],PRV
  "   %a -> Argument list status if argv() > 1
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
    " highlight StatuslineInsert ctermfg=0 ctermbg=2
    " highlight StatuslineReplace ctermfg=13 ctermbg=1

    highlight Statusline term=reverse cterm=reverse ctermfg=14 ctermbg=0 gui=bold,reverse
    highlight StatuslineNC term=reverse cterm=reverse ctermfg=11 ctermbg=0 gui=reverse

    highlight StatuslineInsert ctermfg=0 ctermbg=2
    highlight StatuslineReplace ctermfg=0 ctermbg=1
  else
    " Base16 Solarized Light
    " StatusLine: term=bold,reverse ctermfg=8 ctermbg=7 guifg=#657b83 guibg=#93a1a1
    " StatusLineNC: term=reverse ctermfg=12 ctermbg=13 guifg=#839496 guibg=#eee8d5
    " highlight StatusLine term=bold,reverse ctermfg=15 ctermbg=7 guifg=#657b83 guibg=#93a1a1
    " highlight StatusLineNC term=reverse ctermfg=12 ctermbg=13 guifg=#839496 guibg=#eee8d5
    " highlight StatuslineInsert ctermfg=13 ctermbg=2
    " highlight StatuslineReplace ctermfg=13 ctermbg=1

    highlight Statusline term=reverse cterm=reverse ctermfg=10 ctermbg=7 gui=bold,reverse
    highlight StatuslineNC term=reverse cterm=reverse ctermfg=12 ctermbg=7 gui=reverse

    highlight StatuslineInsert ctermfg=7 ctermbg=2
    highlight StatuslineReplace ctermfg=7 ctermbg=1
  endif

  " highlight link StatuslineWarning WarningMsg
  highlight StatuslineWarning term=reverse cterm=reverse ctermfg=1 guifg=Red
endfunction

function! StatuslineHighlight(mode)
  if a:mode == 'i'
    " Insert mode
    highlight! link Statusline StatuslineInsert
  elseif a:mode == 'r'
    " Replace mode
    highlight! link Statusline StatuslineReplace
  elseif a:mode == 'v'
    " Virtual replace mode
    highlight! link Statusline StatuslineReplace
  " else
  "   echom 'MODE: ' . a:mode
  "   highlight link Statusline NONE
  endif
endfunction

" set statusline=%!Statusline(winnr())
" set noshowmode

" autocmd BufAdd,BufEnter,WinEnter * call StatuslineBuild()
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
  autocmd InsertLeave * highlight link Statusline NONE
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
