" Markdown

" au BufNewFile,BufReadPost *.md set filetype=markdown -> vim/ftdetect?
" Ident size                                           -> vim/indent?
" ~> github.com/tpope/vim-markdown

if exists("b:did_ftplugin")
  finish
endif

" Enable spellchecking
setlocal spell

" Automatically add line break at 80 characters
setlocal textwidth=80

" Indentation size
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4

let b:did_ftplugin=1
