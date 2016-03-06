" Statusline
" vim: et sts=2 st=2 sw=2

if get(g:, 'loaded_statusline', 0) || v:version < 700 || &cp
  finish
endif
let g:loaded_statusline = 1

let s:save_cpo = &cpo
set cpo&vim

if has('autocmd') && !exists('#statusline')

  augroup statusline
    "autocmd InsertLeave * redraw "call statusline#set()
    "autocmd VimResized * call statusline#set()
    autocmd BufAdd,BufEnter,BufLeave,WinEnter,WinLeave * call statusline#set()
    "autocmd BufWinEnter,BufWinLeave * call statusline#set()
    "autocmd TabEnter * echom 'TabEnter'
    "autocmd TabLeave * echom 'TabLeave'

    autocmd CmdwinEnter * let &l:statusline=' %#StatusLineMode#%{statusline#core#mode()} %#StatusLineNC# %<COMMAND LINE %h%m%r %#StatusLineNC#%=%5.(%p%%%)%4.(%l%):%-4.(%c%V%)'
    "autocmd CmdwinEnter * call statusline#set({ 'branch': 0, 'encoding': 0, 'format': 0 })
    "autocmd CmdwinLeave * call statusline#unset()

    autocmd ColorScheme,VimEnter * call statusline#theme()
    autocmd VimEnter * call statusline#template()

    " getcmdwintype()
    " The character used for the pattern indicates the type of command-line:
    "  :: normal Ex command
    "  >: debug mode command |debug-mode|
    "  /: forward search string
    "  ?: backward search string
    "  =: expression for "= |expr-register|
    "  @: string for |input()|
    "  -: text for |:insert| or |:append|
  augroup END
endif

let &cpo = s:save_cpo
unlet s:save_cpo
