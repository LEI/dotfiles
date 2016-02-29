" Statusline
" vim: et sts=2 st=2 sw=2

if get(g:, 'loaded_statusline', 0) || v:version < 700 || &cp
  finish
endif
let g:loaded_statusline = 1

" Always show the status line
set laststatus=2

" Do not display current mode
set noshowmode

" Display incomplete commands
set showcmd

if has('autocmd') && !exists('#statusline')
  "if !has('gui_running')
    "au InsertEnter  * redraw!
    "au InsertChange * redraw!
    "au InsertLeave  * redraw!
    "au InsertLeave * call SetStatusLine()
    "call setwinvar(statusline#set()
    "au WinEnter * exec 'hi StatusLineBG '.g:statusline#style.dark
    "au WinLeave * hi clear StatusLineBG
  "endif

  "autocmd ColorScheme,VimEnter * call SetStatusLine()

  " BufWinEnter/Leave?
  "au BufEnter,WinEnter * let w:statusline_active = 1
  "au BufLeave,WinLeave * let w:statusline_active = 0

  augroup statusline
    "autocmd InsertLeave * call statusline#set()
    "autocmd VimResized * call statusline#set()
    autocmd BufEnter,BufLeave,BufAdd,WinEnter,WinLeave * call statusline#set()
    "autocmd BufWinEnter,BufWinLeave * call statusline#set()

    autocmd CmdwinEnter,CmdwinLeave * call statusline#set()
    " getcmdwintype()
    " The character used for the pattern indicates the type of command-line:
    "  :: normal Ex command
    "  >: debug mode command |debug-mode|
    "  /: forward search string
    "  ?: backward search string
    "  =: expression for "= |expr-register|
    "  @: string for |input()|
    "  -: text for |:insert| or |:append|

    "autocmd TabEnter * echom "TabEntered"
    "autocmd TabLeave * echom "TabLeaved"
  augroup END
endif
