" Terminal.crapp

" www.damtp.cam.ac.uk/user/rbw/vim-osx-cursor.html
"If this is Terminal.app, do cursor hack for visible cursor
"This hack does not behave well with other terminals (particularly xterm)
"function MacOSX()
"  hi CursorLine term=none cterm=none "Invisible CursorLine
"  set cursorline "cursorline required to continuously update cursor position
"  hi Cursor cterm=reverse "I like a reversed cursor, edit this to your liking
"  match Cursor /\%#/ "This line does all the work
"endfunction
"
"if $TERM_PROGRAM == "Apple_Terminal" " Terminal.app, xterm and urxvt pass this test
"  if $WINDOWID == ""                  " xterm and urxvt don't pass this test
"    "It is unlikely that anything except Terminal.app will get here
"    call MacOSX()
"  endif
"endif
"
"if $SSH_TTY != ""            " If the user is connected through ssh
"  if $TERM == "xterm-color" || $ORIGTERM = "xterm-color"
"    "Something other than Terminal.app might well get here
"    call MacOSX()
"  endif
"endif
