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
