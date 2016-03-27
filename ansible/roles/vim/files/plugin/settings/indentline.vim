" Indent line

let g:indentLine_enabled = 1

" Modes in which text in the cursor line can be concealed (default: inc)
" n: Normal mode
" v: Visual mode
" i: Insert mode
" c: Command line editing, for 'incsearch'
let g:indentLine_concealcursor = ''

" Display concealed text (default: 2)
" 0: Text is shown normally
" 1: Each block of concealed text is replaced with one
"    character.  If the syntax item does not have a custom
"    replacement character defined (see |:syn-cchar|) the
"    character defined in 'listchars' is used (space)
" 2: Concealed text is completely hidden unless it has a
"    custom replacement character defined
" 3: Concealed text is completely hidden
let g:indentLine_conceallevel = 2

" Identation guide character (UTF-8: 00A6, 2506, or |)
let g:indentLine_char = nr2char(0x2502)

" Colors
let g:indentLine_color_term = 10
" GVim
"let g:indentLine_color_gui = '#A4E57E'
" none X terminal
"let g:indentLine_color_tty_light = 7 " (default: 4)
"let g:indentLine_color_dark = 1 " (default: 2)
