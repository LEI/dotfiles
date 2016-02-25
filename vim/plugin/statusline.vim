" Statusline

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

function s:render()
    setl statusline=%!statusline#render()
endfunction

if has("autocmd")
  if !has('gui_running')
    "au InsertEnter  * redraw!
    "au InsertChange * redraw!
    "au InsertLeave  * redraw!
    "au InsertLeave * call SetStatusLine()
    "call setwinvar(s:render
    "au WinEnter * exec 'hi StatusLineBG '.g:statusline#style.dark
    "au WinLeave * hi clear StatusLineBG
  endif

  "autocmd ColorScheme,VimEnter * call SetStatusLine()

  " BufWinEnter/Leave?
  au BufEnter,WinEnter * let w:statusline_active = 1
  au BufLeave,WinLeave * let w:statusline_active = 0
  au BufEnter,BufLeave,BufAdd,WinEnter,WinLeave * call s:render()
  " getcmdwintype()
  " The character used for the pattern indicates the type of command-line:
  "  :	normal Ex command
  "  >	debug mode command |debug-mode|
  "  /	forward search string
  "  ?	backward search string
  "  =	expression for "= |expr-register|
  "  @	string for |input()|
  "  -	text for |:insert| or |:append|
  "au CmdwinEnter,CmdwinLeave * call s:render()
endif
