let s:template = ['%<[%n] %f %([%H%M%R] %)', '%=', '%-14.(%l,%c%V%) %P']

function statusline#templates#default#load()
  return s:template
endfunction

