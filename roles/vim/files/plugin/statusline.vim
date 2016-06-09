" Vim statusline plugin

" https://github.com/itchyny/lightline.vim
" https://github.com/tpope/vim-flagship
" https://github.com/vim-airline/vim-airline
" https://gist.github.com/suderman/1229444
" https://github.com/millermedeiros/vim-statline

if &compatible || get(g:, 'loaded_statusline', 0)
  finish
endif
let g:loaded_statusline = 1

" Variables: {{{1

if !exists('g:statusline')
  let g:statusline = {}
endif

call extend(g:statusline, {'modes': {}, 'symbols': {}, 'states': {}, 'items': []}, 'keep')

" Modes {{{2

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

" Symbols {{{2

" https://github.com/ryanoasis/nerd-fonts
" TODO: sign-define?
call extend(g:statusline.symbols, {
      \   'branch': nr2char(0xE0A0) . ' ',
      \   'key': nr2char(0x1F511) . ' ',
      \   'separator': nr2char(0x2502),
      \ }, 'keep')
" Branch: system('uname -s')[:5] ==? 'Darwin' ? nr2char(0x2387) . ' ' : ''
" Close: nr2char(0x2715)
" Lock: nr2char(0x1F512)
" |- nr2char(0x251C)

" States {{{2

" Default statusline:
" %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

call extend(g:statusline.states, {
      \ 'default': ['mode', '%<%{exists("w:statusline_title") ? w:statusline_title . " " : ""}', 'file', 'branch', 'flags', '%=', 'filetype', 'ruler', 'warnings', 'errors'],
      \ 'help': [' HELP ', '|', '%<', 'file', '%=', 'ruler'],
      \ 'commandline': ['mode', '%<', 'buffer', 'flags', '%=', 'ruler'],
      \ 'quickfix': ['quickfix', '|', '%<', 'quickfix_title', '%=', 'filetype', 'ruler'],
      \ 'netrw': ['%<', 'file', 'branch', '%=', 'netrw', 'ruler'],
      \ 'gundo': ['buffer', '%=', 'filetype', 'ruler'],
      \ 'plug': ['buffer', '%=', 'filetype', 'ruler'],
      \ 'scratch': ['mode', '%<', 'buffer', 'flags', '%=', 'ruler'],
      \ }, 'keep')

" Items {{{2

" Format markers:
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

let g:statusline.items = {
      \   'mode': {
      \     'string': '%{g:statusline.active() ? get(g:statusline.modes, mode(), mode()) . (&paste ? " PASTE" : "") : "------"}',
      \     'surround': ' ',
      \     'suffix': '|',
      \     'minwidth': 20,
      \   },
      \   'buffer': {
      \     'string': '%{g:statusline.bufname(expand("%"))}',
      \     'surround': ' ',
      \   },
      \   'quickfix': {
      \     'function': 'StatuslineQuickfix',
      \     'surround': ' ',
      \   },
      \   'quickfix_title': {
      \     'string': '%{exists("w:quickfix_title") ? w:quickfix_title : ""}',
      \     'surround': ' ',
      \   },
      \   'file': {
      \     'string': '%f',
      \     'surround': ' ',
      \   },
      \   'branch': {
      \     'string': '%{exists("*fugitive#head") ? fugitive#head(7) : ""}',
      \     'surround': '[',
      \     'minwidth': 60,
      \   },
      \   'flags': {
      \     'string': '%{StatuslineFlags()}',
      \     'surround': '[',
      \   },
      \   'warnings': {
      \     'string': '%{StatuslineIndent()}%{StatuslineTrailing()}',
      \     'surround': ' ',
      \     'highlight': 'WarningMsg',
      \   },
      \   'errors': {
      \     'string': '%{StatuslineErrors()}',
      \     'surround': ' ',
      \     'highlight': 'ErrorMsg',
      \   },
      \   'fileinfo': {
      \     'string': '%{&fileformat}[%{strlen(&fileencoding) ? &fileencoding : &encoding}%{exists("+bomb") && &bomb ? ",B" : ""}]',
      \     'surround': ' ',
      \     'suffix': '|',
      \     'minwidth': 100
      \   },
      \   'filetype': {
      \     'string': '%{strlen(&filetype) ? &filetype : "no ft"}',
      \     'surround': ' ',
      \     'suffix': '|',
      \     'minwidth': 80,
      \   },
      \   'netrw': {
      \     'string': '%{g:netrw_sort_by}[%{(g:netrw_sort_direction =~ "n") ? "+" : "-"}]',
      \     'surround': ' ',
      \     'suffix': '|',
      \     'minwidth': 80,
      \   },
      \   'ruler': {
      \     'string': &ruler ? strlen(&rulerformat) ? &rulerformat : '%-14.(%l,%c%V/%L%)%4.( %P%)' : '',
      \     'surround': ' ',
      \     'minwidth': 40,
      \   },
      \   '|': get(g:statusline.symbols, 'separator'),
      \ }

