" Vim statusline

" https://github.com/itchyny/lightline.vim
" https://github.com/tpope/vim-flagship
" https://github.com/vim-airline/vim-airline
" https://gist.github.com/suderman/1229444

if get(g:, 'loaded_statusline', 0)
  finish
endif
let g:loaded_statusline = 1

" Variables: {{{1

if !exists('g:statusline')
  let g:statusline = {}
endif

call extend(g:statusline, {'modes': {}, 'symbols': {}, 'components': {}}, 'keep')

" Modes: {{{2

" n      Normal
" no     Operator-pending
" v      Visual by character
" V      Visual by line
" CTRL-V Visual blockwise
" s      Select by character
" S      Select by line
" CTRL-S Select blockwise
" i      Insert
" R      Replace |R|
" Rv     Virtual Replace |gR|
" c      Command-line
" cv     Vim Ex mode |gQ|
" ce     Normal Ex mode |Q|
" r      Hit-enter prompt
" rm     The -- more -- prompt
" r?     A confirm query of some sort
" !      Shell or external command is executing
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

" Symbols: {{{2

" https://github.com/ryanoasis/nerd-fonts
call extend(g:statusline.symbols, {
      \   'branch': nr2char(0xE0A0) . ' ',
      \   'key': nr2char(0x1F511) . ' ',
      \   'separator': nr2char(0x2502),
      \ }, 'keep')
" Branch: system('uname -s')[:5] ==? 'Darwin' ? nr2char(0x2387) . ' ' : ''
" Close: nr2char(0x2715)
" Lock: nr2char(0x1F512)
" |- nr2char(0x251C)

" Statusline: {{{2

" Default Format: %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
" %<    Where to truncate line if too long
" %n    Buffer number
" %F    Full path to the file in the buffed
" %f    Relative path or as typed
" %t    File name (tail)
" %m    Modified flag [+] (modified), [-] (unmodifiable) or nothing
" %r    Readonly flag [RO]
" %w    Preview window flag
" %y    Filetype [ruby]
" %=    Separation point between left and right aligned items
" %l    Current line number
" %L    Number of lines in buffer
" %c    Current column number
" %V    Current virtual column number (-n), if different from %c
" %P    Percentage through file of displayed window
" %(    Start of item group (%-35. width and alignement of a section)
" %)    End of item group

call extend(g:statusline.components, {
      \   'mode': '%{winnr() != winnr("#") ? get(g:statusline.modes, mode(), mode()) . (&paste ? " PASTE" : "") : "------"}',
      \   'branch': '%{exists("*fugitive#head") ? fugitive#head(7) : ""}',
      \   'buffer': '%f%{exists("w:quickfix_title") ? " " . w:quickfix_title : ""}',
      \   'flags': '%{StatuslineFlags()}',
      \   'errors': '%{exists("g:loaded_syntastic_plugin") ? SyntasticStatuslineFlag() : ""}',
      \   'fileinfo': '%{&fileformat}[%{strlen(&fenc) ? &fenc : &enc}%{exists("+bomb") && &bomb ? ",B" : ""}]',
      \   'filetype': '%{StatuslineFiletype()}',
      \   'ruler': &ruler ? &rulerformat ? &rulerformat : '%-14.(%l,%c%V/%L%) %P' : '',
      \ }, 'keep')

function! StatuslineFlags() abort
  let flags = []

  " TODO PRV
  if &buftype == 'help'
    call add(flags, 'H')
  elseif &buftype != 'nofile' && &filetype !~ 'help\|netrw\|vim-plug'
    if &readonly
      call add(flags, 'RO')
    endif
    if &modified
      call add(flags, '+')
    elseif !&modifiable
      call add(flags, '-')
    endif
  endif

  return join(flags, ',')
endfunction

function! StatuslineFiletype() abort
  if empty(&filetype)
    let ft = 'no ft'
  else
    let ft = &filetype
  endif

  if &filetype == 'netrw'
    let order = (g:netrw_sort_direction =~ 'n') ? '+' : '-'
    let ft.= '[' . g:netrw_sort_by . order . ']'
  endif

  return ft
