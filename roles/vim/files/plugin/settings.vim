" Vim settings

" github.com/skwp/dotfiles/blob/master/vim/settings.vim

if get(g:, 'loaded_settings', 0)
  finish
endif
let g:loaded_settings = 1

let s:settings_path = '~/.vim/plugin/settings'
"let uname = system("uname -s")

for s:file_path in split(globpath(s:settings_path, '*.vim'), '\n')
  exe 'source' s:file_path
endfor

"if (fpath == expand(vimsettings) . "/yadr-keymap-mac.vim") && uname[:4] ==? "linux"
" continue " skip mac mappings for linux
"endif

"if (fpath == expand(vimsettings) . "/yadr-keymap-linux.vim") && uname[:4] !=? "linux"
" continue " skip linux mappings for mac
"endif
