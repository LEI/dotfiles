" Markdown

" ~> github.com/tpope/vim-markdown
" au BufNewFile,BufReadPost *.md set filetype=markdown -> vim/ftdetect?

" Enable spellchecking
setlocal spell

" Automatically wrap at 80 characters
setlocal textwidth=80

" Indentation size (overriden by vim-sleuth!)
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4
