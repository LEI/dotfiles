" Handle Jinja2 extensions
if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" Apply the jinja syntax on an existing filetype
function! JinjaFiletype()
  " Get the second extension
  let s:ext = substitute(expand('%:t:r'), '^.*\.', '', '')
  if strlen(s:ext) > 0 && &filetype != s:ext . '.jinja'
    " Load the main syntax
    let &filetype = s:ext . '.' . &filetype
    " Force jinja syntax plugin
    unlet b:current_syntax
    runtime syntax/jinja.vim
  endif
endfunction

" Must be called after BufNewFile,BufRead and model lines,
" so the filetype have a chance to be detected:
autocmd BufWinEnter *.jinja2,*.j2,*.jinja call JinjaFiletype()
" autocmd! BufNewFile,BufRead *.j2 let &l:filetype = (strlen(&l:filetype) > 0 ? &l:filetype . '.jinja' : 'jinja')
