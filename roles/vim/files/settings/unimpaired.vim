" Unimpaired

" AZERTY
for s:c in map(range(65,90) + range(97,122),'nr2char(v:val)')
  exec 'nmap ('.s:c.' ['.s:c
  exec 'xmap ('.s:c.' ['.s:c
  exec 'nmap )'.s:c.' ]'.s:c
  exec 'xmap )'.s:c.' ]'.s:c
endfor

" Vimcast #26: Bubbling text

" Single lines
nmap <C-Up> [e
nmap <C-Down> ]e
" Multiple lines
vmap <C-Up> [egv
vmap <C-Down> ]egv
