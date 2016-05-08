" Colorscheme

if exists('g:loaded_colorscheme')
  finish
endif

if !exists('g:colors_name')
  " echoerr 'Undefined variable g:colors_name'
  finish
endif

let g:loaded_colorscheme = 1

function! s:SetBackground(...)
  let l:sunrise = a:0 >= 1 ? a:1 : 7
  let l:sunset = a:0 >= 2 ? a:2 : 20

  let l:BG = &background
  let l:hour = strftime('%H')

  " Select a light background during the day and a dark one during the night
  if l:hour <= l:sunrise || l:hour >= l:sunset
    let l:newBG = 'dark'
  else
    let l:newBG = 'light'
  endif

  if l:BG != l:newBG
    let &background = l:newBG
  endif
endfunction

" Set the background option based on the time
call s:SetBackground()
let g:colors_name = 'solarized'

" Then apply the colorscheme
try
  " g:colors_name?
  exe 'colorscheme ' . g:colors_name
catch
  echoerr 'Could not load ' . g:colors_name
endtry
