function statusline#utils#truncate(text, minwidth)
  if a:minwidth > 0 && winwidth(0) < a:minwidth
    return ''
  endif
  return a:text
endfunction

function statusline#utils#define(variable, default)
  if !exists(a:variable)
    let {a:variable} = a:default
  endif
endfunction

" github.com/LucHermitte/lh-vim-lib/blob/master/autoload/lh/askvim.vim
function! statusline#utils#exe(command) abort
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
