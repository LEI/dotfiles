" Vim statusline

" https://github.com/itchyny/lightline.vim
" https://github.com/tpope/vim-flagship
" https://github.com/vim-airline/vim-airline

if get(g:, 'loaded_statusline', 0)
  finish
endif
let g:loaded_statusline = 1

" cpo?

if !exists('g:statusline')
  let g:statusline = {}
endif

call extend(g:statusline, {'modes': {}, 'symbols': {}, 'components': {}}, 'keep')

" Mode Map:
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

" Branch: system('uname -s')[:5] ==? 'Darwin' ? nr2char(0x2387) . ' ' : ''
" Close: nr2char(0x2715)
" Lock: nr2char(0x1F512)
" nr2char(0x251C)
call extend(g:statusline.symbols, {
      \   'key': nr2char(0x1F511) . ' ',
      \   'separator': nr2char(0x2502),
      \ }, 'keep')

" Format Markers:
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

" Default Statusline:
" %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
call extend(g:statusline.components, {
      \   'mode': '%{winnr() != winnr("#") ? get(g:statusline.modes, mode(), mode()) . (&paste ? " PASTE" : "") : "------"}',
      \   'branch': '%{exists("*fugitive#head") ? fugitive#head(7) : ""}',
      \   'buffer': '%f%{exists("w:quickfix_title") ? " " . w:quickfix_title : ""}',
      \   'flags': '%{StatuslineFlags()}',
      \   'errors': '%{exists("g:loaded_syntastic_plugin") ? SyntasticStatuslineFlag() : ""}',
      \   'fileinfo': '%{&fileformat}[%{&fenc!="" ? &fenc : &enc}%{exists("+bomb") && &bomb ? ",B" : ""}]',
      \   'filetype': '%{&filetype!="" ? &filetype : "no ft"}',
      \   'ruler': &ruler ? &rulerformat ? &rulerformat : '%-14.(%l,%c%V/%L%) %P' : '',
      \ }, 'keep')

function! StatuslineFlags() abort
  let flags = []

  " TODO PRV
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

let g:statusline.items = [
      \   {'key': 'mode', 'surround': ' ', 'minwidth': 20, 'suffix': 'separator'},
      \   {'key': 'branch', 'surround': ' ', 'minwidth': 60, 'suffix': 'separator'},
      \   {'key': 'buffer', 'surround': ['%< ', ' ']},
      \   {'key': 'flags', 'surround': ['[', '] ']},
      \   '%=',
      \   {'key': 'errors', 'surround': ' ', 'highlight': 'ErrorMsg'},
      \   {'key': 'fileinfo', 'surround': ' ', 'minwidth': 100, 'suffix': 'separator'},
      \   {'key': 'filetype', 'surround': ' ', 'minwidth': 80, 'suffix': 'separator'},
      \   {'key': 'ruler', 'surround': ' ', 'minwidth': 40},
      \ ]

let g:statusline.commandline = {'branch': 0, 'fileinfo': 0, 'filetype': 0}
let g:statusline.quickfix = {'mode': 0, 'flags': 0, 'fileinfo': 0, 'filetype': 0}

" Normal Buffer: WinEnter,BufEnter,BufAdd
" autocmd BufWinEnter * if &filetype!~'qf' | setlocal statusline=%!StatuslineBuild() | endif
  " autocmd CmdWinEnter * setlocal statusline=%!StatuslineBuild(g:statusline.commandline)
  " autocmd FileType qf setlocal statusline=%!StatuslineBuild(g:statusline.quickfix)
  " autocmd CmdWinEnter * let b:statusline = g:statusline.commandline
  " autocmd FileType qf setlocal statusline=%!StatuslineBuild(g:statusline.quickfix)
" Quickfix Location List: QuickFixCmdPre,QuickFixCmdPost / BufWinEnter quickfix
" %t%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''} %=%-15(%l,%c%V%) %P
" autocmd FileType qf let &l:statusline = '%!StatuslineBuild({"mode": 0, "branch": 0, "flags": 0, "title": " %f %{w:quickfix_title}"})'
" autocmd BufWinEnter quickfix let b:statusline = {'mode': 0,'title': '%t%f%{exists("w:quickfix_title") ? " ".w:quickfix_title : ""}'}
" Command Line Mode: CmdWinEnter,CmdWinLeave
" autocmd CmdWinEnter * let &l:statusline='%!StatuslineBuild({"branch": 0})'

