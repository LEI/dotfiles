" Vim statusline

" https://github.com/itchyny/lightline.vim
" https://github.com/tpope/vim-flagship
" https://github.com/vim-airline/vim-airline

if get(g:, 'loaded_statusline', 0)
  finish
endif
let g:loaded_statusline = 1

if !exists('g:statusline')
  let g:statusline = {}
endif

call extend(g:statusline, { 'modes': {}, 'symbols': {}, 'components': {}, 'items': [
      \   {'key': 'mode', 'surround': 'separator', 'minwidth': 20},
      \   {'key': 'branch', 'surround': 'separator', 'minwidth': 60},
      \   'buffer',
      \   {'key': 'flags', 'surround': [' [', ']']},
      \   '%=',
      \   {'key': 'errors', 'surround': ' ', 'highlight': 'ErrorMsg'},
      \   {'key': 'fileinfo', 'surround': 'separator', 'minwidth': 80},
      \   {'key': 'filetype', 'surround': 'separator', 'minwidth': 60},
      \   {'key': 'ruler', 'surround': ' ', 'minwidth': 40},
      \ ] }, 'keep')

" Mode Map:
" n       Normal
" no      Operator-pending
" v       Visual by character
" V       Visual by line
" CTRL-V  Visual blockwise
" s       Select by character
" S       Select by line
" CTRL-S  Select blockwise
" i       Insert
" R       Replace |R|
" Rv      Virtual Replace |gR|
" c       Command-line
" cv      Vim Ex mode |gQ|
" ce      Normal Ex mode |Q|
" r       Hit-enter prompt
" rm      The -- more -- prompt
" r?      A confirm query of some sort
" !       Shell or external command is executing
call extend(g:statusline.modes, {
      \   'n': 'NORMAL',
      \   'i': 'INSERT',
      \   'R': 'REPLACE',
      \   'v': 'VISUAL',
      \   'V': 'V-LINE',
      \   'c': 'COMMAND',
      \   '': 'V-BLOCK',
      \   's': 'SELECT',
      \   'S': 'S-LINE',
      \   '': 'S-BLOCK',
      \ }, 'keep')

" Branch: system('uname -s')[:5] ==? 'Darwin' ? nr2char(0x2387) . ' ' : ''
" Close: nr2char(0x2715)
" Lock: nr2char(0x1F512)
" nr2char(0x251C)
call extend(g:statusline.symbols, {
      \   'key': nr2char(0x1F511) . ' ',
      \   'separator': nr2char(0x2502),
      \ }, 'keep')

" Format Markers:
" %< Where to truncate line if too long
" %n Buffer number
" %F Full path to the file in the buffed
" %f Relative path or as typed
" %t File name (tail)
" %m Modified flag [+] (modified), [-] (unmodifiable) or nothing
" %r Readonly flag [RO]
" %w Preview window flag
" %y Filetype [ruby]
" %= Separation point between left and right aligned items
" %l Current line number
" %L Number of lines in buffer
" %c Current column number
" %V Current virtual column number (-n), if different from %c
" %P Percentage through file of displayed window
" %( Start of item group (%-35. width and alignement of a section)
" %) End of item group

function! StatuslineFlags()
  " TODO PRV
  let flags = []
  if &buftype == 'help'
    call add(flags, 'H')
  elseif &buftype != 'nofile' && &filetype !~ 'help\|netrw\|qf\|vim-plug'
    if &readonly
      call add(flags, g:statusline.symbols.readonly)
    endif
    if &modified
      call add(flags, '+')
    elseif !&modifiable
      call add(flags, '-')
    endif
  endif
  return join(flags, ',')
endfunction

" Default Statusline:
" %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
call extend(g:statusline.components, {
      \   'mode': '%{winnr() != winnr("#") ? get(g:statusline.modes, mode(), mode()) . (&paste ? " PASTE" : "") : "------"}',
      \   'branch': '%{exists("*fugitive#head") ? fugitive#head(7) : ""}',
      \   'buffer': '%< %f%{exists("w:quickfix_title") ? " " . w:quickfix_title : ""}',
      \   'flags': function('StatuslineFlags'),
      \   'errors': '%{exists("g:loaded_syntastic_plugin") ? SyntasticStatuslineFlag() : ""}',
      \   'fileinfo': '%{&fileformat}[%{&fenc!="" ? &fenc : &enc}%{exists("+bomb") && &bomb ? ",B" : ""}]',
      \   'filetype': '%{&filetype!="" ? &filetype : "no ft"}',
      \   'ruler': &ruler ? &rulerformat ? &rulerformat : '%-14.(%l,%c%V/%L%) %P' : '',
      \ }, 'keep')

let g:statusline.commandline = {'branch': 0, 'fileinfo': 0, 'filetype': 0}
let g:statusline.quickfix = {'mode': 0, 'flags': 0, 'fileinfo': 0, 'filetype': 0}
" let g:statusline.commandline = {'branch': 0, 'fileinfo': 0, 'filetype': 0}
" let g:statusline.quickfix = {'mode': 0, 'buffer': '%t%{exists("w:quickfix_title") ? " " . w:quickfix_title : ""}', 'flags': 0, 'fileinfo': 0, 'filetype': 0}

