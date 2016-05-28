" Status Line

" Variables: {{{1

" Default: %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
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

if !exists('g:statusline')
  let g:statusline = {}
endif

call extend(g:statusline, {'modes': {}, 'symbols': {}, 'types': {}, 'items': []}, 'keep')

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
      \   't': 'TERMINAL',
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

" Types: {{{2

call extend(g:statusline.types, {
      \ 'default': ['mode', 'branch', '%<', 'file', 'flags', '%=', 'errors', 'filetype', 'ruler'],
      \ 'commandline': ['mode', '%<', 'buffer', 'flags', '%=', 'ruler'],
      \ 'help': [' Help ', 'sep', '%<', 'file', '%=', 'ruler'],
      \ 'quickfix': ['quickfix', 'sep', '%<', '%{exists("w:quickfix_title") ? " " . w:quickfix_title : ""}', '%=', 'filetype', 'ruler'],
      \ 'netrw': [' Netrw ', 'sep', 'branch', '%<', ' %f ', '%=', 'netrw', 'ruler'],
      \ 'plug': ['buffer', '%<', '%=', 'filetype', 'ruler'],
      \ 'scratch': ['mode', '%<', 'buffer', 'flags', '%=', 'ruler'],
      \ 'gundo': ['buffer', '%=', 'ruler'],
      \ }, 'keep')

" Items: {{{2

let g:statusline.items = {
      \   'mode': {
      \     'string': '%{g:statusline.active() ? get(g:statusline.modes, mode(), mode()) . (&paste ? " PASTE" : "") : "------"}',
      \     'surround': ' ',
      \     'minwidth': 20,
      \     'suffix': 'separator'
      \   },
      \   'branch': {
      \     'string': '%{exists("*fugitive#head") ? fugitive#head(7) : ""}',
      \     'surround': ' ',
      \     'minwidth': 60,
      \     'suffix': 'separator'
      \   },
      \   'buffer': {
      \     'string': '%{g:statusline.bufname(expand("%"))}',
      \     'surround': ' ',
      \   },
      \   'file': {
      \     'string': '%f',
      \     'surround': ' ',
      \   },
      \   'flags': {
      \     'string': '%{StatuslineFlags()}',
      \     'surround': ['[', '] '],
      \   },
      \   'quickfix': {
      \     'function': 'StatuslineQuickfix',
      \     'surround': ' ',
      \   },
      \   'trailing': {
      \     'string': '',
      \     'surround': ' ',
      \     'highlight': 'WarnMsg'
      \   },
      \   'errors': {
      \     'string': '%{exists("g:loaded_syntastic_plugin") ? SyntasticStatuslineFlag() : ""}',
      \     'surround': ' ',
      \     'highlight': 'ErrorMsg'
      \   },
      \   'fileinfo': {'string': '%{&fileformat}[%{strlen(&fileencoding) ? &fileencoding : &encoding}%{exists("+bomb") && &bomb ? ",B" : ""}]', 'surround': ' ', 'minwidth': 100, 'suffix': 'separator'},
      \   'filetype': {
      \     'string': '%{strlen(&filetype) ? &filetype : "no ft"}',
      \     'surround': ' ',
      \     'minwidth': 80,
      \     'suffix': 'separator'
      \   },
      \   'netrw': {
      \     'string': '%{g:netrw_sort_by}[%{(g:netrw_sort_direction =~ "n") ? "+" : "-"}]',
      \     'surround': ' ',
      \     'minwidth': 80,
      \     'suffix': 'separator'
      \   },
      \   'ruler': {
      \     'string': &ruler ? strlen(&rulerformat) ? &rulerformat : '%-14.(%l,%c%V/%L%) %P' : '',
      \     'surround': ' ',
      \     'minwidth': 40
      \   },
      \   'sep': {
      \     'string': get(g:statusline.symbols, 'separator'),
      \   },
      \ }

" Functions: {{{1

function! StatuslineFlags() abort
  let flags = []

  " elseif &buftype != 'nofile' && &filetype !~ 'help\|vim-plug' " netrw, qf...
  if &buftype == 'help'
    call add(flags, 'H')
  else
    if &previewwindow
      call add(flags, 'PRV')
    endif
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