" TODO doautocmd User
augroup Statusline
  autocmd!
  " Set global vim options
  autocmd VimEnter * call StatuslineInit()

  " Create the highlight groups on startup and when the colorscheme changes
  autocmd VimEnter,ColorScheme * call StatuslineColors()

  " Build the full statusline on startup and on resize
  " FIXME update width checks when a new split is created or removed (not winwidth?)
  autocmd VimEnter,VimResized * call StatuslineApply() " | redrawstatus

  " Override the displayed items according to the context
  autocmd CmdWinEnter * call StatuslineApply('commandline')
  autocmd FileType qf call StatuslineApply('quickfix')

  " Update the highlight group in insert and replace modes
  autocmd InsertEnter * call StatuslineHighlight(v:insertmode)
  autocmd InsertChange * call StatuslineHighlight(v:insertmode)
  autocmd InsertLeave * call StatuslineHighlight() " | redrawstatus

  " autocmd BufWritePost * redrawstatus
augroup END

" if exists('loaded_gundo')
" TODO g:gundo_preview/tree_statusline

function! StatuslineInit() abort
  let &statusline = StatuslineBuild()
  " setglobal statusline=%!StatuslineBuild()
  if &laststatus == 1
    set laststatus=2
  endif
endfunction

function! StatuslineColors() abort
  " Initialize colors
  if &background == 'dark'
    highlight StatusLineInsert ctermfg=0 ctermbg=2
    highlight StatusLineReplace ctermfg=0 ctermbg=9
  else
    highlight StatusLineInsert ctermfg=7 ctermbg=2
    highlight StatusLineReplace ctermfg=7 ctermbg=9
  endif
endfunction

function! StatuslineApply(...) abort
  let map = a:0 ? get(g:statusline, a:1, a:1) : {}
  let &l:statusline = StatuslineBuild(map)
endfunction

function! StatuslineHighlight(...) abort
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

function! StatuslineBuild(...) abort
  " echom "STL " . strftime('%H:%M:%S')

  let stl = a:0 ? a:1 : get(b:, 'statusline', get(w:, 'statusline', {}))
  call extend(stl, g:statusline.components, 'keep')

  let line = ''
  for item in g:statusline.items
    let str = ''
    let surround = ''
    let highlight = ''

    if type(item) == type('')
      " Look for component, otherwise return the string
      if has_key(stl, item)
        let str = s:parse(stl[item])
      else " if item =~ '^%'
        let line.= item
        continue
      endif
    " TODO type function('tr')
    elseif type(item) == type({})
      " Do not display component if the minimum width is reached
      if has_key(item, 'minwidth') && winwidth(0) < item.minwidth
        continue
      endif
      " Look for the component by its name, or use the item itself
      if has_key(item, 'key') && has_key(stl, item.key)
        let str = s:parse(stl[item.key])
      else
        let str = s:parse(item)
      endif
    else
      echoerr 'Invalid type: ' . item
    endif

    if strlen(str)
      " TM TPOPE
      let surround = get(item, 'surround', '')
      if type(surround) == type([]) && len(surround) == 2
        let str = surround[0] . str . surround[1]
      elseif strlen(surround) > 0
        let match = {'[': ']', '{': '}', '(': ')', '<': '>', ',': ''}
        let str = surround . str . get(match, surround, surround)
      endif

      let prefix = get(item, 'prefix', '')
      let prefix = get(g:statusline.symbols, prefix, prefix)
      let suffix = get(item, 'suffix', '')
      let suffix = get(g:statusline.symbols, suffix, suffix)
      let str = prefix . str . suffix

      " TODO width, align (%-35.)
      if get(item, 'wrap', 1)
        let str = '%(' . str . '%)'
      endif

      let highlight = get(item, 'highlight', '')
      if strlen(highlight) > 0
        let str = '%#' . highlight . '#' . str . '%*'
      endif

      let line.= str
    endif
  endfor

  return line
endfunction

function! s:parse(item) abort
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