" Normal Buffer: WinEnter,BufEnter,BufAdd
" autocmd BufWinEnter * if &filetype!~'qf' | setlocal statusline=%!Statusline() | endif
" Quickfix Location List: QuickFixCmdPre,QuickFixCmdPost / BufWinEnter quickfix
" %t%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''} %=%-15(%l,%c%V%) %P
" autocmd FileType qf let &l:statusline = '%!Statusline({"mode": 0, "branch": 0, "flags": 0, "title": " %f %{w:quickfix_title}"})'
" autocmd BufWinEnter quickfix let b:statusline = {'mode': 0,'title': '%t%f%{exists("w:quickfix_title") ? " ".w:quickfix_title : ""}'}
" Command Line Mode: CmdWinEnter,CmdWinLeave
" autocmd CmdWinEnter * let &l:statusline='%!Statusline({"branch": 0})'
augroup Statusline
  autocmd!
  " Create the highlight groups on startup and when the colorscheme changes
  autocmd VimEnter,ColorScheme * call StatuslineInit() "| redrawstatus
  " Adjust statusline according to the context
  autocmd CmdWinEnter * setlocal statusline=%!Statusline(g:statusline.commandline)
  autocmd FileType qf setlocal statusline=%!Statusline(g:statusline.quickfix)
  " autocmd CmdWinEnter * let b:statusline = g:statusline.commandline
  " autocmd FileType qf setlocal statusline=%!Statusline(g:statusline.quickfix)
  " TODO __Gundo*__
  " Change the statusline color and redraw faster
  autocmd InsertEnter * call StatuslineHighlight(v:insertmode)
  autocmd InsertChange * call StatuslineHighlight(v:insertmode)
  autocmd InsertLeave * call StatuslineHighlight() | redrawstatus
  autocmd BufWritePost * redrawstatus
augroup END

function! StatuslineInit() abort
  setglobal statusline=%!Statusline()
  if &laststatus == 1
    set laststatus=2
  endif
  if &background == 'dark'
    highlight StatusLineInsert ctermfg=0 ctermbg=2
    highlight StatusLineReplace ctermfg=0 ctermbg=9
  else
    highlight StatusLineInsert ctermfg=7 ctermbg=2
    highlight StatusLineReplace ctermfg=7 ctermbg=9
  endif
endfunction

function! StatuslineHighlight(...) abort
  let l:mode = a:0 ? a:1 : ''

  if l:mode == 'i'
    " insert mode
    highlight! link StatusLine StatusLineInsert
  elseif l:mode == 'r'
    " replace mode
    highlight! link StatusLine StatusLineReplace
  elseif l:mode == 'v'
    " virtual replace mode
    highlight! link StatusLine StatusLineReplace
  " elseif strlen(l:mode) > 0
  "   echom 'unknown mode: ' . l:mode
  else
    highlight link StatusLine NONE
  endif
endfunction

" TODO item list loop (s:show) [left, right]?
function! Statusline(...) abort
  " echom "STL " . strftime('%H:%M:%S')

  let stl = a:0 ? a:1 : get(b:, 'statusline', get(w:, 'statusline', {}))
  call extend(stl, g:statusline.components, 'keep')

  let line = ''
  for item in g:statusline.items
    let str = ''
    let surround = ''
    let highlight = ''

    if type(item) == type('')
      if has_key(stl, item)
        let str = s:parse(stl[item])
      else " if item =~ '^%'
        let line.= item
        continue
      endif
    " TODO type function('tr')
    elseif type(item) == type({})
      if has_key(item, 'minwidth') && winwidth(0) < item.minwidth
        continue
      elseif has_key(item, 'key') && has_key(stl, item.key)
        let str = s:parse(stl[item.key])
      endif
      if has_key(item, 'highlight')
        let highlight = item.highlight
      endif
      if has_key(item, 'surround')
        let surround = item.surround
      endif
      " if has_key(item, 'surround') && strlen(item.surround) > 0
      "   let surround = type(item.surround) == type(0) ? ' ' : item.surround
      " endif
    else
      echoerr 'Unknown type: ' . item
    endif

    if strlen(str)
      " TODO surround array [prefix, suffix]
      let match = {'[': ']', '{': '}', '(': ')', '<': '>', ',': ''}
      if len(surround) == 2
        let prefix = surround[0]
        let suffix = surround[1]
        let str = prefix . str . suffix
      elseif strlen(surround) > 0
        let prefix = has_key(match, surround) ? surround : ' '
        let suffix = get(match, surround, ' ' . get(g:statusline.symbols, surround, ''))
        let str = prefix . str . suffix
      endif
      let str = '%(' . str . '%)'
      if strlen(highlight) > 0
        let str = '%#' . highlight . '#' . str . '%*'
      endif

      let line.= str
    endif
  endfor

  return line
endfunction

function! s:parse(item)
  if type(a:item) == type(0) && a:item == 0
    return ''
  elseif type(a:item) == type('') && strlen(a:item) > 0
    return a:item
  elseif type(a:item) == type(function('tr'))
    return '%{' . string(a:item) . '()}'
  else
    echoerr 'Unkown type: ' . a:item
  endif
endfunction
