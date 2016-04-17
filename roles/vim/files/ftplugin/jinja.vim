" Handle Jinja2 extensions
if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" Apply the jinja syntax on an existing filetype
function! AddJinjaSyntax()
  let l:ft = ''
  let l:jinja_ft = 'jinja'

  if strlen(&filetype) > 0 && &filetype !~ l:jinja_ft
    " Register the filetype if it is not already set to jinja
    let l:ft = &filetype
  elseif &filetype == l:jinja_ft
    " Look for the last extension if the filetype is jinja
    let l:ft = substitute(expand('%:t:r'), '^.*\.', '', '')
  endif

  if strlen(l:ft) > 0
    let l:ft.= '.' . l:jinja_ft
    " Load the main syntax
    let &filetype = l:ft
    " Force jinja syntax
    unlet b:current_syntax
    runtime syntax/jinja.vim
  endif
endfunction

" Must be called after BufNewFile,BufRead and model lines,
" so the filetype have a chance to be detected
autocmd BufWinEnter *.jinja2,*.j2,*.jinja call AddJinjaSyntax()

" autocmd! BufNewFile,BufRead *.j2
" let &l:filetype = (strlen(&l:filetype) > 0 ? &l:filetype . '.jinja' : 'jinja')
