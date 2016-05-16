" Vim settings

" https://github.com/skwp/dotfiles/blob/master/vim/settings.vim

if get(g:, 'loaded_settings', 0)
  finish
endif

let s:settings_path = '~/.vim/settings'
let s:plugins_path = '~/.vim/plugged'

function SourcePluginSettings(directory, check_directory)
  for l:path in split(globpath(a:directory, '*.vim'), '\n')
    let l:name = fnamemodify(l:path, ':t:r')
    let l:check = !empty(glob(a:check_directory . '/*' . l:name . '*'))
    " echom l:name . ' -> ' . l:check
    if l:check
      exe 'source' l:path
    endif
  endfor
  "let uname = system("uname -s")
  "if (fpath == expand(vimsettings) . "/yadr-keymap-mac.vim") && uname[:4] ==? "linux"
  " continue " skip mac mappings for linux
  "endif
  "if (fpath == expand(vimsettings) . "/yadr-keymap-linux.vim") && uname[:4] !=? "linux"
  " continue " skip linux mappings for mac
  "endif
endfunction

" TODO: use autoload#init()?
call SourcePluginSettings(s:settings_path, s:plugins_path)