endfunction

let s:items = []

let g:statusline.commandline = {'branch': 0, 'fileinfo': 0, 'filetype': 0}
let g:statusline.quickfix = {'mode': 0, 'flags': 0, 'fileinfo': 0}

function! g:statusline.add(item) abort dict
  call add(self.items, a:item)
endfunction

let g:statusline.items = []
call statusline.add({'key': 'mode', 'surround': ' ', 'minwidth': 20, 'suffix': 'separator'})
call statusline.add({'key': 'branch', 'surround': ' ', 'minwidth': 60, 'suffix': 'separator'})
call statusline.add({'key': 'buffer', 'surround': ['%< ', ' ']})
call statusline.add({'key': 'flags', 'surround': ['[', '] ']})
call statusline.add('%=')
call statusline.add({'key': 'errors', 'surround': ' ', 'highlight': 'ErrorMsg'})
" call statusline.add({'key': 'fileinfo', 'surround': ' ', 'minwidth': 100, 'suffix': 'separator'})
call statusline.add({'key': 'filetype', 'surround': ' ', 'minwidth': 80, 'suffix': 'separator'})
call statusline.add({'key': 'ruler', 'surround': ' ', 'minwidth': 40})

" Functions: {{{1

function! g:statusline.init() abort dict
  if &laststatus == 1
    set laststatus=2
  endif
  let &g:statusline = self.build()
  " setglobal statusline=%!StatuslineBuild()
endfunction

function! g:statusline.apply(...) abort dict
  if empty(&l:statusline)
    let map = a:0 ? get(self, a:1, a:1) : {}
    let &l:statusline = self.build(map)
  else
    echom 'Existing local statusline: ' . &l:stl
  endif
endfunction

" Highlight: {{{2

function! g:statusline.colors() abort dict
  " Initialize colors
  if &background == 'dark'
    highlight StatusLineInsert ctermfg=0 ctermbg=2
    highlight StatusLineReplace ctermfg=0 ctermbg=9
  else
    highlight StatusLineInsert ctermfg=7 ctermbg=2
    highlight StatusLineReplace ctermfg=7 ctermbg=9
  endif
endfunction

function! g:statusline.highlight(...) abort dict
  let l:mode = a:0 ? a:1 : ''

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

" Build: {{{2

function! g:statusline.build(...) abort dict
  " echom "STL " . strftime('%H:%M:%S')

  let stl = a:0 ? a:1 : get(b:, 'statusline', get(w:, 'statusline_map', {}))
  call extend(stl, self.components, 'keep')

  let line = ''
  for item in self.items
    let component = 0

    if type(item) == type('') && has_key(stl, item)
      " Component key
      let component = stl[item]
    elseif type(item) == type('') && strlen(item) > 0
      " Statusline string
      let line.= item
      unlet item
      continue
    elseif has_key(item, 'minwidth') && winwidth(0) < item.minwidth
      " Truncated if below minimum width
      unlet item
      continue
    elseif has_key(item, 'key') && has_key(stl, item.key)
      " Dictionnary with 'key'
      let component = stl[item.key]
    else
      " echoerr 'Invalid type: ' . item
      let component = item
    endif

    if strlen(component) > 0 && type(item) == type({})
      let str = s:parse(component)
      " echom 'Component ' . component . ': ' . str
      if strlen(str) > 0
        let str = s:surround(str, get(item, 'surround', ''))
        let str = s:symbol(item, 'prefix') . str . s:symbol(item, 'suffix')
        let str = s:wrap(str, get(item, 'wrap', 1))
        let str = s:highlight(str, get(item, 'highlight', ''))
        let line.= str
      endif
    else
      echoerr 'Invalid component: ' . component
    endif

    unlet item
  endfor

  return line
endfunction

" Utils: {{{2

