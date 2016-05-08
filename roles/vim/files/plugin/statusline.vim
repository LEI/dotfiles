" Vim statusline

set statusline=%!StatusLine()

function! StatusLine()
  let l:s = ''

  " TODO: fugitive

  " File
  let l:s.=' %n'
  let l:s.='%<'
  let l:s.= ' %f'

  " Flags
  " let l:s.= '%h%m%r'
  let l:s.= '%( '
  " expand('%') == 'gundo', &buftype == 'nofile'?
  if &filetype !~ 'help\|netrw\|vim-plug'
    " %R RO (readonly)
    " %M +,- (modifiable)
    let l:s.= '[%R%M]'
  elseif &filetype == 'help'
    " %h [Help]
    " %H HLP
    let l:s.= '[H]'
  endif
  let l:s.= '%)'

  " Break
  let l:s.='%='

  " File format
  let l:s.=' %{&fileformat}'
  " File encoding
  let l:s.=' [%{&fenc != "" ? &fenc : &enc}%{exists("+bomb") && &bomb ? ",B" : ""}]'

  " File type
  let l:s.=' %{&ft != "" ? &ft : "no ft"}'

  " Separator
  let l:s.=' '

  " Cursor position
  let l:s.=' %-12.(%l,%c%V%)'

  " File position
  let l:s.=' %P '

  " TODO: syntastic

  return l:s
endfunction

" Red: 1
" Green: 2
" Yellow: 3
" Blue: 4
" Magenta: 5
" Cyan: 6
" Brightred: 9

augroup StatusLine
  autocmd!
  autocmd VimEnter,ColorScheme * highlight StatusLineInsert ctermfg=7 ctermbg=9 gui=bold
  autocmd InsertEnter * highlight! link StatusLine StatusLineInsert
  autocmd InsertLeave * highlight link StatusLine NONE
  " autocmd InsertEnter * highlight StatusLine ctermfg=9
  " autocmd InsertLeave * highlight StatusLine term=reverse cterm=reverse ctermfg=10 ctermbg=7 gui=bold,reverse
  " StatusLineNC fg=12 bg=7
augroup END
