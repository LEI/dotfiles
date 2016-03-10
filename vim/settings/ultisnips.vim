" UltiSnips

" Trigger configuration
"
" Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe
let g:UltiSnipsExpandTrigger = '<tab>'

" Some terminal emulators don't send <c-tab> to the running program
let g:UltiSnipsListSnippets = '<c-tab>'

" <c-b>?
let g:UltiSnipsJumpForwardTrigger = '<c-j>'
" <c-z>?
let g:UltiSnipsJumpBackwardTrigger = '<c-k>'

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit = 'vertical'