" Functions: {{{1
"
" Flags {{{2

function! StatuslineFlags() abort
  let l:flags = []

  " elseif &buftype != 'nofile' && &filetype !~ 'help\|vim-plug' " netrw, qf...
  if &buftype ==# 'help'
    call add(l:flags, 'H')
  else
    if &previewwindow
      call add(l:flags, 'PRV')
    endif
    if &readonly
      call add(l:flags, 'RO')
    endif
    if &modified
      call add(l:flags, '+')
    elseif !&modifiable
      call add(l:flags, '-')
    endif
  endif

  return join(l:flags, ',')
endfunction

" Quickfix {{{2

function StatuslineQuickfix() abort
  let l:title = '%f'

  if len(getloclist(0))
    let l:title = 'Location List'
  elseif len(getqflist()) >= 0
    let l:title = 'Quickfix List'
  endif

  return l:title
endfunction

" Errors {{{2

function StatuslineErrors() abort
  let l:str = ''

  if exists('*neomake#Make')
    let l:str = neomake#statusline#QflistStatus('qf: ')
    let l:str.= neomake#statusline#LoclistStatus()
  elseif exists('g:loaded_syntastic_plugin')
    let l:str = SyntasticStatuslineFlag()
  endif

  return l:str
endfunction

" Whitespace {{{2

function! StatuslineIndent()
  if !exists('b:statusline_indent')
    let b:statusline_indent = ''
    if !&modifiable
      return b:statusline_indent
    endif
    let l:tabs = search('^\t', 'nw') != 0
    " Find spaces that arent used as alignment in the first indent column
    let l:spaces = search('^ \{' . &tabstop . ',}[^\t]', 'nw') != 0
    if l:tabs && l:spaces
      " Spaces and tabs are used to indent
      let b:statusline_indent = 'mixed'
    elseif (l:spaces && !&expandtab) || (l:tabs && &expandtab)
      " 'expandtab' option is set wrong
      let b:statusline_indent = '&et'
    endif
  endif
  return b:statusline_indent
endfunction

function! StatuslineTrailing()
  if !exists('b:statusline_trailing')
    if search('\s\+$', 'nw') != 0
      let b:statusline_trailing = '[\s]'
    else
      let b:statusline_trailing = ''
    endif
  endif
  return b:statusline_trailing
endfunction

" Helpers {{{2

function! g:statusline.apply(...) abort dict
  " let self.current = winnr()
  " if !empty(&l:statusline)
  "   echom 'Existing local statusline: ' . &l:stl
  " endif
  let l:items = a:0 ? get(g:statusline.states, a:1, []) : []
  let &l:statusline = self.build(l:items)
endfunction

function! g:statusline.active() abort dict
  if !exists('self.current_winnr')
    let self.current_winnr = winnr()
  endif

  return winnr() == self.current_winnr
endfunction

" Highlight {{{2

function! g:statusline.colors() abort dict
  " Initialize colors
  if &background ==# 'dark'
    highlight StatusLineInsert ctermfg=0 ctermbg=2
    highlight StatusLineReplace ctermfg=0 ctermbg=9
  else
    highlight StatusLineInsert ctermfg=7 ctermbg=2
    highlight StatusLineReplace ctermfg=7 ctermbg=9
  endif
endfunction

