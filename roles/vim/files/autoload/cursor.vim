" Cursor position
" https://github.com/junegunn/dotfiles/blob/master/vimrc
let s:braille = split('"⠉⠒⠤⣀', '\zs')
function! cursor#position() abort
  let len = len(s:braille)
  let [cur, max] = [line('.'), line('$')]
  let pos  = min([len * (cur - 1) / max([1, max - 1]), len - 1])
  return s:braille[pos]
endfunction