function! s:parse(item) abort
  if type(a:item) == type(0) && a:item == 0
    " False
    return ''
  elseif type(a:item) == type('') && strlen(a:item) > 0
    " String
    return a:item
  elseif type(a:item) == type(function('tr'))
    " Function reference
    return '%{' . string(a:item) . '()}'
  else
    echoerr 'Unkown type: ' . a:item
    return a:item
  endif
endfunction

function! s:surround(string, ...) abort
  let str = a:string
  let surround = a:0 ? a:1 : ''

  if empty(surround)
    return str
  elseif type(surround) == type([]) && len(surround) == 2
    let str = surround[0] . str . surround[1]
  elseif strlen(surround) > 0
    let match = {'[': ']', '{': '}', '(': ')', '<': '>', ',': ''}
    let str = surround . str . get(match, surround, surround)
  endif

  return str
endfunction

function! s:symbol(dict, key) abort
  let s = get(a:dict, a:key, '')
  let s = get(g:statusline.symbols, s, s)

  return s
endfunction

function! s:wrap(string, ...) abort
  let wrap = a:0 ? a:1 : 0

  if wrap > 0
    " TODO width, align (%-35.)
    let str = '%(' . a:string . '%)'
  else
    let str = a:string
  endif

  return str
endfunction

function! s:highlight(string, ...) abort
  let group = a:0 ? a:1 : ''

  if strlen(group) > 0
    let str = '%#' . group . '#' . a:string . '%*'
  else
    let str = a:string
  endif

  return str
endfunction

" Auto Commands: {{{1

" TODO g:gundo_preview/tree_statusline, doautocmd User?

" Normal Buffer: WinEnter,BufEnter,BufAdd
" autocmd BufWinEnter * if &filetype!~'qf' | setlocal statusline=%!StatuslineBuild() | endif
  " autocmd CmdWinEnter * setlocal statusline=%!StatuslineBuild(g:statusline:statusline.commandline)
  " autocmd FileType qf setlocal statusline=%!StatuslineBuild(g:statusline.quickfix)
  " autocmd CmdWinEnter * let b:statusline = g:statusline.commandline
  " autocmd FileType qf setlocal statusline=%!StatuslineBuild(g:statusline.quickfix)
" Quickfix Location List: QuickFixCmdPre,QuickFixCmdPost / BufWinEnter quickfix
" %t%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''} %=%-15(%l,%c%V%) %P
" autocmd FileType qf let &l:statusline = '%!StatuslineBuild({"mode": 0, "branch": 0, "flags": 0, "title": " %f %{w:quickfix_title}"})'
" autocmd BufWinEnter quickfix let b:statusline = {'mode': 0,'title': '%t%f%{exists("w:quickfix_title") ? " ".w:quickfix_title : ""}'}
" Command Line Mode: CmdWinEnter,CmdWinLeave
" autocmd CmdWinEnter * let &l:statusline='%!StatuslineBuild({"branch": 0})'

augroup StatuslineMode
  autocmd!
  " Set global vim options once
  autocmd VimEnter * call statusline.init()
  " Build the full statusline on startup
  autocmd VimEnter * call statusline.apply() " | redrawstatus
  " FIXME update width checks when a new split is created or removed (not winwidth?)
  " for nr in winnr('$') call setwinvar(nr, '&stl', stl)
  autocmd VimResized * call statusline.apply() " | redrawstatus
  " Override the statusline components according to the context
  autocmd CmdWinEnter * call statusline.apply('commandline')
  autocmd FileType qf call statusline.apply('quickfix')
  " autocmd BufWritePost * redrawstatus
augroup END

augroup StatuslineHighlight
  autocmd!
  " Create the highlight groups on startup and when the colorscheme changes
  autocmd VimEnter,ColorScheme * call statusline.colors()
  " Update the highlight group in insert and replace modes
  autocmd InsertEnter * call statusline.highlight(v:insertmode)
  autocmd InsertChange * call statusline.highlight(v:insertmode)
  autocmd InsertLeave * call statusline.highlight() | redrawstatus
augroup END
