" Background

" TODO tz?
function! s:isDayTime(...)
  let l:sunrise = a:0 > 0 ? a:1 : 7
  let l:sunset = a:0 > 1 ? a:2 : 20
  let l:hour = strftime('%H')
  return l:hour > l:sunrise && l:hour < l:sunset
endfunction

function! background#set()
  if !exists('*strftime')
    let l:background = has('gui_running') ? 'light' : 'dark'
  elseif s:isDayTime()
    let l:background = 'light'
  else
    let l:background = 'dark'
  endif
  if &background != l:background
    let &background = l:background
  endif
endfunction
