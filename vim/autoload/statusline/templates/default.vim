let s:template = ['%<[%n] %f %h%m%r%=%-14.(%l,%c%V%) %P']

function statusline#templates#default#apply()
  return s:template
endfunction

