" Tab line

" github.com/vim-airline/vim-airline/blob/master/autoload/airline/extensions/tabline.vim

let statusline#tabline#Build = {}

function statusline#tabline#Build.render()
  let l:s = ''
  for i in range(tabpagenr('$'))
    " Select the highlighting
    if i + 1 == tabpagenr()
      let l:s.= '%#TabLineSel#'
    else
      let l:s.= '%#TabLine#'
    endif

    " Set the tab page number (for mouse clicks)
    let l:s.= '%' . (i + 1) . 'T'

    " Build label
    let l:s.= ' %{statusline#tabline#Build.label(' . (i + 1) . ')} '
  endfor

  " After the last tab fill with TabLineFill and reset tab page nr
  let l:s.= '%#TabLineFill#%T'

  " Right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let l:s.= '%=%#TabLine#%999X'.g:statusline#symbol.close
  endif

  return s
endfunction

function statusline#tabline#Build.label(n)
  let l:buflist = tabpagebuflist(a:n)
  let l:winnr = tabpagewinnr(a:n)
  return bufname(l:buflist[l:winnr - 1])
endfunction

function statusline#tabline#set()
  if !has('gui_running')
    " Display tab page labels
    " 0: never
    " 1: only if there are at least two tab pages
    " 2: always
    set showtabline=2
    setl tabline=%!statusline#tabline#Build.render()
  endif
endfunction
