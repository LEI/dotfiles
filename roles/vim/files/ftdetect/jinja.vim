" Add syntax highlighting and append jinja filetype

function s:AddJinjaSyntax()
  let l:ft = &filetype
  let l:e = expand('%:r:e')

  " echom 'Detected filetype: ' . l:ft
  if strlen(l:e) > 0
    execute 'doautocmd BufRead *.' . l:e
    if strlen(l:ft) > 0
      let &filetype = l:ft . '.' . &ft
    endif
    let &filetype.= '.jinja'
    unlet b:current_syntax
    runtime syntax/jinja.vim " set ft=jinja
  endif
endfunction

" BufReadPost is too soon?
autocmd BufWinEnter *.jinja2,*.j2,*.jinja call <SID>AddJinjaSyntax()

" http://vim.wikia.com/wiki/Filetype.vim
" http://stackoverflow.com/a/8414460

" FILETYPE AFTER

" if exists('did_load_filetypes_userafter')
"   finish
" endif

" function! s:DetectMultipleFiletype()
"   let l:ft = &filetype
"   let l:ext = expand('%:e')
"   let l:second_ext = expand('%:r:e')
"   " let l:extension = substitute(expand('%:t:r'), '^.*\.', '', '')

"   echom l:second_ext
"   if strlen(l:second_ext) > 0
"     execute 'doautocmd BufRead *.' . l:second_ext
"     if strlen(l:ft) && strlen(&ft) > 0 && l:ft != &ft
"       let &filetype = &ft . '.' . l:ft
"       unlet b:current_syntax
"       execute 'runtime syntax/' . l:ft . '.vim'
"     endif
"   endif
" endfunction

" BufNewFile,BufRead
" augroup filetypedetect
"   autocmd! BufWinEnter *.*.* call <SID>DetectMultipleFiletype()
" augroup END

" FTPLUGIN

" " Handle Jinja2 extensions
" if exists('b:did_ftplugin')
"   finish
" endif
" let b:did_ftplugin = 1

" " Apply the jinja syntax on an existing filetype
" function! AddJinjaSyntax()
"   let l:ft = ''
"   let l:jinja_ft = 'jinja'

"   if strlen(&filetype) > 0 && &filetype !~ l:jinja_ft
"     " Register the filetype if it is not already set to jinja
"     let l:ft = &filetype
"   elseif &filetype == l:jinja_ft
"     " Look for the last extension if the filetype is jinja
"     let l:ft = substitute(expand('%:t:r'), '^.*\.', '', '')
"   endif

"   if strlen(l:ft) > 0
"     let l:ft.= '.' . l:jinja_ft
"     " Load the main syntax
"     let &filetype = l:ft
"     " Force jinja syntax
"     unlet b:current_syntax
"     runtime syntax/jinja.vim
"   endif
" endfunction

" " Must be called after BufNewFile,BufRead and model lines,
" " so the filetype have a chance to be detected
" "autocmd BufWinEnter *.jinja2,*.j2,*.jinja call AddJinjaSyntax()

" " autocmd! BufNewFile,BufRead *.j2
" " let &l:filetype = (strlen(&l:filetype) > 0 ? &l:filetype . '.jinja' : 'jinja')
