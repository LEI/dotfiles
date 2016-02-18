" Vim settings

" github.com/skwp/dotfiles/blob/master/vim/settings.vim

let vimsettings = '~/.vim/settings'
"let uname = system("uname -s")

for fpath in split(globpath(vimsettings, '*.vim'), '\n')
  exe 'source' fpath
endfor

"if (fpath == expand(vimsettings) . "/yadr-keymap-mac.vim") && uname[:4] ==? "linux"
" continue " skip mac mappings for linux
"endif

"if (fpath == expand(vimsettings) . "/yadr-keymap-linux.vim") && uname[:4] !=? "linux"
" continue " skip linux mappings for mac
"endif
