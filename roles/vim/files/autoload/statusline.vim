function statusline#mode()
  return '%{winnr() == ' . winnr() . ' ? get(g:statusline.modes, mode(), mode()) . (&paste ? " PASTE" : "") : "------"}'
endfunction

function statusline#fugitive()
  return '%{exists("*fugitive#head") ? fugitive#head(7) : ""}'
endfunction

function statusline#flags()
  " let l.= s:wrap('%h%r%m')
  " let l:flags = []
  " if &buftype == 'help'
  "   call add(l:flags, 'H')
  " elseif &buftype != 'nofile' && &filetype !~ 'help\|netrw\|qf\|vim-plug'
  "   if &readonly
  "     call add(l:flags, g:statusline.symbols.readonly)
  "   endif
  "   if &modified
  "     call add(l:flags, '+')
  "   elseif !&modifiable
  "     call add(l:flags, '-')
  "   endif
  " endif
  return '[%H%R%M]'
endfunction

function statusline#filetype()
  return '%{&filetype!="" ? &filetype : "no ft"}'
endfunction

function statusline#fileinfo()
  let encoding = '%{&fenc!="" ? &fenc : &enc}'
  let encoding.= '%{exists("+bomb") && &bomb ? ",B" : ""}'

  return '%{&fileformat} [' . encoding . ']'
endfunction

function statusline#syntastic()
  return '%{exists("g:loaded_syntastic_plugin") ? SyntasticStatuslineFlag() : ""}'
endfunction

function statusline#ruler()
  if empty(&rulerformat)
    let &rulerformat = '%-14.(%l,%c%V/%L%) %P'
  endif

  return ' ' . &rulerformat
endfunction
