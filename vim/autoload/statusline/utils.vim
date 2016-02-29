" Utils
" vim: et st=2 sts=2 sw=2

" github.com/vim-airline/vim-airline/blob/master/autoload/airline/util.vim

function statusline#utils#define(variable, default)
  if !exists(a:variable)
    let {a:variable} = a:default
  endif
endfunction

if v:version >= 704
  function statusline#utils#getwinvar(winnr, key, default)
    return getwinvar(a:winnr, a:key, a:default)
  endfunction
else
  function statusline#utils#getwinvar(winnr, key, default)
    let winvals = getwinvar(a:winnr, '')
    return get(winvals, a:key, a:default)
  endfunction
endif

function statusline#utils#truncate(minwidth)
  if a:minwidth > 0 && winwidth(0) < a:minwidth
    return 1
  else
    return 0
  endif
endfunction

"function statusline#utils#truncate(text, minwidth)
"  if a:minwidth > 0 && winwidth(0) < a:minwidth
"    return ''
"  endif
"  return a:text
"endfunction

" github.com/LucHermitte/lh-vim-lib/blob/master/autoload/lh/askvim.vim
function statusline#utils#exe(command) abort
  let save_a = @a
  try
    silent! redir @a
    silent! exe a:command
    redir END
  finally
    " Always restore everything
    let res = @a
    let @a = save_a
  endtry
  return res
endfunction
