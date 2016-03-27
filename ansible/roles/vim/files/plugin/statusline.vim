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
    autocmd!

    " Redraw the status line of the current window
    autocmd InsertLeave * redrawstatus
    "autocmd InsertLeave * call statusline#update()
    "autocmd BufWinEnter,BufWinLeave * call statusline#update()

    autocmd BufAdd,BufEnter,WinEnter * call statusline#update()
    "autocmd BufLeave,WinLeave * call statusline#update(1)
    "autocmd WinEnter,BufWinEnter,FileType,ColorScheme,SessionLoadPost * call statusline#update()

    "autocmd TabEnter * echom 'TabEnter'
    "autocmd TabLeave * echom 'TabLeave'
    "autocmd VimResized * call statusline#update()

    autocmd ColorScheme * call statusline#colorscheme()
    "autocmd VimEnter * call statusline#template()

    " autocmd CmdwinEnter * let &l:statusline=' %#StatusLineMode#%{statusline#core#mode("cl")} %#StatusLineNC# %<COMMAND LINE %h%m%r %#StatusLineNC#%=%5.(%p%%%)%4.(%l%):%-4.(%c%V%)'
    autocmd CmdwinEnter * call statusline#update()
    autocmd CmdwinLeave * call statusline#update(winnr() - 1)

    "autocmd CmdwinEnter * call statusline#update({ 'branch': 0, 'encoding': 0, 'format': 0 })
    "autocmd CmdwinLeave * call statusline#unset()

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
