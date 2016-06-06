" The Silver Searcher

if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --vimgrep\ --nogroup\ --nocolor
  " Command output format (default "%f:%l:%m,%f:%l%m,%f  %l%m")
  set grepformat=%f:%l:%c:%m
endif
