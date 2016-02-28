" Utils
" vim: et st=2 sts=2 sw=2

function statusline#utils#define(variable, default)
  if !exists(a:variable)
    let {a:variable} = a:default
  endif
endfunction

function statusline#utils#minwidth(minwidth)
  if a:minwidth > 0 && winwidth(0) < a:minwidth
    let l:r = 0
  else
    let l:r = 1
  endif

  return l:r
endfunction

" Apply style to status line highlight group
function statusline#utils#highlight(group, style)
  exec 'hi StatusLine'.a:group.' '.a:style
endfunction

function statusline#utils#truncate(text, minwidth)
  if a:minwidth > 0 && winwidth(0) < a:minwidth
    return ''
  endif
  return a:text
endfunction

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
