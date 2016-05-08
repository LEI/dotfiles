" Vim statusline

set statusline=%!StatusLine()

function! StatusLine()
  let l:s = ''

  let l:s.=' %n'
  let l:s.='%<'
  let l:s.= ' %f'
  " let l:s.= '%h%m%r'
  let l:s.= '%( [%H%R%M]%)'

  let l:s.='%='
  " let l:s.=' %{&ft} '
  let l:s.='%-12.(%l,%c%V%)'
  let l:s.=' %P '

  return l:s
endfunction

" Red: 1
" Green: 2
" Yellow: 3
" Blue: 4
" Magenta: 5
" Cyan: 6
" Brightred: 9

" highlight link StatusLine StatusLineInsert
highlight StatusLineInsert ctermfg=7 ctermbg=9 gui=bold

augroup StatusLine
  autocmd!
  autocmd InsertEnter * highlight! link StatusLine StatusLineInsert
  autocmd InsertLeave * highlight link StatusLine NONE
  " autocmd InsertEnter * highlight StatusLine ctermfg=9
  " autocmd InsertLeave * highlight StatusLine term=reverse cterm=reverse ctermfg=10 ctermbg=7 gui=bold,reverse
  " StatusLineNC fg=12 bg=7
augroup END