function StatuslineQuickfix() abort
  let title = '%f'

  if len(getloclist(0))
    let title = "Location List"
  elseif len(getqflist())
    let title = "Quickfix List"
  endif

  return title
endfunction

" Helpers {{{2

function! g:statusline.apply(...) abort dict
  " let self.current = winnr()
  " if !empty(&l:statusline)
  "   echom 'Existing local statusline: ' . &l:stl
  " endif
  let items = a:0 ? get(g:statusline.types, a:1, []) : []
  let &l:statusline = self.build(items)
endfunction

function! g:statusline.active() abort dict
  if !exists('self.current_winnr')
    let self.current_winnr = winnr()
  endif

  return winnr() == self.current_winnr
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
  " let stl = a:0 ? a:1 : get(b:, 'statusline', get(w:, 'statusline_map', {}))
  " call extend(stl, self.components, 'keep')
  let line = ''
  let items = a:0 && len(a:1) ? a:1 : g:statusline.types.default
  " let items = a:0 && len(a:1) ? a:1 : self.default
  " let items = a:0 && len(a:1) ? a:1 : range(0, len(self.items) - 1)
  for key in items
    if has_key(g:statusline.items, key)
      let item = g:statusline.items[key]
      if has_key(item, 'function')
        let item.string = {item.function}()
      endif
      if has_key(item, 'string') && strlen(item.string)
        let str = statusline#parse(item.string)
        if strlen(str)
          let str = statusline#truncate(str, get(item, 'minwidth', 0))
          let str = statusline#surround(str, get(item, 'surround', ''))
          let str = statusline#symbol(item, 'prefix') . str . statusline#symbol(item, 'suffix')
          let str = statusline#wrap(str, get(item, 'wrap', 1))
          let str = statusline#highlight(str, get(item, 'highlight', ''))
          let line.= str
        endif
      else
        echoerr 'Invalid item: ' . key
      endif
    elseif strlen(key)
      let line.= key
      continue
    else
      echoerr 'Invalid key: ' . key
      continue
    endif
    unlet item
  endfor

  return line
endfunction

" Format buffer name
function! g:statusline.bufname(string) abort dict
  let name = a:string

  let brackets_pattern = '\[\([^\]]\+\)\]'
  " __Gundo_Preview__ ...
  let underscores_pattern = '__\(\w\+\)__'
  if name =~ brackets_pattern
    " Remove surrounding brackets
    " Uppercase matched string: \U\1\E
    let name = substitute(name, brackets_pattern, '\1', '')
  elseif name =~ underscores_pattern
    let name = substitute(name, underscores_pattern, '\1', '')
    let name = substitute(name, '_', ' ', 'g')
  endif

  return name
endfunction

" Auto Commands {{{1
" TODO doautocmd User?

augroup StatuslineInit
  autocmd!
  " Build the default statusline once
  " for nr in winnr('$') call setwinvar(nr, '&stl', stl)
  " autocmd VimEnter * call statusline.apply() " | redrawstatus
  " Update current window number
  autocmd BufAdd,BufEnter,WinEnter * let g:statusline.current_winnr = winnr()
  " Redraw directly after saving
  autocmd BufWritePost * redrawstatus
  " autocmd VimResized * redrawstatus
augroup END

augroup StatuslineType
  autocmd!
  " Override the statusline components according to the context
  autocmd CmdWinEnter * let g:statusline.current_winnr = winnr()
        \ | call statusline.apply('commandline')
  autocmd CmdWinLeave * let g:statusline.current_winnr = winnr('#')
  " Help buffer
  autocmd FileType help call statusline.apply('help')
  "  QuickFixCmdPre, QuickFixCmdPost / BufReadPost quickfix
  autocmd FileType qf call statusline.apply('quickfix')
  " Netrw
  autocmd FileType netrw call statusline.apply('netrw')
  " Vim Plug
  autocmd FileType vim-plug call statusline.apply('plug')
  " g:ScratchBufferName
  autocmd BufNewFile __Scratch__ call statusline.apply('scratch')
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