function! g:statusline.highlight(...) abort dict
  let l:mode = a:0 ? a:1 : ''

  if l:mode ==# 'i'
    " Insert mode
    highlight! link StatusLine StatusLineInsert
  elseif l:mode ==# 'r'
    " Replace mode
    highlight! link StatusLine StatusLineReplace
  elseif l:mode ==# 'v'
    " Virtual replace mode
    highlight! link StatusLine StatusLineReplace
  elseif strlen(l:mode) > 0
    echoerr 'Unknown mode: ' . l:mode
  else
    highlight link StatusLine NONE
  endif
endfunction

" Build {{{2

function! g:statusline.build(...) abort dict
  " echom "STL " . strftime('%H:%M:%S')
  " let stl = a:0 ? a:1 : get(b:, 'statusline', get(w:, 'statusline_map', {}))
  " call extend(stl, self.components, 'keep')
  let l:line = ''
  let l:items = a:0 && len(a:1) ? a:1 : g:statusline.states.default
  " let items = a:0 && len(a:1) ? a:1 : self.default
  " let items = a:0 && len(a:1) ? a:1 : range(0, len(self.items) - 1)
  for l:key in l:items
    if has_key(g:statusline.items, l:key)
      let l:item = g:statusline.items[l:key]
      if type(l:item) == type({}) && has_key(l:item, 'function')
        let l:item.string = {l:item.function}()
      endif
      if type(l:item) == type('')
        if strlen(l:item)
          let l:line.= l:item
        endif
      elseif type(l:item) == type({}) && has_key(l:item, 'string')
        if strlen(l:item.string)
          let l:str = statusline#parse(l:item.string)
          if strlen(l:str)
            let l:str = statusline#truncate(l:str, get(l:item, 'minwidth', 0))
            let l:str = statusline#surround(l:str, get(l:item, 'surround', ''))
            let l:str = statusline#symbol(l:item, 'prefix') . l:str . statusline#symbol(l:item, 'suffix')
            let l:str = statusline#wrap(l:str, get(l:item, 'wrap', 1))
            let l:str = statusline#highlight(l:str, get(l:item, 'highlight', ''))
            let l:line.= l:str
          endif
        endif
      else
        " echo l:item
        echoerr 'Invalid item: ' . l:key
      endif
    elseif strlen(l:key)
      let l:line.= l:key
      continue
    else
      echoerr 'Invalid key: ' . l:key
      continue
    endif
    unlet l:item
  endfor

  return l:line
endfunction

" Format buffer name
function! g:statusline.bufname(string) abort dict
  let l:name = a:string

  let l:brackets_pattern = '\[\([^\]]\+\)\]'
  " __Gundo_Preview__ ...
  let l:underscores_pattern = '__\(\w\+\)__'
  if l:name =~ l:brackets_pattern
    " Remove surrounding brackets
    " Uppercase matched string: \U\1\E
    let l:name = substitute(l:name, l:brackets_pattern, '\1', '')
  elseif l:name =~ l:underscores_pattern
    let l:name = substitute(l:name, l:underscores_pattern, '\1', '')
    let l:name = substitute(l:name, '_', ' ', 'g')
  endif

  return l:name
endfunction

" Auto Commands {{{1
" TODO doautocmd User?

" for nr in winnr('$') call setwinvar(nr, '&stl', stl)
" autocmd VimEnter * call statusline.apply() " | redrawstatus
" autocmd VimResized * redrawstatus

augroup StatuslineBuffer
  autocmd!
  " Update current window number
  autocmd BufAdd,BufEnter,WinEnter * let g:statusline.current_winnr = winnr()
  " Redraw directly after saving
  autocmd BufWritePost * redrawstatus
  " Update whitespace warnings
  autocmd BufWritePost,CursorHold * unlet! b:statusline_trailing | unlet! b:statusline_indent
augroup END

augroup StatuslineType
  autocmd!
  " Override the statusline components according to the context
  autocmd CmdWinEnter * let g:statusline.current_winnr = winnr()
        \ | call statusline.apply('commandline')
  autocmd CmdWinLeave * let g:statusline.current_winnr = winnr('#')
  "  QuickFixCmdPre, QuickFixCmdPost / BufReadPost quickfix (works in nvim)
  " autocmd BufReadPost quickfix call statusline.apply('quickfix')
  autocmd FileType qf call statusline.apply('quickfix')
  " Help buffer
  autocmd FileType help call statusline.apply('help')
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
