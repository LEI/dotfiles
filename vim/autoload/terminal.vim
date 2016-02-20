" Terminal.crapp

" www.damtp.cam.ac.uk/user/rbw/vim-osx-cursor.html
"If this is Terminal.app, do cursor hack for visible cursor
"This hack does not behave well with other terminals (particularly xterm)
function terminal#MacOSX()
  hi CursorLine term=none cterm=none "Invisible CursorLine
  set cursorline "cursorline required to continuously update cursor position
  hi Cursor cterm=reverse "I like a reversed cursor, edit this to your liking
  match Cursor /\%#/ "This line does all the work
endfunction

